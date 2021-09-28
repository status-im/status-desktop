import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../shared"
import "../../../../shared/status"

import utils 1.0

StatusRoundButton {
    id: btnAdd
    icon.name: "plusSign"
    pressedIconRotation: 45
    size: "medium"
    type: "secondary"
    width: 36
    height: 36
    readonly property var onAfterAddAccount: function() {
        walletInfoContainer.changeSelectedAccount(walletModel.accountsView.accounts.rowCount() - 1)
    }

    onClicked: {
        if (newAccountMenu.opened) {
            newAccountMenu.close()
        } else {
            let x = btnAdd.iconX + btnAdd.icon.width / 2 - newAccountMenu.width / 2
            newAccountMenu.popup(x, btnAdd.height + 4)
        }
    }

    GenerateAccountModal {
        id: generateAccountModal
        onAfterAddAccount: function() { btnAdd.onAfterAddAccount() }
    }
    AddAccountWithSeed {
        id: addAccountWithSeedModal
        onAfterAddAccount: function() { btnAdd.onAfterAddAccount() }
    }
    AddAccountWithPrivateKey {
        id: addAccountWithPrivateKeydModal
        onAfterAddAccount: function() { btnAdd.onAfterAddAccount() }
    }
    AddWatchOnlyAccount {
        id: addWatchOnlyAccountModal
        onAfterAddAccount: function() { btnAdd.onAfterAddAccount() }
    }

    PopupMenu {
        id: newAccountMenu
        width: 260
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        Action {
            //% "Generate an account"
            text: qsTrId("generate-a-new-account")
            icon.source: Style.svg("generate_account")
            icon.width: 19
            icon.height: 19
            onTriggered: {
                generateAccountModal.open()
            }
        }
        Action {
            //% "Add a watch-only address"
            text: qsTrId("add-a-watch-account")
            icon.source: Style.svg("eye")
            icon.width: 19
            icon.height: 19
            onTriggered: {
                addWatchOnlyAccountModal.open()
            }
        }
        Action {
            //% "Enter a seed phrase"
            text: qsTrId("enter-a-seed-phrase")
            icon.source: Style.svg("enter_seed_phrase")
            icon.width: 19
            icon.height: 19
            onTriggered: {
                addAccountWithSeedModal.open()
            }
        }
        Action {
            //% "Enter a private key"
            text: qsTrId("enter-a-private-key")
            icon.source: Style.svg("enter_private_key")
            icon.width: 19
            icon.height: 19
            onTriggered: {
                addAccountWithPrivateKeydModal.open()
            }
        }
        onAboutToShow: {
            btnAdd.state = "pressed"
        }

        onAboutToHide: {
            btnAdd.state = "default"
        }
    }
}

/*##^##
Designer {
    D{i:0;height:36;width:36}
}
##^##*/
