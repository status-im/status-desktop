import QtQuick 2.13
import QtQuick.Layouts 1.14

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

import shared.controls 1.0
import shared.popups 1.0
import "../controls"

Item {
    id: root

    property string selectedSenderAccount
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
            if (root.collectibles)
                root.collectibles.currentCollectionUid = ""
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

        property string currentBrowsingCollectionName

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

                header: d.isBrowsingTypeERC20 ? tokenHeader : collectibleHeader
                model: d.isBrowsingTypeERC20 ? root.assets : collectiblesModel
                delegate: d.isBrowsingTypeERC20 ? tokenDelegate : collectiblesDelegate
                section {
                    property: "isCommunityAsset"
                    delegate: Loader {
                        width: ListView.view.width
                        required property string section
                        sourceComponent: section === "true" ? sectionDelegate : null
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
                expression: !!model.communityId
                expectedRoles: ["communityId"]
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
                roleName: "isCollection"
                sortOrder: Qt.DescendingOrder
            }
        ]
    }

    Component {
        id: tokenDelegate
        TokenBalancePerChainDelegate {
            width: ListView.view.width
            selectedSenderAccount: root.selectedSenderAccount
            balancesModel: LeftJoinModel {
                leftModel: !!model & !!model.balances ? model.balances : nil
                rightModel: root.networksModel
                joinRole: "chainId"
            }
            onTokenSelected: root.tokenSelected(symbol, Constants.TokenType.ERC20)
            onTokenHovered: root.tokenHovered(symbol, Constants.TokenType.ERC20, hovered)
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
            width: ListView.view.width
            placeholderText: qsTr("Search for token or enter token address")
            onTextChanged: Qt.callLater(d.updateAssetSearchText, text)
        }
    }
    Component {
        id: collectiblesDelegate
        CollectibleNestedDelegate {
            width: ListView.view.width
            onItemHovered: root.tokenHovered(selectedItem.uid, Constants.TokenType.ERC721, hovered)
            onItemSelected: {
                if (isCollection) {
                    d.currentBrowsingCollectionName = collectionName
                    root.collectibles.currentCollectionUid = collectionUid
                } else {
                    root.tokenSelected(selectedItem.uid, Constants.TokenType.ERC721)
                }
            }
        }
    }
    Component {
        id: collectibleHeader
        ColumnLayout {
            width: parent.width
            spacing: 0
            CollectibleBackButtonWithInfo {
                Layout.fillWidth: true
                visible: !!root.collectibles && root.collectibles.currentCollectionUid !== ""
                count: root.collectibles.count
                name: d.currentBrowsingCollectionName
                onBackClicked: root.collectibles.currentCollectionUid = ""
            }
            SearchBoxWithRightIcon {
                Layout.fillWidth: true
                showTopBorder: true
                placeholderText: qsTr("Search collectibles")
                onTextChanged: Qt.callLater(d.updateCollectibleSearchText, text)
            }
        }
    }

    Component {
        id: sectionDelegate
        AssetsSectionDelegate {
            width: parent.width
            onOpenInfoPopup: Global.openPopup(communityInfoPopupCmp)
        }
    }

    Component {
        id: communityInfoPopupCmp
        CommunityAssetsInfoPopup {}
    }
}
