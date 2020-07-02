import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"

Item {
    property var currentAccount: walletModel.currentAccount
    property var changeSelectedAccount

    id: walletHeader
    height: walletAddress.y + walletAddress.height
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: title
        text: currentAccount.name
        anchors.top: parent.top
        anchors.topMargin: 56
        anchors.left: parent.left
        anchors.leftMargin: 24
        font.weight: Font.Medium
        font.pixelSize: 28
    }

    Rectangle {
        id: separatorDot
        width: 8
        height: 8
        color: Style.current.blue
        anchors.top: title.verticalCenter
        anchors.topMargin: -3
        anchors.left: title.right
        anchors.leftMargin: 8
        radius: 50
    }

    StyledText {
        id: walletBalance
        text: currentAccount.balance
        anchors.left: separatorDot.right
        anchors.leftMargin: 8
        anchors.verticalCenter: title.verticalCenter
        font.pixelSize: 22
    }

    StyledText {
        id: walletAddress
        text: currentAccount.address
        font.family: Style.current.fontHexRegular.name
        elide: Text.ElideMiddle
        anchors.right: title.right
        anchors.rightMargin: 0
        anchors.top: title.bottom
        anchors.topMargin: 0
        anchors.left: title.left
        anchors.leftMargin: 0
        font.pixelSize: 13
        color: Style.current.darkGrey
    }

    SendModal{
        id: sendModal
    }

    SetCurrencyModal{
        id: setCurrencyModal
    }

    TokenSettingsModal{
        id: tokenSettingsModal
    }

    AccountSettingsModal {
        id: accountSettingsModal
        changeSelectedAccount: walletHeader.changeSelectedAccount
    }

    AddCustomTokenModal {
        id: addCustomTokenModal
    }

    Item {
        property int btnMargin: 8
        property int btnOuterMargin: 32
        id: walletMenu
        width: sendBtn.width + receiveBtn.width + settingsBtn.width
               + walletMenu.btnOuterMargin * 2
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16

        Item {
            id: sendBtn
            width: sendImg.width + sendText.width + walletMenu.btnMargin
            height: sendText.height

            SVGImage {
                id: sendImg
                width: 12
                height: 12
                fillMode: Image.PreserveAspectFit
                source: "../../img/diagonalArrow.svg"
            }

            StyledText {
                id: sendText
                text: "Send"
                anchors.left: sendImg.right
                anchors.leftMargin: walletMenu.btnMargin
                font.pixelSize: 13
                color: Style.current.blue
            }
            MouseArea {
                anchors.rightMargin: -Style.current.smallPadding
                anchors.leftMargin: -Style.current.smallPadding
                anchors.bottomMargin: -Style.current.smallPadding
                anchors.topMargin: -Style.current.smallPadding
                anchors.fill: parent
                onClicked: sendModal.open()
                cursorShape: Qt.PointingHandCursor
            }
        }
        Item {
            id: receiveBtn
            width: receiveImg.width + receiveText.width + walletMenu.btnMargin
            anchors.left: sendBtn.right
            anchors.leftMargin: walletMenu.btnOuterMargin

            SVGImage {
                id: receiveImg
                width: 12
                height: 12
                fillMode: Image.PreserveAspectFit
                source: "../../img/diagonalArrow.svg"
                rotation: 180
            }

            StyledText {
                id: receiveText
                text: "Receive"
                anchors.left: receiveImg.right
                anchors.leftMargin: walletMenu.btnMargin
                font.pixelSize: 13
                color: Style.current.blue
            }
        }
        Item {
            id: settingsBtn
            anchors.left: receiveBtn.right
            anchors.leftMargin: walletMenu.btnOuterMargin
            width: settingsImg.width
            height: settingsImg.height
            SVGImage {
                id: settingsImg
                width: 18
                height: 18
                fillMode: Image.PreserveAspectFit
                source: "../../img/settings.svg"
            }

            MouseArea {
                anchors.rightMargin: -Style.current.smallPadding
                anchors.leftMargin: -Style.current.smallPadding
                anchors.bottomMargin: -Style.current.smallPadding
                anchors.topMargin: -Style.current.smallPadding
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    let x = settingsImg.x + settingsImg.width / 2 - newSettingsMenu.width / 2
                    newSettingsMenu.popup(x, settingsImg.height + 10)
                }

                PopupMenu {
                    id: newSettingsMenu
                    width: 280
                    Action {
                        text: qsTr("Account Settings")
                        icon.source: "../../img/walletIcon.svg"
                        onTriggered: {
                            accountSettingsModal.open()
                        }
                    }
                    Action {
                        text: qsTr("Add/Remove Tokens")
                        icon.source: "../../img/add_remove_token.svg"
                        onTriggered: {
                            tokenSettingsModal.open()
                        }
                    }
                    Action {
                        text: qsTr("Set Currency")
                        icon.source: "../../img/set_currency.svg"
                        onTriggered: {
                            setCurrencyModal.open()
                        }
                    }
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
