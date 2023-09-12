import QtQuick 2.13
import QtQuick.Layouts 1.14

import SortFilterProxyModel 0.2

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

import "../controls"

Item {
    id: root

    property var assets: null
    property var collectibles: null
    signal tokenSelected(string symbol, var holdingType)
    signal tokenHovered(string symbol, var holdingType, bool hovered)
    property var searchTokenSymbolByAddressFn: function (address) {
        return ""
    }
    property var getNetworkIcon: function(chainId){}
    property bool onlyAssets: false
    property int browsingHoldingType: Constants.HoldingType.Asset

    onVisibleChanged: {
        if(!visible)
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
                                                [Constants.HoldingType.Asset] :
                                                [Constants.HoldingType.Asset, Constants.HoldingType.Collectible]

        readonly property var tabsModel: onlyAssets ?
                                             [qsTr("Assets")] :
                                             [qsTr("Assets"), qsTr("Collectibles")]

        property string currentBrowsingCollectionName
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
                topPadding: 20

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

                    header: root.browsingHoldingType === Constants.HoldingType.Asset ? tokenHeader : collectibleHeader
                    model: root.browsingHoldingType === Constants.HoldingType.Asset ? tokensModel : collectiblesModel
                    delegate: root.browsingHoldingType === Constants.HoldingType.Asset ? tokenDelegate : collectiblesDelegate
                }
            }
        }
    }

    property var tokensModel: SortFilterProxyModel {
        sourceModel: root.assets
        filters: [
            ExpressionFilter {
                expression: {
                    var tokenSymbolByAddress = searchTokenSymbolByAddressFn(d.assetSearchString)
                    tokenList.positionViewAtBeginning()
                    return visibleForNetwork && (
                                symbol.startsWith(d.assetSearchString.toUpperCase()) || name.toUpperCase().startsWith(d.assetSearchString.toUpperCase()) || (tokenSymbolByAddress!=="" && symbol.startsWith(tokenSymbolByAddress))
                                )
                }
            }
        ]
    }
    property var collectiblesModel: SortFilterProxyModel {
        sourceModel: root.collectibles
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
            getNetworkIcon: root.getNetworkIcon
            onTokenSelected: root.tokenSelected(symbol, Constants.HoldingType.Asset)
            onTokenHovered: root.tokenHovered(symbol, Constants.HoldingType.Asset, hovered)
        }
    }
    Component {
        id: tokenHeader
        SearchBoxWithRightIcon {
            showTopBorder: true
            width: parent.width
            placeholderText: qsTr("Search for token or enter token address")
            onTextChanged: Qt.callLater(d.updateAssetSearchText, text)
        }
    }
    Component {
        id: collectiblesDelegate
        CollectibleNestedDelegate {
            width: ListView.view.width
            getNetworkIcon: root.getNetworkIcon
            onItemHovered: root.tokenHovered(selectedItem.uid, Constants.HoldingType.Collectible, hovered)
            onItemSelected: {
                if (isCollection) {
                    d.currentBrowsingCollectionName = collectionName
                    root.collectibles.currentCollectionUid = collectionUid
                } else {
                    root.tokenSelected(selectedItem.uid, Constants.HoldingType.Collectible)
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
