import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "./components"

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
        color: currentAccount.iconColor
        anchors.top: title.verticalCenter
        anchors.topMargin: -3
        anchors.left: title.right
        anchors.leftMargin: 8
        radius: 50
    }

    StyledText {
        id: walletBalance
        text: currentAccount.balance.toUpperCase()
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
        ReceiveModal{
            onClosed: {
                destroy();
            }
            selectedAccount: currentAccount
        }
    }

    Component {
        id: setCurrencyModalComponent
        SetCurrencyModal{
            onClosed: {
                destroy();
            }
        }
    }

    Component {
        id: tokenSettingsModalComponent
        TokenSettingsModal{
            onClosed: {
                destroy();
            }
        }
    }

    Component {
        id: accountSettingsModalComponent
        AccountSettingsModal{
            onClosed: {
                destroy();
            }
            changeSelectedAccount: walletHeader.changeSelectedAccount
        }
    }

    AddCustomTokenModal{
        id: addCustomTokenModal
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
            onClicked: function() {
                sendModal.open()
            }
        }

        HeaderButton {
            id: receiveBtn
            imageSource: "../../img/send.svg"
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
            imageSource: "../../img/settings.svg"
            flipImage: true
            text: ""
            onClicked: function () {
                // FIXME the button is too much on the right, so the arrow can never align
                let x = settingsBtn.x + settingsBtn.width / 2 - newSettingsMenu.width / 2
                newSettingsMenu.popup(x, settingsBtn.height)
            }
            anchors.left: receiveBtn.right
            anchors.leftMargin: walletMenu.btnOuterMargin

            PopupMenu {
                id: newSettingsMenu
                width: 176
                Action {
                    //% "Account Settings"
                    text: qsTrId("account-settings")
                    icon.source: "../../img/manage-wallet.svg"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: openPopup(accountSettingsModalComponent)
                }
                Action {
                    text: qsTr("Manage Assets")
                    icon.source: "../../img/add_remove_token.svg"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        openPopup(tokenSettingsModalComponent)
                        walletModel.loadCustomTokens()
                    }
                }
                Action {
                    //% "Set Currency"
                    text: qsTrId("set-currency")
                    icon.source: "../../img/currency.svg"
                    icon.width: 16
                    icon.height: 16
                    onTriggered: {
                        openPopup(setCurrencyModalComponent, { 
                            defaultCurrency: walletModel.defaultCurrency
                        })
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
