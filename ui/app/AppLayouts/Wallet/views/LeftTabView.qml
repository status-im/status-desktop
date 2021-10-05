import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import "../../../../shared"
import "../controls"
import "../popups"
import "../stores"

Rectangle {    
    id: walletInfoContainer

    property int selectedAccountIndex: 0
    property var changeSelectedAccount: function(){}

    function onAfterAddAccount () {
        walletInfoContainer.changeSelectedAccount(RootStore.accounts.rowCount() - 1)
    }

    color: Style.current.secondaryMenuBackground

    StyledText {
        id: title
        //% "Wallet"
        text: qsTrId("wallet")
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Bold
        font.pixelSize: 17
    }

    Item {
        id: walletValueTextContainer
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: title.bottom
        anchors.topMargin: Style.current.padding
        height: childrenRect.height

        StyledTextEdit {
            id: walletAmountValue
            color: Style.current.textColor
            text: Utils.toLocaleString(RootStore.totalFiatBalance, globalSettings.locale, {"currency": true}) + " " + RootStore.defaultCurrency.toUpperCase()
            selectByMouse: true
            cursorVisible: true
            readOnly: true
            anchors.left: parent.left
            font.weight: Font.Medium
            font.pixelSize: 30
        }

        StyledText {
            id: totalValue
            color: Style.current.secondaryText
            //% "Total value"
            text: qsTrId("wallet-total-value")
            anchors.left: walletAmountValue.left
            anchors.top: walletAmountValue.bottom
            font.weight: Font.Medium
            font.pixelSize: 13
        }

        AddAccountButton {
            id: addAccountButton
            anchors.top: parent.top
            anchors.right: parent.right
            onClicked: {
                if (newAccountMenu.opened) {
                    newAccountMenu.close()
                } else {
                    newAccountMenu.popup(addAccountButton.x + addAccountButton.width/2 - newAccountMenu.width/2 ,
                                         addAccountButton.y + addAccountButton.height + 55)
                }
            }
        }
    }

    AddNewAccountMenu {
        id: newAccountMenu
        onAboutToShow: addAccountButton.state = "pressed"
        onAboutToHide: addAccountButton.state = "default"
    }

    GenerateAccountModal {
        id: generateAccountModal
        onAfterAddAccount: walletInfoContainer.onAfterAddAccount()
    }

    AddAccountWithSeedModal {
        id: addAccountWithSeedModal
        onAfterAddAccount: walletInfoContainer.onAfterAddAccount()
    }

    AddAccountWithPrivateKeyModal {
        id: addAccountWithPrivateKeydModal
        onAfterAddAccount: walletInfoContainer.onAfterAddAccount()
    }

    AddWatchOnlyAccountModal {
        id: addWatchOnlyAccountModal
        onAfterAddAccount: walletInfoContainer.onAfterAddAccount()
    }

    ScrollView {
        anchors.bottom: parent.bottom
        anchors.top: walletValueTextContainer.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        anchors.left: parent.left
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: listView.contentHeight > listView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            id: listView

            spacing: 5
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds

            delegate: WalletDelegate {
                defaultCurrency: RootStore.defaultCurrency
                selectedAccountIndex: walletInfoContainer.selectedAccountIndex
                onClicked: {
                    changeSelectedAccount(index)
                }
            }

            model: RootStore.accounts
//            model: RootStore.exampleWalletModel
        }
    }
}
