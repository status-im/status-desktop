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

    property var tokensList
    property var collectiblesList

    signal back()
    signal tokenToggled(string tokenSymbol)
    signal collectibleToggled(string name)

    property var searchTokenSymbolByAddressFn: function (address) {
        return ""
    }

    implicitWidth: 289

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

            SearchBox {
                id: tokensSearchBox
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 16
                input.height: 36
                placeholderText: qsTr("Search asset name")
            }

            ColumnLayout {
                width: parent.width
                spacing: 0
                Repeater {
                    model: SortFilterProxyModel {
                        sourceModel: root.tokensList
                        filters: [
                            ExpressionFilter {
                                expression: {
                                    var tokenSymbolByAddress = root.searchTokenSymbolByAddressFn(tokensSearchBox.text)
                                    return symbol.startsWith(tokensSearchBox.text.toUpperCase()) || name.toUpperCase().startsWith(tokensSearchBox.text.toUpperCase()) || (tokenSymbolByAddress!=="" && symbol.startsWith(tokenSymbolByAddress))
                                }
                            }
                        ]
                    }
                    delegate: ActivityTypeCheckBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        title: model.name
                        titleAsideText: model.symbol
                        assetSettings.name: model.symbol ? Constants.tokenIcon(symbol) : ""
                        assetSettings.isImage: true
                        buttonGroup: tokenButtonGroup
                        allChecked: model.allChecked
                        checked: model.checked
                        onActionTriggered: root.tokenToggled(model.symbol)
                    }
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

            SearchBox {
                id: collectiblesSearchBox
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 16
                input.height: 36
                placeholderText: qsTr("Search collectible name")
            }

            ColumnLayout {
                width: parent.width
                spacing: 0
                Repeater {
                    model: SortFilterProxyModel {
                        sourceModel: root.collectiblesList
                        filters: [
                            ExpressionFilter {
                                expression: {
                                    return model.name.toUpperCase().startsWith(collectiblesSearchBox.text.toUpperCase())
                                }
                            }
                        ]
                    }
                    delegate: ActivityTypeCheckBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        title: model.name
                        assetSettings.name: model.iconSource
                        assetSettings.bgWidth: 32
                        assetSettings.bgHeight: 32
                        assetSettings.bgRadius: assetSettings.bgHeight/2
                        assetSettings.isImage: true
                        buttonGroup: collectibleButtonGroup
                        allChecked: model.allChecked
                        checked: model.checked
                        onActionTriggered: root.collectibleToggled(name)
                    }
                }
            }
        }
    }
}
