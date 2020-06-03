import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import "../../../imports"
import "../../../shared"

Item {
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

    Text {
        id: title
        // TODO this should be the name of the wallet
        text: qsTr("Status account")
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
        color: Theme.blue
        anchors.top: title.verticalCenter
        anchors.topMargin: -3
        anchors.left: title.right
        anchors.leftMargin: 8
        radius: 50
    }

    Text {
        id: walletBalance
        // TODO this should be the balance
        text: qsTr("12.00 USD")
        anchors.left: separatorDot.right
        anchors.leftMargin: 8
        anchors.verticalCenter: title.verticalCenter
        font.pixelSize: 22
    }

    Text {
        id: walletAddress
        // TODO this should be the address and an actual Address component that can shrink and expend
        text: qsTr("0X2Ef1...E0Ba")
        anchors.top: title.bottom
        anchors.topMargin: 0
        anchors.left: title.left
        anchors.leftMargin: 0
        font.pixelSize: 13
        color: Theme.darkGrey
    }

    SendModal{
        id: sendModal
    }

    SettingsModal{
        id: settingsModal
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

            Image {
                id: sendImg
                width: 12
                height: 12
                fillMode: Image.PreserveAspectFit
                source: "../../img/diagonalArrow.svg"
            }

            Text {
                id: sendText
                text: "Send"
                anchors.left: sendImg.right
                anchors.leftMargin: walletMenu.btnMargin
                font.pixelSize: 13
                color: Theme.blue
            }
            MouseArea {
                anchors.rightMargin: -Theme.smallPadding
                anchors.leftMargin: -Theme.smallPadding
                anchors.bottomMargin: -Theme.smallPadding
                anchors.topMargin: -Theme.smallPadding
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

            Image {
                id: receiveImg
                width: 12
                height: 12
                fillMode: Image.PreserveAspectFit
                source: "../../img/diagonalArrow.svg"
                rotation: 180
            }

            Text {
                id: receiveText
                text: "Receive"
                anchors.left: receiveImg.right
                anchors.leftMargin: walletMenu.btnMargin
                font.pixelSize: 13
                color: Theme.blue
            }
        }
        Item {
            id: settingsBtn
            anchors.left: receiveBtn.right
            anchors.leftMargin: walletMenu.btnOuterMargin
            width: settingsImg.width
            Image {
                id: settingsImg
                width: 18
                height: 18
                fillMode: Image.PreserveAspectFit
                source: "../../img/settings.svg"
            }

            MouseArea {
                anchors.rightMargin: -Theme.smallPadding
                anchors.leftMargin: -Theme.smallPadding
                anchors.bottomMargin: -Theme.smallPadding
                anchors.topMargin: -Theme.smallPadding
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
                    QQC2.Action {
                        text: qsTr("Account Settings")
                        icon.source: "../../img/account_settings.svg"
                        onTriggered: {
                            console.log("TODO: AccountSettings")
                        }
                    }
                    QQC2.Action {
                        text: qsTr("Add/Remove Tokens")
                        icon.source: "../../img/add_remove_token.svg"
                        onTriggered: {
                            console.log("TODO: Add/Remove Tokens")
                        }
                    }
                    QQC2.Action {
                        text: qsTr("Set Currency")
                        icon.source: "../../img/set_currency.svg"
                        onTriggered: {
                            settingsModal.open()
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
