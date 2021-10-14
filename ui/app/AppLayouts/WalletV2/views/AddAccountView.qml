import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Controls 0.1
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"

import utils 1.0

import "../popups"

StatusFlatButton {
    id: btnAdd
    width: 138
    height: 38
    size: StatusBaseButton.Size.Small
    text: qsTr("Add account")
    icon.name: "add"
    icon.width: 14
    icon.height: 14
    property var store

    onClicked: {
        if (newAccountMenu.opened) {
            newAccountMenu.close();
        } else {
            newAccountMenu.popup(0, btnAdd.height + 4);
        }
    }

    // TODO: replace with StatusPopupMenu
    PopupMenu {
        id: newAccountMenu
        width: 260
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        Action {
            icon.width: 19
            icon.height: 19
            icon.source: Style.svg("generate_account")
            text: qsTrId("generate-a-new-account")
            onTriggered: { console.log("TODO"); }
        }
        Action {
            icon.width: 19
            icon.height: 19
            icon.source: Style.svg("eye")
            text: qsTrId("add-a-watch-account")
            onTriggered: { console.log("TODO"); }
        }
        Action {
            text: qsTr("Add with key or seed phrase")
            icon.source: Style.svg("enter_private_key")
            icon.width: 19
            icon.height: 19
            onTriggered: {
                addAccountPopupLoader.active = !addAccountPopupLoader.active;
            }
        }
        onAboutToShow: {
            btnAdd.state = "pressed";
        }

        onAboutToHide: {
            btnAdd.state = "default";
        }
    }

    Loader {
        id: addAccountPopupLoader
        active: false
        sourceComponent: AddAccountPopup {
            id: addAccountPopup
            anchors.centerIn: parent
            store: btnAdd.store
            onAddAccountClicked: {
                btnAdd.store.afterAddAccount();
            }
            onClosed: {
                addAccountPopupLoader.active = false;
            }
        }
        onLoaded: {
            if (status === Loader.Ready) {
                item.open();
            }
        }
    }
}
