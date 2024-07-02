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

    property var assets: null
    property var collectibles: null
    property var networksModel
    property string assetSearchString

    signal tokenSelected(string symbol, var holdingType)
    signal tokenHovered(string symbol, var holdingType, bool hovered)

    property bool onlyAssets: false
    property int browsingHoldingType: Constants.TokenType.ERC20
    property var formatCurrentCurrencyAmount: function(balance){}
    property var formatCurrencyAmountFromBigInt: function(balance, symbol, decimals){}

    onVisibleChanged: {
        if(!visible) {
            if (!!root.collectibles)
                root.collectibles.currentGroupId = ""
            // Send Modal doesn't open with a valid headerItem
            if (!!tokenList.headerItem && !!tokenList.headerItem.input)
                tokenList.headerItem.input.edit.clear()
        }
    }

    QtObject {
        id: d
        readonly property var updateAssetSearchText: Backpressure.debounce(root, 1000, function(inputText) {
            assetSearchString = inputText
        })

        property string collectibleSearchString
        readonly property var updateCollectibleSearchText: Backpressure.debounce(root, 1000, function(inputText) {
            d.collectibleSearchString = inputText
        })

        // Internal management properties and signals:
        readonly property var holdingTypes: onlyAssets ?
                                                [Constants.TokenType.ERC20] :
                                                [Constants.TokenType.ERC20, Constants.TokenType.ERC721]

        readonly property var tabsModel: onlyAssets ?
                                             [qsTr("Assets")] :
                                             [qsTr("Assets"), qsTr("Collectibles")]

        property string currentBrowsingGroupName

        readonly property RolesRenamingModel renamedAllNetworksModel: RolesRenamingModel {
            sourceModel: root.networksModel
            mapping: RoleRename {
                from: "iconUrl"
                to: "networkIconUrl"
            }
        }

        readonly property LeftJoinModel collectiblesNetworksJointModel: LeftJoinModel {
            leftModel: root.collectibles
            rightModel: d.renamedAllNetworksModel
            joinRole: "chainId"
        }

        readonly property bool isBrowsingTypeERC20: root.browsingHoldingType === Constants.TokenType.ERC20
        readonly property bool isBrowsingGroup: !isBrowsingTypeERC20 && !!root.collectibles && root.collectibles.currentGroupId !== ""

        function isCommunityItem(type) {
            return type === Constants.CollectiblesNestedItemType.CommunityCollectible ||
                   type === Constants.CollectiblesNestedItemType.Community
        }

        function isGroupItem(type) {
            return type === Constants.CollectiblesNestedItemType.Collection ||
                   type === Constants.CollectiblesNestedItemType.Community
        }
    }

    StatusBaseText {
        id: label
        anchors.top: parent.top
        elide: Text.ElideRight
        text: qsTr("Token to send")
        font.pixelSize: 13
        color: Theme.palette.directColor1
    }

    Rectangle {
        anchors.top: label.bottom
        anchors.topMargin: 8
        width: parent.width
        height: parent.height

        color: Theme.palette.indirectColor1
        radius: 8

        ColumnLayout {
            id: column

            anchors.fill: parent
            anchors.topMargin: root.onlyAssets ? 0 : 20

            StatusTabBar {
                visible: !root.onlyAssets
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                currentIndex: d.holdingTypes.indexOf(root.browsingHoldingType)

                onCurrentIndexChanged: {
                    if (currentIndex >= 0) {
                        root.browsingHoldingType = d.holdingTypes[currentIndex]
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

            StatusListView {
                id: tokenList

                Layout.fillWidth: true
                Layout.fillHeight: true

                // Control order of components not to mix models and delegates
                function resetComponents() {
                    tokenList.model = []
                    tokenList.delegate = d.isBrowsingTypeERC20 ? tokenDelegate : collectiblesDelegate
                    tokenList.header = d.isBrowsingTypeERC20 ? tokenHeader : collectibleHeader
                    tokenList.model = d.isBrowsingTypeERC20 ? root.assets : root.collectiblesModel
                }

                Component.onCompleted: resetComponents()
                Connections {
                    target: d
                    function onIsBrowsingTypeERC20Changed() {
                        tokenList.resetComponents()
                    }
                }

                property bool hasCommunityTokens: false
                function updateHasCommunityTokens() {
                    hasCommunityTokens = Helpers.modelHasCommunityTokens(model, d.isBrowsingTypeERC20)
                }

                onModelChanged: updateHasCommunityTokens()
                section {
                    property: "isCommunityAsset"
                    delegate: AssetsSectionDelegate {
                        required property bool section
                        width: parent.width
                        height: !!text ? 52 : 0 // if we bind to some property instead of hardcoded value it wont work nice when switching tabs or going inside collection and back
                        text: Helpers.assetsSectionTitle(section, tokenList.hasCommunityTokens, d.isBrowsingGroup, d.isBrowsingTypeERC20)
                        onInfoButtonClicked: Global.openPopup(communityInfoPopupCmp)
                    }
                }
            }
        }
    }

    property var collectiblesModel: SortFilterProxyModel {
        sourceModel: d.collectiblesNetworksJointModel
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
                    return d.collectibleSearchString === "" || name.toUpperCase().startsWith(d.collectibleSearchString.toUpperCase())
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

    Component {
        id: tokenDelegate
        TokenBalancePerChainDelegate {
            width: tokenList.width

            balancesModel: LeftJoinModel {
                leftModel: !!model & !!model.balancesModel ? model.balancesModel : null
                rightModel: root.networksModel
                joinRole: "chainId"
            }
            onTokenSelected: function (selectedToken) {
                root.tokenSelected(selectedToken.symbol, Constants.TokenType.ERC20)
            }
            onTokenHovered: root.tokenHovered(selectedToken.symbol, Constants.TokenType.ERC20, hovered)
            formatCurrentCurrencyAmount: function(balance){
                return root.formatCurrentCurrencyAmount(balance)
            }
            formatCurrencyAmountFromBigInt: function(balance, symbol, decimals){
                return root.formatCurrencyAmountFromBigInt(balance, symbol, decimals)
            }
        }
    }
    Component {
        id: tokenHeader
        SearchBoxWithRightIcon {
            showTopBorder: !root.onlyAssets
            showBottomBorder: false
            width: tokenList.width
            placeholderText: qsTr("Search for token or enter token address")
            onTextChanged: Qt.callLater(d.updateAssetSearchText, text)
        }
    }
    Component {
        id: collectiblesDelegate
        CollectibleNestedDelegate {
            width: tokenList.width
            onItemHovered: root.tokenHovered(selectedItem.uid, Constants.TokenType.ERC721, hovered)
            onItemSelected: {
                if (isGroup) {
                    d.currentBrowsingGroupName = groupName
                    root.collectibles.currentGroupId = groupId
                } else {
                    root.tokenSelected(selectedItem.uid, Constants.TokenType.ERC721)
                }
            }
        }
    }
    Component {
        id: collectibleHeader
        ColumnLayout {
            width: tokenList.width
            spacing: 0
            CollectibleBackButtonWithInfo {
                Layout.fillWidth: true
                visible: d.isBrowsingGroup
                count: root.collectibles.count
                name: d.currentBrowsingGroupName
                onBackClicked: {
                    searchBox.reset()
                    root.collectibles.currentGroupId = ""
                }
            }
            SearchBoxWithRightIcon {
                id: searchBox

                Layout.fillWidth: true
                showTopBorder: true
                showBottomBorder: false
                placeholderText: qsTr("Search collectibles")
                onTextChanged: Qt.callLater(d.updateCollectibleSearchText, text)
            }
        }
    }

    Component {
        id: communityInfoPopupCmp
        CommunityAssetsInfoPopup {}
    }
}
