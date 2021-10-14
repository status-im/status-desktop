import QtQuick 2.13
import QtQuick.Controls 2.13

import "../../../../shared"
import "../../../../shared/popups"

import utils 1.0

// TODO: replace with StatusPopupMenu
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
}
