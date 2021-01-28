import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../imports"
import "../../../shared"
import "../../../shared/status"

ModalPopup {
    property var currentAccount: walletModel.currentAccount
    property var changeSelectedAccount
    id: popup
    // TODO add icon when we have that feature
    //% "Status account settings"
    title: qsTrId("status-account-settings")
    height: 675

    property int marginBetweenInputs: 35
    property string accountNameValidationError: ""

    function validate() {
        if (accountNameInput.text === "") {
            //% "You need to enter an account name"
            accountNameValidationError = qsTrId("you-need-to-enter-an-account-name")
        } else {
            accountNameValidationError = ""
        }

        return accountNameValidationError === ""
    }

    onOpened: {
        accountNameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: accountNameInput
        //% "Enter an account name..."
        placeholderText: qsTrId("enter-an-account-name...")
        //% "Account name"
        label: qsTrId("account-name")
        text: currentAccount.name
        validationError: popup.accountNameValidationError
    }

    StatusWalletColorSelect {
        id: accountColorInput
        selectedColor: currentAccount.iconColor.toUpperCase()
        model: Constants.accountColors
        anchors.top: accountNameInput.bottom
        anchors.topMargin: marginBetweenInputs
        anchors.left: parent.left
        anchors.right: parent.right
    }

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
        anchors.top: accountColorInput.bottom
        anchors.topMargin: marginBetweenInputs
    }

    TextWithLabel {
        id: addressText
        //% "Wallet address"
        label: qsTrId("wallet-address")
        text: currentAccount.address
        fontFamily: Style.current.fontHexRegular.name
        anchors.top: typeText.bottom
        anchors.topMargin: marginBetweenInputs
    }

    TextWithLabel {
        id: pathText
        visible: currentAccount.walletType !== Constants.watchWalletType && currentAccount.walletType !== Constants.keyWalletType
        //% "Derivation path"
        label: qsTrId("derivation-path")
        text: currentAccount.path
        anchors.top: addressText.bottom
        anchors.topMargin: marginBetweenInputs
    }

    TextWithLabel {
        id: storageText
        visible: currentAccount.walletType !== Constants.watchWalletType
        //% "Storage"
        label: qsTrId("storage")
        //% "This device"
        text: qsTrId("this-device")
        anchors.top: pathText.bottom
        anchors.topMargin: marginBetweenInputs
    }

    footer: Item {
        width: parent.width
        height: saveBtn.height

        StatusButton {
            visible:  currentAccount.walletType === Constants.watchWalletType
            anchors.top: parent.top
            anchors.right: saveBtn.left
            anchors.rightMargin: Style.current.padding
            //% "Delete account"
            text: qsTrId("delete-account")
            bgColor: "transparent"
            showBorder: true
            borderColor: Style.current.border
            hoveredBorderColor: Style.current.transparent
            type: "warn"

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
                onAccepted: {
                    const error = walletModel.deleteAccount(currentAccount.address);
                    if (error) {
                        errorSound.play()
                        deleteError.text = error
                        deleteError.open()
                        return
                    }

                    // Change active account to the first
                    changeSelectedAccount(0)
                    popup.close();
                }
            }

            onClicked : {
                confirmationDialog.open()
            }
        }
        StatusButton {
            id: saveBtn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            //% "Save changes"
            text: qsTrId("save-changes")

            enabled: accountNameInput.text !== ""

            MessageDialog {
                id: changeError
                title: "Changing settings failed"
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }

            onClicked : {
                if (!validate()) {
                    return
                }

                const error = walletModel.changeAccountSettings(currentAccount.address, accountNameInput.text, accountColorInput.selectedColor);

                if (error) {
                    errorSound.play()
                    changeError.text = error
                    changeError.open()
                    return
                }
                popup.close();
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
