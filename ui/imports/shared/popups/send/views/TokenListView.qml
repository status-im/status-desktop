import QtQuick 2.13
import QtQuick.Layouts 1.14

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

import "../controls"

Item {
    id: root

    property string selectedSenderAccount
    property var assets: null
    property var collectibles: null
    property var networksModel

    signal tokenSelected(string symbol, var holdingType)
    signal tokenHovered(string symbol, var holdingType, bool hovered)

    property bool onlyAssets: false
    property int browsingHoldingType: Constants.TokenType.ERC20
    property var getCurrencyAmountFromBigInt: function(balance, symbol, decimals){}
    property var getCurrentCurrencyAmount: function(balance){}

    onVisibleChanged: {
        if(!visible && root.collectibles)
            root.collectibles.currentCollectionUid = ""
    }

    QtObject {
        id: d
        property string assetSearchString
        readonly property var updateAssetSearchText: Backpressure.debounce(root, 1000, function(inputText) {
            d.assetSearchString = inputText
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

        function searchAddressInList(addressPerChain, searchString) {
            let addressFound = false
            let tokenAddresses = SQUtils.ModelUtils.modelToFlatArray(addressPerChain, "address")
            for (let i =0; i< tokenAddresses.length; i++){
                if(tokenAddresses[i].toUpperCase().startsWith(searchString.toUpperCase())) {
                    addressFound = true
                    break;
                }
            }
            return addressFound
        }
    }

    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight

    ColumnLayout {
        id: contentLayout

        anchors.fill: parent
        spacing: 8

        StatusBaseText {
            id: label
            elide: Text.ElideRight
            text: qsTr("Token to send")
            font.pixelSize: 13
            color: Theme.palette.directColor1
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: column.height

            color: Theme.palette.indirectColor1
            radius: 8

            Column {
                id: column
                width: parent.width
                topPadding: root.onlyAssets ? 0 : 20

                StatusTabBar {
                    visible: !root.onlyAssets
                    height: 40
                    width: parent.width
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

                    width: parent.width
                    height: tokenList.contentHeight

                    header: root.browsingHoldingType === Constants.TokenType.ERC20 ? tokenHeader : collectibleHeader
                    model: root.browsingHoldingType === Constants.TokenType.ERC20 ? tokensModel : collectiblesModel
                    delegate: root.browsingHoldingType === Constants.TokenType.ERC20 ? tokenDelegate : collectiblesDelegate
                }
            }
        }
    }

    property var tokensModel: SortFilterProxyModel {
        sourceModel: root.assets
        filters: [
            FastExpressionFilter {
                function search(symbol, name, addressPerChain, searchString) {
                    tokenList.positionViewAtBeginning()
                    return (
                        symbol.startsWith(searchString.toUpperCase()) ||
                                name.toUpperCase().startsWith(searchString.toUpperCase()) || d.searchAddressInList(addressPerChain, searchString)
                    )
                }
                expression: search(symbol, name, addressPerChain, d.assetSearchString)
                expectedRoles: ["symbol", "name", "addressPerChain"]
            }
        ]
    }

    property var collectiblesModel: SortFilterProxyModel {
        sourceModel: d.collectiblesNetworksJointModel
        filters: [
            ExpressionFilter {
                expression: {
                    return d.collectibleSearchString === "" || name.toUpperCase().startsWith(d.collectibleSearchString.toUpperCase())
                }
            }
        ]
        sorters: RoleSorter {
            roleName: "isCollection"
            sortOrder: Qt.DescendingOrder
        }
    }

    Component {
        id: tokenDelegate
        TokenBalancePerChainDelegate {
            width: ListView.view.width
            selectedSenderAccount: root.selectedSenderAccount
            balancesModel: LeftJoinModel {
                leftModel: model.balances
                rightModel: root.networksModel
                joinRole: "chainId"
            }
            onTokenSelected: root.tokenSelected(symbol, Constants.TokenType.ERC20)
            onTokenHovered: root.tokenHovered(symbol, Constants.TokenType.ERC20, hovered)
            getCurrencyAmountFromBigInt: function(balance, symbol, decimals){
                return root.getCurrencyAmountFromBigInt(balance, symbol, decimals)
            }
            getCurrentCurrencyAmount: function(balance){
                return root.getCurrentCurrencyAmount(balance)
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
}
