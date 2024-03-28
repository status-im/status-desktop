
import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

import shared.controls 1.0
import shared.popups 1.0
import shared.popups.send 1.0
import "../controls"

Item {
    id: root

    property var assetsModel
    property string selectedSenderAccount
    property var collectiblesModel
    property var networksModel
    property string currentCurrencySymbol
    property bool onlyAssets: true
    property string searchText

    implicitWidth: holdingItemSelector.implicitWidth
    implicitHeight: holdingItemSelector.implicitHeight

    property var formatCurrentCurrencyAmount: function(balance){}
    property var formatCurrencyAmountFromBigInt: function(balance, symbol, decimals){}

    signal itemHovered(string holdingId, var holdingType)
    signal itemSelected(string holdingId, var holdingType)

    property alias selectedItem: holdingItemSelector.selectedItem
    property alias hoveredItem: holdingItemSelector.hoveredItem

    function setSelectedItem(item, holdingType) {
        d.browsingHoldingType = holdingType
        holdingItemSelector.selectedItem = null
        d.currentHoldingType = holdingType
        holdingItemSelector.selectedItem = item
    }

    function setHoveredItem(item, holdingType) {
        d.browsingHoldingType = holdingType
        holdingItemSelector.hoveredItem = null
        d.currentHoldingType = holdingType
        holdingItemSelector.hoveredItem = item
    }

    QtObject {
        id: d
        // Internal management properties and signals:
        readonly property var holdingTypes: onlyAssets ?
         [Constants.TokenType.ERC20] :
         [Constants.TokenType.ERC20, Constants.TokenType.ERC721]

        readonly property var tabsModel: onlyAssets ?
         [qsTr("Assets")] :
         [qsTr("Assets"), qsTr("Collectibles")]

        readonly property var updateSearchText: Backpressure.debounce(root, 1000, function(inputText) {
            searchText = inputText
        })

        function isAsset(type) {
            return type === Constants.TokenType.ERC20
        }

        function isCommunityItem(type) {
            return type === Constants.CollectiblesNestedItemType.CommunityCollectible ||
                   type === Constants.CollectiblesNestedItemType.Community
        }

        function isGroupItem(type) {
            return type === Constants.CollectiblesNestedItemType.Collection ||
                   type === Constants.CollectiblesNestedItemType.Community
        }

        property int browsingHoldingType: Constants.TokenType.ERC20
        readonly property bool isCurrentBrowsingTypeAsset: isAsset(browsingHoldingType)
        readonly property bool isBrowsingGroup: !isCurrentBrowsingTypeAsset && !!root.collectiblesModel && root.collectiblesModel.currentGroupId !== ""
        property string currentBrowsingGroupName

        property var currentHoldingType: Constants.TokenType.Unknown

        readonly property string uppercaseSearchText: searchText.toUpperCase()

        property var assetTextFn: function (asset) {
            return !!asset && asset.symbol ? asset.symbol : ""
        }

        property var assetIconSourceFn: function (asset) {
            if (!asset) {
                return ""
            } else if (asset.image) {
                // Community assets have a dedicated image streamed from status-go
                return asset.image
            } else {
                return Constants.tokenIcon(asset.symbol)
            }
            return ""
        }

        property var collectibleTextFn: function (item) {
            if (!!item) {
                return !!item.groupName ? item.groupName + ": " + item.name : item.name
            }
            return ""
        }

        property var collectibleIconSourceFn: function (item) {
            return !!item && item.iconUrl ? item.iconUrl : ""
        }

        readonly property RolesRenamingModel renamedAllNetworksModel: RolesRenamingModel {
            sourceModel: root.networksModel
            mapping: RoleRename {
                from: "iconUrl"
                to: "networkIconUrl"
            }
        }

        readonly property LeftJoinModel collectibleNetworksJointModel: LeftJoinModel {
            leftModel: root.collectiblesModel
            rightModel: d.renamedAllNetworksModel
            joinRole: "chainId"
        }

        property var collectibleComboBoxModel: SortFilterProxyModel {
            sourceModel: d.collectibleNetworksJointModel
            proxyRoles: [
                FastExpressionRole {
                    name: "isCommunityAsset"
                    expression: d.isCommunityItem(model.itemType)
                    expectedRoles: ["itemType"]
                },
                FastExpressionRole {
                    name: "isGroup"
                    expression: d.isGroupItem(model.itemType)
                    expectedRoles: ["itemType"]
                }
            ]
            filters: [
                ExpressionFilter {
                    expression: {
                        return d.uppercaseSearchText === "" || name.toUpperCase().startsWith(d.uppercaseSearchText)
                    }
                }
            ]
            sorters: [
                RoleSorter {
                    roleName: "isCommunityAsset"
                    sortOrder: Qt.DescendingOrder
                },
                RoleSorter {
                    roleName: "isGroup"
                    sortOrder: Qt.DescendingOrder
                }
            ]
        }

        readonly property string searchPlaceholderText: {
            if (isCurrentBrowsingTypeAsset) {
                return qsTr("Search for token or enter token address")
            } else if (isBrowsingGroup) {
                return qsTr("Search %1").arg(d.currentBrowsingGroupName ?? qsTr("collectibles in collection"))
            } else {
                return qsTr("Search collectibles")
            }
        }

        // By design values:
        readonly property int padding: 16
        readonly property int headerTopMargin: 5
        readonly property int tabBarTopMargin: 20
        readonly property int tabBarHeight: 35
        readonly property int bottomInset: 20
        readonly property int assetContentIconSize: 21
        readonly property int collectibleContentIconSize: 28
        readonly property int assetContentTextSize: 28
        readonly property int collectibleContentTextSize: 15

    }

    HoldingItemSelector {
        id: holdingItemSelector
        width: parent.width
        height: parent.height

        defaultIconSource: Style.png("tokens/DEFAULT-TOKEN@3x")
        placeholderText: d.isCurrentBrowsingTypeAsset ? qsTr("Select token") : qsTr("Select collectible")
        property bool hasCommunityTokens: false

        comboBoxDelegate: Item {
          property var itemModel: model // read 'model' from the delegate's context
          width: loader.width
          height: loader.height
          Loader {
              id: loader

              // inject model properties to the loaded item's context
              // common
              property var model: itemModel
              property var chainId: model.chainId
              property var name: model.name
              property var tokenType: model.tokenType
              // asset
              property var symbol: model.symbol
              property var totalBalance: model.totalBalance
              property var marketDetails: model.marketDetails
              property var decimals: model.decimals
              property var balances: model.balances
              // collectible
              property var uid: model.uid
              property var iconUrl: model.iconUrl
              property var networkIconUrl: model.networkIconUrl
              property var groupId: model.groupId
              property var groupName: model.groupName
              property var isGroup: model.isGroup
              property var count: model.count
          }
        }

        // Switch models and delegate in the right order not to mix different models and delegates
        function updateComponents() {
            holdingItemSelector.comboBoxModel = []
            sourceComponent: d.isCurrentBrowsingTypeAsset ? assetComboBoxDelegate : collectibleComboBoxDelegate
            holdingItemSelector.comboBoxModel = d.isCurrentBrowsingTypeAsset
                                                    ? root.assetsModel
                                                    : d.collectibleComboBoxModel
        }
        Component.onCompleted: updateComponents()
        Connections {
            target: d
            function onIsCurrentBrowsingTypeAssetChanged() {
                holdingItemSelector.updateComponents()
            }
        }
        comboBoxModel: null

        comboBoxPopupHeader: headerComponent
        itemTextFn: d.isCurrentBrowsingTypeAsset ? d.assetTextFn : d.collectibleTextFn
        itemIconSourceFn: d.isCurrentBrowsingTypeAsset ? d.assetIconSourceFn : d.collectibleIconSourceFn
        onComboBoxModelChanged: updateHasCommunityTokens()

        function updateHasCommunityTokens() {
            hasCommunityTokens = Helpers.modelHasCommunityTokens(comboBoxModel, d.isCurrentBrowsingTypeAsset)
        }

        contentIconSize: d.isAsset(d.currentHoldingType) ? d.assetContentIconSize : d.collectibleContentIconSize
        contentTextSize: d.isAsset(d.currentHoldingType) ? d.assetContentTextSize : d.collectibleContentTextSize
        comboBoxListViewSection.property: "isCommunityAsset"
        comboBoxListViewSection.delegate: AssetsSectionDelegate {
                            height: !!text ? 52 : 0 // if we bind to some property instead of hardcoded value it wont work nice when switching tabs or going inside collection and back
                            width: ListView.view.width
                            required property bool section
                            text: Helpers.assetsSectionTitle(section, holdingItemSelector.hasCommunityTokens, d.isBrowsingGroup, d.isCurrentBrowsingTypeAsset)
                            onOpenInfoPopup: Global.openPopup(communityInfoPopupCmp)
                        }
        comboBoxControl.popup.onClosed: comboBoxControl.popup.contentItem.headerItem.clear()
    }

    Component {
        id: communityInfoPopupCmp
        CommunityAssetsInfoPopup {}
    }

    Component {
        id: headerComponent
        ColumnLayout {
            function clear() {
                searchInput.input.edit.clear()
            }

            width: holdingItemSelector.comboBoxControl.popup.width
            Layout.topMargin: d.headerTopMargin
            spacing: -1 // Used to overlap rectangles from row components

            StatusTabBar {
                id: tabBar

                visible: !root.onlyAssets
                Layout.preferredHeight: d.tabBarHeight
                Layout.fillWidth: true
                Layout.leftMargin: d.padding
                Layout.rightMargin: d.padding
                Layout.topMargin: d.tabBarTopMargin
                Layout.bottomMargin: 6
                currentIndex: d.holdingTypes.indexOf(d.browsingHoldingType)

                onCurrentIndexChanged: {
                    if (currentIndex >= 0) {
                        d.browsingHoldingType = d.holdingTypes[currentIndex]
                    }
                }

                Repeater {
                    id: tabLabelsRepeater
                    model: d.tabsModel

                    StatusTabButton {
                        text: modelData
                        width: implicitWidth
                    }
                }
            }
            CollectibleBackButtonWithInfo {
                Layout.fillWidth: true
                visible: d.isBrowsingGroup
                count: collectiblesModel.count
                name: d.currentBrowsingGroupName
                onBackClicked: {
                    if (!d.isCurrentBrowsingTypeAsset) {
                        searchInput.reset()
                        root.collectiblesModel.currentGroupId = ""
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: searchInput.input.implicitHeight

                color: "transparent"
                border.color: Theme.palette.baseColor2
                border.width: 1

                StatusInput {
                    id: searchInput
                    anchors.fill: parent

                    input.showBackground: false
                    placeholderText: d.searchPlaceholderText
                    onTextChanged: Qt.callLater(d.updateSearchText, text)
                    input.clearable: true
                    input.implicitHeight: 56
                    input.rightComponent: StatusFlatRoundButton {
                        icon.name: "search"
                        type: StatusFlatRoundButton.Type.Secondary
                        enabled: false
                    }
                }
            }
        }
    }

    Component {
        id: assetComboBoxDelegate
        TokenBalancePerChainDelegate {
            objectName: "AssetSelector_ItemDelegate_" + symbol
            width: holdingItemSelector.comboBoxControl.popup.width
            selectedSenderAccount: root.selectedSenderAccount
            balancesModel: LeftJoinModel {
                leftModel: balances
                rightModel: root.networksModel
                joinRole: "chainId"
            }
            onTokenSelected: function (selectedToken) {
                holdingItemSelector.selectedItem = selectedToken
                d.currentHoldingType = Constants.TokenType.ERC20
                root.itemSelected(selectedToken.symbol, Constants.TokenType.ERC20)
                holdingItemSelector.comboBoxControl.popup.close()
            }
            formatCurrentCurrencyAmount: function(balance){
                return root.formatCurrentCurrencyAmount(balance)
            }
            formatCurrencyAmountFromBigInt: function(balance, symbol, decimals){
                return root.formatCurrencyAmountFromBigInt(balance, symbol, decimals)
            }
        }
    }

    Component {
        id: collectibleComboBoxDelegate
        CollectibleNestedDelegate {
            objectName: "CollectibleSelector_ItemDelegate_" + groupId
            width: holdingItemSelector.comboBoxControl.popup.width
            onItemSelected: {
                if (isGroup) {
                    d.currentBrowsingGroupName = groupName
                    root.collectiblesModel.currentGroupId = groupId
                } else {
                    holdingItemSelector.selectedItem = selectedItem
                    d.currentHoldingType = tokenType
                    root.itemSelected(selectedItem.uid, tokenType)
                    holdingItemSelector.comboBoxControl.popup.close()
                }
            }
        }
    }
}
