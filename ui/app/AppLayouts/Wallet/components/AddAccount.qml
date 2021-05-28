import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"

StatusRoundButton {
    id: btnAdd
    icon.name: "plusSign"
    pressedIconRotation: 45
    size: "medium"
    type: "secondary"
    width: 36
    height: 36

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
    }
    AddAccountWithSeed {
        id: addAccountWithSeedModal
    }
    AddAccountWithPrivateKey {
        id: addAccountWithPrivateKeydModal
    }
    AddWatchOnlyAccount {
        id: addWatchOnlyAccountModal
    }

    PopupMenu {
        id: newAccountMenu
        width: 260
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        Action {
            //% "Generate an account"
            text: qsTrId("generate-a-new-account")
            icon.source: "../../../img/generate_account.svg"
            icon.width: 19
            icon.height: 19
            onTriggered: {
                generateAccountModal.open()
            }
        }
        Action {
            //% "Add a watch-only address"
            text: qsTrId("add-a-watch-account")
            icon.source: "../../../img/eye.svg"
            icon.width: 19
            icon.height: 19
            onTriggered: {
                addWatchOnlyAccountModal.open()
            }
        }
        Action {
            //% "Enter a seed phrase"
            text: qsTrId("enter-a-seed-phrase")
            icon.source: "../../../img/enter_seed_phrase.svg"
            icon.width: 19
            icon.height: 19
            onTriggered: {
                addAccountWithSeedModal.open()
            }
        }
        Action {
            //% "Enter a private key"
            text: qsTrId("enter-a-private-key")
            icon.source: "../../../img/enter_private_key.svg"
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
