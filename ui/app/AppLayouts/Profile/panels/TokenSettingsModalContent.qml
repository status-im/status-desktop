import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import shared.panels 1.0
import shared.controls 1.0

Item {
    id: modalBody

    property var defaultTokenList
    property var customTokenList
    signal toggleVisibleClicked(int chainId, string address)
    signal removeCustomTokenTriggered(int chainId, string address)
    signal showTokenDetailsTriggered(int chainId, string address, string name, string symbol, string decimals)

    Component {
        id: tokenComponent

        StatusListItem {
            id: assetSymbol
            title: symbol
            subTitle: name || ""
            image.source: Style.png("tokens/" + (hasIcon ? symbol : "DEFAULT-TOKEN@3x"))
            image.height: Style.dp(36)
            components: [StatusCheckBox {
                id: assetCheck
                checked: model.isVisible
                onClicked: toggleVisibleClicked(chainId, address)
            }]
            visible: symbol && (searchBox.text == "" || name.toLowerCase().includes(searchBox.text.toLowerCase()) || symbol.toLowerCase().includes(searchBox.text.toLowerCase()))
            MouseArea {
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: function (event) {
                    if (event.button === Qt.RightButton) {
                        return contextMenu.popup(mouseX, mouseY)
                    }
                    assetCheck.checked = !assetCheck.checked
                    toggleVisibleClicked(chainId, address)
                }
                
                StatusPopupMenu {
                    id: contextMenu
                    Action {
                        icon.name: "admin"
                        //% "Token details"
                        text: qsTrId("token-details")
                        onTriggered: {
                            modalBody.showTokenDetailsTriggered(chainId, address, name, symbol, decimals);
                        }
                    }
                    Action {
                        icon.name: "remove"
                        icon.color: Style.current.red
                        enabled: isCustom
                        //% "Remove token"
                        text: qsTrId("remove-token")
                        onTriggered: removeCustomTokenTriggered(chainId, address)
                    }
                }
            }
        }  
    }

    SearchBox {
        id: searchBox
        input.font.pixelSize: Style.current.tertiaryTextFontSize
        anchors.top: modalBody.top
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        anchors.left: parent.left
    }


    ScrollView {
        id: sview
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        contentHeight: tokenList.height

        anchors.top: searchBox.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom


        Item {
            id: tokenList
            height: childrenRect.height

            Column {
                id: customTokens
                spacing: Style.current.halfPadding
                visible: { modalBody.customTokenList.count > 0 }

                StyledText {
                    id: customLbl
                    //% "Custom"
                    text: qsTrId("custom")
                    font.pixelSize: 13
                    color: Style.current.secondaryText
                    height: Style.dp(20)
                }

                Repeater {
                    id: customTokensRepeater
                    model: modalBody.customTokenList
                    delegate: tokenComponent
                    anchors.top: customLbl.bottom
                    anchors.topMargin: Style.current.smallPadding
                }
            }

            Column {
                anchors.top: customTokens.bottom
                anchors.topMargin: Style.current.smallPadding
                id: defaultTokens
                spacing: Style.current.halfPadding

                StyledText {
                    id: defaultLbl
                    //% "Default"
                    text: qsTrId("default")
                    font.pixelSize: Style.current.additionalTextSize
                    color: Style.current.secondaryText
                    height: Style.dp(20)
                }

                Repeater {
                    model: modalBody.defaultTokenList
                    delegate: tokenComponent
                    anchors.top: defaultLbl.bottom
                    anchors.topMargin: Style.current.smallPadding
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }
        }
    }
}
