import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./components"

Item {
    property var currentAccount: walletV2Model.accountsView.currentAccount
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

    Row {
        id: accountRow
        anchors.top: parent.top
        anchors.topMargin: 56
        anchors.left: parent.left
        anchors.leftMargin: 24

        spacing: 8

        StyledText {
            id: title
            anchors.verticalCenter: parent.verticalCenter
            text: currentAccount.name
            font.weight: Font.Medium
            font.pixelSize: 28
        }

        Rectangle {
            id: separatorDot
            width: 8
            height: 8
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            color: Style.current.primary
            radius: 50
        }

        StyledText {
            id: walletBalance
            anchors.verticalCenter: parent.verticalCenter
            text: currentAccount.balance.toUpperCase()
            font.pixelSize: 22
        }
    }

    MouseArea {
        anchors.fill: accountRow
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            openPopup(shareModalComponent);
        }
    }

    StatusExpandableAddress {
        id: walletAddress
        address: currentAccount.address
        anchors.top: accountRow.bottom
        anchors.left: accountRow.left
        addressWidth: 180
        anchors.leftMargin: 0
        anchors.topMargin: 0
    }

    Item {
        property int btnMargin: 8
        property int btnOuterMargin: Style.current.bigPadding
        id: walletMenu
        width: sendBtn.width + receiveBtn.width + settingsBtn.width
               + walletMenu.btnOuterMargin * 2
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16

        HeaderButton {
            id: sendBtn
            imageSource: "../../img/send.svg"
            //% "Send"
            text: qsTrId("command-button-send")
            onClicked: () => console.log("TODO");
        }

        HeaderButton {
            id: receiveBtn
            imageSource: "../../img/send.svg"
            flipImage: true
            //% "Receive"
            text: qsTrId("receive")
            onClicked: () => console.log("TODO")
            anchors.left: sendBtn.right
            anchors.leftMargin: walletMenu.btnOuterMargin
        }

        HeaderButton {
            id: settingsBtn
            imageSource: "../../img/settings.svg"
            flipImage: true
            text: ""
            onClicked: function () {
                if (newSettingsMenu.opened) {
                    newSettingsMenu.close()
                } else {
                    let x = settingsBtn.x + settingsBtn.width / 2 - newSettingsMenu.width / 2
                    newSettingsMenu.popup(x, settingsBtn.height)
                }
            }
            anchors.left: receiveBtn.right
            anchors.leftMargin: walletMenu.btnOuterMargin

            PopupMenu {
                id: newSettingsMenu
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                width: 176
                Action {
                    //% "Account Settings"
                    text: qsTrId("account-settings")
                    icon.source: "../../img/manage-wallet.svg"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: console.log("TODO")
                }
                Action {
                    //% "Manage Assets"
                    text: qsTrId("manage-assets")
                    icon.source: "../../img/add_remove_token.svg"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: console.log("TODO")
                }
                Action {
                    //% "Set Currency"
                    text: qsTrId("set-currency")
                    icon.source: "../../img/currency.svg"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: console.log("TODO")
                }
            }
        }
    }

    Component {
        id: shareModalComponent
        ShareModal {
            onClosed: {
                destroy();
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
