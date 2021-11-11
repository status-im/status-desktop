import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import "../popups"
import "../controls"
import "../stores"

Item {
    id: walletHeader

    property string currency: ""
    property var currentAccount
    property var changeSelectedAccount

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
        color: Style.current.primary
        anchors.top: title.verticalCenter
        anchors.topMargin: -3
        anchors.left: title.right
        anchors.leftMargin: 8
        radius: 50
    }

    StyledText {
        id: walletBalance
        text: {
            Utils.toLocaleString(currentAccount.currencyBalance.toFixed(2), localAppSettings.locale, {"currency": true}) + " " + walletHeader.currency.toUpperCase()
        }
        anchors.left: separatorDot.right
        anchors.leftMargin: 8
        anchors.verticalCenter: title.verticalCenter
        font.pixelSize: 22
    }

    StatusExpandableAddress {
        id: walletAddress
        address: currentAccount.address
        anchors.top: title.bottom
        anchors.left: title.left
        addressWidth: 180
        anchors.leftMargin: 0
        anchors.topMargin: 0
    }

    Component {
        id: receiveModalComponent
        ReceiveModal {
            onClosed: {
                destroy();
            }
            selectedAccount: RootStore.currentAccount
        }
    }

    Component {
        id: setCurrencyModalComponent
        SetCurrencyModal {
            onClosed: {
                destroy();
            }
        }
    }

    Component {
        id: tokenSettingsModalComponent
        TokenSettingsModal {
            onClosed: {
                destroy();
            }
        }
    }

    Component {
        id: accountSettingsModalComponent
        AccountSettingsModal {
            onClosed: destroy()
            changeSelectedAccount: walletHeader.changeSelectedAccount
        }
    }

    AddCustomTokenModal{
        id: addCustomTokenModal
    }

    Item {
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
            imageSource: Style.svg("send")
            //% "Send"
            text: qsTrId("command-button-send")
            onClicked: function() {
                sendModal.open()
            }
        }

        HeaderButton {
            id: receiveBtn
            imageSource: Style.svg("send")
            flipImage: true
            //% "Receive"
            text: qsTrId("receive")
            onClicked: function () {
                openPopup(receiveModalComponent);
            }
            anchors.left: sendBtn.right
            anchors.leftMargin: walletMenu.btnOuterMargin
        }

        HeaderButton {
            id: settingsBtn
            imageSource: Style.svg("settings")
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

            // TODO: replace with StatusPopupMenu
            PopupMenu {
                id: newSettingsMenu
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                width: 176
                Action {
                    //% "Account Settings"
                    text: qsTrId("account-settings")
                    icon.source: Style.svg("manage-wallet")
                    icon.width: 16
                    icon.height: 16
                    onTriggered: openPopup(accountSettingsModalComponent)
                }
                Action {
                    //% "Manage Assets"
                    text: qsTrId("manage-assets")
                    icon.source: Style.svg("add_remove_token")
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        openPopup(tokenSettingsModalComponent)
                    }
                }
                Action {
                    //% "Set Currency"
                    text: qsTrId("set-currency")
                    icon.source: Style.svg("currency")
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        openPopup(setCurrencyModalComponent)
                    }
                }
            }
        }
    }
}
