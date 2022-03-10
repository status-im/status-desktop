import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import shared.popups 1.0
import shared.panels 1.0
import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    property var currentAccount: RootStore.currentAccount
    property var changeSelectedAccount
    property var emojiPopup

    //% "Status account settings"
    header.title: qsTrId("status-account-settings")
    height: 675

    property int marginBetweenInputs: 30

    onOpened: {
        accountNameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Connections {
        enabled: popup.opened
        target: emojiPopup
        onEmojiSelected: function (emojiText, atCursor) {
            popup.contentItem.accountNameInput.input.icon.emoji = emojiText
        }
    }


    contentItem: Column {
        property alias accountNameInput: accountNameInput

        width: popup.width
        spacing: marginBetweenInputs
        topPadding: Style.current.padding

        StatusInput {
            id: accountNameInput
            //% "Enter an account name..."
            input.placeholderText: qsTrId("enter-an-account-name...")
            input.text: currentAccount.name
            //% "Account name"
            label: qsTrId("account-name")
            input.isIconSelectable: true
            input.icon.emoji: currentAccount.emoji
            input.icon.color: currentAccount.color
            input.icon.name: !currentAccount.emoji ? "filled-account": ""
            onIconClicked: {
                popup.emojiPopup.open()
                popup.emojiPopup.x = popup.x + accountNameInput.x + Style.current.padding
                popup.emojiPopup.y = popup.y + contentItem.y + accountNameInput.y + accountNameInput.height +  Style.current.halfPadding
            }
            validators: [
                StatusMinLengthValidator {
                    //% "You need to enter an account name"
                    errorMessage: qsTrId("you-need-to-enter-an-account-name")
                    minLength: 1
                }
            ]
        }

        StatusColorSelectorGrid {
            id: accountColorInput
            anchors.top: selectedColor.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            //% "color"
            titleText: qsTr("color").toUpperCase()
            selectedColor: currentAccount.color
            selectedColorIndex: {
                for (let i = 0; i < model.length; i++) {
                    if(model[i] === currentAccount.color)
                        return i
                }
            }
            onSelectedColorChanged: {
                if(selectedColor !== currentAccount.color) {
                    accountNameInput.input.icon.color = selectedColor
                }

            }
        }

        Column {
            width: parent.width
            leftPadding: Style.current.padding
            spacing: Style.current.padding

            TextWithLabel {
                id: typeText
                //% "Type"
                label: qsTrId("type")
                text: {
                    var result = ""
                    switch (currentAccount.walletType) {
                        //% "Watch-only"
                    case Constants.watchWalletType: result = qsTrId("watch-only"); break;
                    case Constants.keyWalletType:
                        //% "Off Status tree"
                    case Constants.seedWalletType: result = qsTrId("off-status-tree"); break;
                        //% "On Status tree"
                    default: result = qsTrId("on-status-tree")
                    }
                    return result
                }
            }

            TextWithLabel {
                id: addressText
                //% "Wallet address"
                label: qsTrId("wallet-address")
                text: currentAccount.address
                fontFamily: Style.current.fontHexRegular.name
            }

            TextWithLabel {
                id: pathText
                visible: currentAccount.walletType !== Constants.watchWalletType && currentAccount.walletType !== Constants.keyWalletType
                //% "Derivation path"
                label: qsTrId("derivation-path")
                text: currentAccount.path
            }

            TextWithLabel {
                id: storageText
                visible: currentAccount.walletType !== Constants.watchWalletType
                //% "Storage"
                label: qsTrId("storage")
                //% "This device"
                text: qsTrId("this-device")
            }
        }
    }

    rightButtons: [
        StatusButton {
            visible:  currentAccount.walletType === Constants.watchWalletType
            //% "Delete account"
            text: qsTrId("delete-account")
            type: StatusBaseButton.Type.Danger

            MessageDialog {
                id: deleteError
                title: "Deleting account failed"
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok

            }

            MessageDialog {
                id: confirmationDialog
                //% "Are you sure?"
                title: qsTrId("are-you-sure?")
                //% "A deleted account cannot be retrieved later. Only press yes if you backed up your key/seed or don't care about this account anymore"
                text: qsTrId("a-deleted-account-cannot-be-retrieved-later.-only-press-yes-if-you-backed-up-your-key/seed-or-don't-care-about-this-account-anymore")
                icon: StandardIcon.Warning
                standardButtons: StandardButton.Yes |  StandardButton.No
                onYes: {
                    RootStore.deleteAccount(currentAccount.address)
                    // Change active account to the first
                    changeSelectedAccount(0)
                    popup.close();
                }
            }

            onClicked : {
                confirmationDialog.open()
            }
        },
        StatusButton {
            id: saveBtn
            //% "Save changes"
            text: qsTrId("save-changes")

            enabled: accountNameInput.text !== ""

            MessageDialog {
                id: changeError
                title: qsTr("Changing settings failed")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }

            onClicked : {                
                if (!accountNameInput.valid) {
                     return
                 }

                const error = RootStore.updateCurrentAccount(currentAccount.address, accountNameInput.text, accountColorInput.selectedColor, accountNameInput.input.icon.emoji);

                if (error) {
                    Global.playErrorSound();
                    changeError.text = error
                    changeError.open()
                    return
                }
                popup.close();
            }
        }
    ]
}
