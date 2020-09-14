import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import "../../../../imports"
import "../../../../shared"
import "../../Chat/ContactsColumn"
import "../data/"

Item {
    id: modalBody
    anchors.fill: parent

    SearchBox {
        id: searchBox
        customHeight: 36
        fontPixelSize: 12
        anchors.top: modalBody.top
    }

    Component {
        id: tokenComponent
        Item {
            id: tokenContainer
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            width: 300
            property bool isVisible: symbol && (searchBox.text == "" || name.toLowerCase().includes(searchBox.text.toLowerCase()) || symbol.toLowerCase().includes(searchBox.text.toLowerCase()))

            visible: isVisible
            height: isVisible ? 40 + Style.current.smallPadding : 0

            Image {
                id: assetInfoImage
                width: 36
                height: tokenContainer.isVisible !== "" ? 36 : 0
                anchors.top: parent.top
                anchors.topMargin: 0
                source: hasIcon ? "../../../img/tokens/" + symbol + ".png" : "../../../img/tokens/0-native.png"
                anchors.left: parent.left
                anchors.leftMargin: 0
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
                anchors.bottom: assetInfoImage.bottom
                anchors.bottomMargin: 0
                anchors.left: assetInfoImage.right
                anchors.leftMargin: Style.current.smallPadding
                color: Style.current.darkGrey
                font.pixelSize: 15
                width: 330
            }
            CheckBox  {
                id: assetCheck
                checked: walletModel.hasAsset("0x123", symbol)
                anchors.left: assetFullTokenName.right
                anchors.leftMargin: Style.current.smallPadding
                onClicked: walletModel.toggleAsset(symbol)
            }

            MouseArea {
                acceptedButtons: Qt.RightButton
                anchors.fill: parent
                onClicked: contextMenu.popup(assetSymbol.x - 100, assetSymbol.y + 25)
                PopupMenu {
                    id: contextMenu
                    Action {
                        icon.source: "../../../img/make-admin.svg"
                        //% "Token details"
                        text: qsTrId("token-details")
                        onTriggered: {
                            console.log("TODO")
                        }
                    }
                    Action {
                        icon.source: "../../../img/remove-from-group.svg"
                        icon.color: Style.current.red
                        //% "Remove token"
                        text: qsTrId("remove-token")
                        onTriggered: walletModel.removeCustomToken(address)
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
                    model: walletModel.customTokenList
                    delegate: tokenComponent
                    anchors.top: customLbl.bottom
                    anchors.topMargin: Style.current.smallPadding
                }

                Connections {
                    target: walletModel.customTokenList
                    onTokensLoaded: {
                        customLbl.visible = cnt > 0
                    }
                }
            }

            Column {
                anchors.top: customTokens.bottom
                anchors.topMargin: Style.current.smallPadding
                id: defaultTokens

                StyledText {
                    id: defaultLbl
                    //% "Default"
                    text: qsTrId("default")
                    font.pixelSize: 13
                    color: Style.current.secondaryText
                    height: 20
                }

                Repeater {
                    model: walletModel.defaultTokenList
                    delegate: tokenComponent
                    anchors.top: defaultLbl.bottom
                    anchors.topMargin: Style.current.smallPadding
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
