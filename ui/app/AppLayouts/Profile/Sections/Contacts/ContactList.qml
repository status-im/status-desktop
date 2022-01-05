import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "./samples/"

import utils 1.0
import shared 1.0
import shared.popups 1.0
import "../../../Chat/popups"
import "."

ListView {
    id: contactList
    property var contacts: ContactsData {}
    property string searchStr: ""
    property string searchString: ""
    property string lowerCaseSearchString: searchString.toLowerCase()
    property string contactToRemove: ""
    property bool hideBlocked: false

    width: parent.width

    model: contacts

    delegate: Contact {
        name: Utils.removeStatusEns(model.name)
        address: model.address
        localNickname: model.localNickname
        identicon: model.thumbnailImage || model.identicon
        isContact: model.isContact
        isBlocked: model.isBlocked
        profileClick: function (showFooter, userName, fromAuthor, identicon, textParam, nickName) {
            Global.openProfilePopup(fromAuthor)
        }
        visible: {
          if (hideBlocked && model.isBlocked) {
            return false
          }

          return searchString === "" ||
            model.name.toLowerCase().includes(lowerCaseSearchString) ||
            model.address.toLowerCase().includes(lowerCaseSearchString)
        }
        onBlockContactActionTriggered: {
            blockContactConfirmationDialog.contactName = name
            blockContactConfirmationDialog.contactAddress = address
            blockContactConfirmationDialog.open()
        }
        onRemoveContactActionTriggered: {
            removeContactConfirmationDialog.value = address
            removeContactConfirmationDialog.open()
        }
    }

    // TODO: Make BlockContactConfirmationDialog a dynamic component on a future refactor
    BlockContactConfirmationDialog {
        id: blockContactConfirmationDialog
        onBlockButtonClicked: {
            // TODO use a store once it is available
            contactsModule.blockContact(blockContactConfirmationDialog.contactAddress)
            blockContactConfirmationDialog.close()
        }
    }

    // TODO: Make ConfirmationDialog a dynamic component on a future refactor
    ConfirmationDialog {
        id: removeContactConfirmationDialog
        //% "Remove contact"
        header.title: qsTrId("remove-contact")
        //% "Are you sure you want to remove this contact?"
        confirmationText: qsTrId("are-you-sure-you-want-to-remove-this-contact-")
        onConfirmButtonClicked: {
            // TODO use a store once it is available
            if (contactsModule.model.isAdded(removeContactConfirmationDialog.value)) {
              contactsModule.removeContact(removeContactConfirmationDialog.value);
            }
            removeContactConfirmationDialog.close()
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
