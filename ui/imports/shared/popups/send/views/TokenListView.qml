import QtQuick 2.15
import QtQml 2.15
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
        readonly property bool isBrowsingCollection: !isBrowsingTypeERC20 && !!root.collectibles && root.collectibles.currentCollectionUid !== ""
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

                visible: d.isBrowsingTypeERC20
                header: tokenHeader
                model: root.assets
                delegate: tokenDelegate

                property bool hasCommunityTokens: false
                function updateHasCommunityTokens() {
                    if (count > 0) {
                        // For assets community minted tokens are at the end of the list by design.
                        // It is faster than iterate over all the items and check their isCommunityAsset role
                        const isCommunityAsset = model.get(count - 1).isCommunityAsset
                        hasCommunityTokens = hasCommunityTokens || isCommunityAsset
                    }
                }

                onCountChanged: updateHasCommunityTokens()
                section {
                    property: "isCommunityAsset"
                    delegate: Loader {
                        required property bool section
                        width: parent.width
                        property string sectionTitle: Helpers.assetsSectionTitle(section, tokenList.hasCommunityTokens, d.isBrowsingCollection, d.isBrowsingTypeERC20)
                        active: !!sectionTitle
                        sourceComponent: AssetsSectionDelegate {
                            text: parent.sectionTitle
                            onOpenInfoPopup: Global.openPopup(communityInfoPopupCmp)
                        }
                    }
                }
            }

            // We have a separate listview for collectibles because if we switch models within one listview,
            // sections are not displayed correctly, if we play with their "visible" or "height" properties
            // when we want to hide some sections. It feels like sections are not designed to be hidden and
            // do not hide well in complex scenarios.
            StatusListView {
                id: collectiblesList

                Layout.fillWidth: true
                Layout.fillHeight: true

                visible: !d.isBrowsingTypeERC20
                header: collectibleHeader
                model: collectiblesModel
                delegate: collectiblesDelegate

                property bool hasCommunityTokens: false
                onCountChanged: updateHasCommunityTokens()

                function updateHasCommunityTokens() {
                    if (count > 0) {
                        const isCommunityAsset = model.get(0).isCommunityAsset
                        hasCommunityTokens = hasCommunityTokens || isCommunityAsset
                    }
                }

                section {
                    property: "isCommunityAsset"
                    delegate: Loader {
                        required property bool section
                        width: parent.width
                        property string sectionTitle: Helpers.assetsSectionTitle(section, collectiblesList.hasCommunityTokens, d.isBrowsingCollection, d.isBrowsingTypeERC20)
                        active: !!sectionTitle
                        sourceComponent: AssetsSectionDelegate {
                            text: parent.sectionTitle
                            onOpenInfoPopup: Global.openPopup(communityInfoPopupCmp)
                        }
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
                leftModel: !!model & !!model.balances ? model.balances : null
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
            showBottomBorder: false
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
                visible: d.isBrowsingCollection
                count: root.collectibles.count
                name: d.currentBrowsingCollectionName
                onBackClicked: root.collectibles.currentCollectionUid = ""
            }
            SearchBoxWithRightIcon {
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
