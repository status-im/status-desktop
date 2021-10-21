import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0

Item {
    id: modalBody

    property var defaultTokenList
    property var customTokenList
    signal toggleVisibleClicked(string symbol)
    signal removeCustomTokenTriggered(string address)

    SearchBox {
        id: searchBox
        customHeight: 36
        fontPixelSize: 12
        anchors.top: modalBody.top
    }

    Component {
        id: tokenComponent
        Rectangle {
            id: tokenContainer
            property bool hovered: false
            width: modalBody.width
            anchors.topMargin: Style.current.smallPadding
            color: hovered ? Style.current.backgroundHover : "transparent"
            property bool isVisible: symbol && (searchBox.text == "" || name.toLowerCase().includes(searchBox.text.toLowerCase()) || symbol.toLowerCase().includes(searchBox.text.toLowerCase()))

            visible: isVisible
            height: isVisible ? 40 + Style.current.smallPadding : 0
            radius: Style.current.radius

            Image {
                id: assetInfoImage
                width: 36
                height: tokenContainer.isVisible !== "" ? 36 : 0
                source: Style.png("tokens/" + (hasIcon ? symbol : "DEFAULT-TOKEN@3x"))
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
                anchors.verticalCenter: parent.verticalCenter
            }
            StyledText {
                id: assetSymbol
                text: symbol
                anchors.left: assetInfoImage.right
                anchors.leftMargin: Style.current.smallPadding
                anchors.top: assetInfoImage.top
                anchors.topMargin: 0
                font.pixelSize: 15
            }
            StyledText {
                id: assetFullTokenName
                text: name || ""
                anchors.top: assetSymbol.bottom
                anchors.topMargin: 0
                anchors.left: assetInfoImage.right
                anchors.leftMargin: Style.current.smallPadding
                color: Style.current.secondaryText
                font.pixelSize: 15
            }
            StatusCheckBox  {
                id: assetCheck
                checked: model.isVisible
                anchors.right: parent.right
                anchors.rightMargin: Style.current.smallPadding
                onClicked: toggleVisibleClicked(symbol)
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: function (event) {
                    if (event.button === Qt.RightButton) {
                        return contextMenu.popup(assetSymbol.x - 100, assetSymbol.y + 25)
                    }
                    assetCheck.checked = !assetCheck.checked
                    toggleVisibleClicked(symbol)
                }
                onEntered: {
                    tokenContainer.hovered = true
                }
                onExited: {
                    tokenContainer.hovered = false
                }
                // TODO: replace with StatusPopupMenu
                PopupMenu {
                    id: contextMenu
                    Action {
                        icon.source: Style.svg("make-admin")
                        //% "Token details"
                        text: qsTrId("token-details")
                        onTriggered: addCustomTokenModal.openWithData(address, name, symbol, decimals)
                    }
                    Action {
                        icon.source: Style.svg("remove-from-group")
                        icon.color: Style.current.red
                        enabled: isCustom
                        //% "Remove token"
                        text: qsTrId("remove-token")
                        onTriggered: removeCustomTokenTriggered(address)
                    }
                }
            }
        }
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
                    height: 20
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
                    font.pixelSize: 13
                    color: Style.current.secondaryText
                    height: 20
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
