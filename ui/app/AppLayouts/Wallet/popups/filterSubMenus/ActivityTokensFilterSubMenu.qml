import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1

import shared.controls 1.0
import "../../controls"

import SortFilterProxyModel 0.2

import utils 1.0

StatusMenu {
    id: root

    property var tokensFilter: []
    property var tokensList: []
    readonly property bool allTokensChecked: tokensFilter.length === 0

    property var collectiblesList: []
    property var collectiblesFilter: []
    readonly property bool allCollectiblesChecked: collectiblesFilter.length === 0

    signal back()
    signal tokenToggled(string tokenSymbol)
    signal collectibleToggled(double id)

    property var searchTokenSymbolByAddressFn: function (address) { return "" }

    implicitWidth: 289

    QtObject {
        id: d
        property bool isFetching: root.collectiblesList.isFetching
    }

    MenuBackButton {
        id: backButton
        width: parent.width
        onClicked: {
            close()
            back()
        }
    }

    StatusSwitchTabBar {
        id: tabBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: backButton.bottom
        anchors.topMargin: 12
        width: parent.width - 16
        StatusSwitchTabButton {
            text: qsTr("Assets")
        }
        StatusSwitchTabButton {
            text: qsTr("Collectibles")
        }
    }

    StackLayout {
        id: layout
        width: parent.width
        anchors.top: tabBar.bottom
        anchors.topMargin: 12
        currentIndex: tabBar.currentIndex

        Column {
            Layout.fillWidth: true
            spacing: 8

            ButtonGroup {
                id: tokenButtonGroup
                exclusive: false
            }

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("No Assets")
                visible: root.tokensList.count === 0
            }

            SearchBox {
                id: tokensSearchBox
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 16
                input.height: 36
                placeholderText: qsTr("Search asset name")
            }

            StatusListView {
                width: parent.width
                height: root.height - tabBar.height - tokensSearchBox.height - 12
                spacing: 0
                model: SortFilterProxyModel {
                    sourceModel: root.tokensList
                    filters: ExpressionFilter {
                        enabled: root.tokensList.count > 0
                        expression: {
                            var tokenSymbolByAddress = root.searchTokenSymbolByAddressFn(tokensSearchBox.text)
                            return symbol.startsWith(tokensSearchBox.text.toUpperCase()) || name.toUpperCase().startsWith(tokensSearchBox.text.toUpperCase()) || (tokenSymbolByAddress!=="" && symbol.startsWith(tokenSymbolByAddress))
                        }
                    }
                }
                delegate: ActivityTypeCheckBox {
                    width: ListView.view.width
                    height: 44
                    title: model.name
                    titleAsideText: model.symbol
                    assetSettings.name: model.symbol ? Constants.tokenIcon(symbol) : ""
                    assetSettings.isImage: true
                    buttonGroup: tokenButtonGroup
                    allChecked: root.allTokensChecked
                    checked: root.allTokensChecked || root.tokensFilter.includes(model.symbol)
                    onActionTriggered: root.tokenToggled(model.symbol)
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8

            ButtonGroup {
                id: collectibleButtonGroup
                exclusive: false
            }

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("No Collectibles")
                visible: root.collectiblesList.count === 0
            }

            SearchBox {
                id: collectiblesSearchBox
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 16
                input.height: 36
                placeholderText: qsTr("Search collectible name")
            }

            StatusListView {
                width: parent.width
                height: root.height - tabBar.height - tokensSearchBox.height - 12
                spacing: 0
                model: SortFilterProxyModel {
                    sourceModel: root.collectiblesList
                    filters: ExpressionFilter {
                        enabled: root.collectiblesList.count > 0 && !!collectiblesSearchBox.text
                        expression: {
                            let searchText = collectiblesSearchBox.text.toUpperCase()
                            return name.toUpperCase().startsWith(searchText)
                        }
                    }
                }
                delegate: ActivityTypeCheckBox {
                    width: ListView.view.width
                    height: 44
                    title: model.name
                    assetSettings.name: model.imageUrl
                    assetSettings.isImage: true
                    assetSettings.bgWidth: 32
                    assetSettings.bgHeight: 32
                    assetSettings.bgRadius: assetSettings.bgHeight/2
                    buttonGroup: collectibleButtonGroup
                    allChecked: root.allCollectiblesChecked
                    checked: root.allCollectiblesChecked || root.collectiblesFilter.includes(model.id)
                    onActionTriggered: root.collectibleToggled(model.id)
                    loading: d.isFetching
                }
            }
        }
    }
}
