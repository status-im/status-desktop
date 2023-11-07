
import QtQml 2.15
import QtQuick 2.13
import QtQuick.Layouts 1.13

import shared.controls 1.0
import utils 1.0

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"

Item {
    id: root
    property var assetsModel
    property var collectiblesModel
    property var networksModel
    property string currentCurrencySymbol
    property bool onlyAssets: true

    implicitWidth: holdingItemSelector.implicitWidth
    implicitHeight: holdingItemSelector.implicitHeight

    property var searchAssetSymbolByAddressFn: function (address) {
        return ""
    }

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

        property int browsingHoldingType: Constants.TokenType.ERC20
        readonly property bool isCurrentBrowsingTypeAsset: isAsset(browsingHoldingType)
        readonly property bool isBrowsingCollection: !isCurrentBrowsingTypeAsset && !!collectiblesModel && collectiblesModel.currentCollectionUid !== ""
        property string currentBrowsingCollectionName

        property var currentHoldingType: Constants.TokenType.Unknown

        property string searchText
        readonly property string assetSymbolByAddress: isCurrentBrowsingTypeAsset ? "": root.searchAssetSymbolByAddressFn(searchText)
        readonly property string uppercaseSearchText: searchText.toUpperCase()

        property var assetTextFn: function (asset) {
            return !!asset && asset.symbol ? asset.symbol : ""
        }

        property var assetIconSourceFn: function (asset) {
            return !!asset && asset.symbol ? Style.png("tokens/%1".arg(asset.symbol)) : ""
        }

        property var assetComboBoxModel: SortFilterProxyModel {
            sourceModel: root.assetsModel
            filters: [
                ExpressionFilter {
                    expression: {
                        d.uppercaseSearchText; // Force re-evaluation when searchText changes
                        return (
                            d.uppercaseSearchText === "" ||
                            symbol.startsWith(d.uppercaseSearchText) ||
                            name.toUpperCase().startsWith(d.uppercaseSearchText) |
                            (d.assetSymbolByAddress !== "" && symbol.startsWith(d.assetSymbolByAddress))
                        )
                    }
                }
            ]
        }

        property var collectibleTextFn: function (item) {
            if (!!item) {
                return !!item.collectionName ? item.collectionName + ": " + item.name : item.name
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
            filters: [
                ExpressionFilter {
                    expression: {
                        return d.uppercaseSearchText === "" || name.toUpperCase().startsWith(d.uppercaseSearchText)
                    }
                }
            ]
            sorters: RoleSorter {
                roleName: "isCollection"
                sortOrder: Qt.DescendingOrder
            }
        }

        readonly property string searchPlaceholderText: {
            if (isCurrentBrowsingTypeAsset) {
                return qsTr("Search for token or enter token address")
            } else if (isBrowsingCollection) {
                return qsTr("Search %1").arg(d.currentBrowsingCollectionName ?? qsTr("collectibles in collection"))
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
              // asset
              property var symbol: model.symbol
              property var totalBalance: model.totalBalance
              property var totalCurrencyBalance: model.totalCurrencyBalance
              property var decimals: model.decimals
              property var balances: model.balances
              // collectible
              property var uid: model.uid
              property var iconUrl: model.iconUrl
              property var networkIconUrl: model.networkIconUrl
              property var collectionUid: model.collectionUid
              property var collectionName: model.collectionName
              property var isCollection: model.isCollection

              sourceComponent: d.isCurrentBrowsingTypeAsset ? assetComboBoxDelegate : collectibleComboBoxDelegate
          }
        }

        comboBoxPopupHeader: headerComponent
        itemTextFn: d.isCurrentBrowsingTypeAsset ? d.assetTextFn : d.collectibleTextFn
        itemIconSourceFn: d.isCurrentBrowsingTypeAsset ? d.assetIconSourceFn : d.collectibleIconSourceFn
        comboBoxModel: d.isCurrentBrowsingTypeAsset ? d.assetComboBoxModel : d.collectibleComboBoxModel

        contentIconSize: d.isAsset(d.currentHoldingType) ? d.assetContentIconSize : d.collectibleContentIconSize
        contentTextSize: d.isAsset(d.currentHoldingType) ? d.assetContentTextSize : d.collectibleContentTextSize
    }

    Component {
        id: headerComponent
        ColumnLayout {
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
                visible: d.isBrowsingCollection
                count: collectiblesModel.count
                name: d.currentBrowsingCollectionName
                onBackClicked: {
                    if (!d.isCurrentBrowsingTypeAsset) {
                        root.collectiblesModel.currentCollectionUid = ""
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
            balancesModel: LeftJoinModel {
                leftModel: balances
                rightModel: root.networksModel
                joinRole: "chainId"
            }
            onTokenSelected: {
                holdingItemSelector.selectedItem = selectedToken
                d.currentHoldingType = Constants.TokenType.ERC20
                root.itemSelected(selectedToken.symbol, Constants.TokenType.ERC20)
                holdingItemSelector.comboBoxControl.popup.close()
            }
        }
    }

    Component {
        id: collectibleComboBoxDelegate
        CollectibleNestedDelegate {
            objectName: "CollectibleSelector_ItemDelegate_" + collectionUid
            width: holdingItemSelector.comboBoxControl.popup.width
            onItemSelected: {
                if (isCollection) {
                    d.currentBrowsingCollectionName = collectionName
                    root.collectiblesModel.currentCollectionUid = collectionUid
                } else {
                    holdingItemSelector.selectedItem = selectedItem
                    d.currentHoldingType = Constants.TokenType.ERC721
                    root.itemSelected(selectedItem.uid, Constants.TokenType.ERC721)
                    holdingItemSelector.comboBoxControl.popup.close()
                }
            }
        }
    }
}
