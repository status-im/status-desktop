import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "./samples/"
import "../../../../../imports"
import "../../../../../shared"
import "../../../Chat/components"
import "."

ListView {
    id: contactList
    property var contacts: ContactsData {}
    property var selectable: true
    property string searchStr: ""
    property alias selectedContact: contactGroup.checkedButton
    property string searchString: ""
    property string lowerCaseSearchString: searchString.toLowerCase()
    property string contactToRemove: ""

    width: parent.width

    model: contacts
    delegate: Contact {
        name: Utils.removeStatusEns(model.name)
        address: model.address
        localNickname: model.localNickname
        identicon: model.identicon
        isContact: model.isContact
        isBlocked: model.isBlocked
        selectable: contactList.selectable
        profileClick: profilePopup.openPopup.bind(profilePopup)
        visible: searchString === "" ||
                 model.name.toLowerCase().includes(lowerCaseSearchString) ||
                 model.address.toLowerCase().includes(lowerCaseSearchString)
        onBlockContactActionTriggered: {
            blockContactConfirmationDialog.contactName = name
            blockContactConfirmationDialog.contactAddress = address
            blockContactConfirmationDialog.open()
        }
        onRemoveContactActionTriggered: {
            contactList.contactToRemove = address
            removeContactConfirmationDialog.open()
        }
    }

    ProfilePopup {
      id: profilePopup
      onBlockButtonClicked: {
          blockContactConfirmationDialog.contactName = name
          blockContactConfirmationDialog.contactAddress = address
          blockContactConfirmationDialog.open()
      }
      onRemoveButtonClicked: {
          contactList.contactToRemove = address
          removeContactConfirmationDialog.open()
      }
    }

    ButtonGroup {
        id: contactGroup
    }

    BlockContactConfirmationDialog {
        id: blockContactConfirmationDialog
        onBlockButtonClicked: {
            profileModel.blockContact(blockContactConfirmationDialog.contactAddress)
            blockContactConfirmationDialog.close()
        }
    }

    ConfirmationDialog {
        id: removeContactConfirmationDialog
        title: qsTrId("remove-contact")
        //% "Are you sure you want to remove this contact?"
        confirmationText: qsTrId("are-you-sure-you-want-to-remove-this-contact-")
        onConfirmButtonClicked: {
            if (profileModel.isAdded(contactList.contactToRemove)) {
              profileModel.removeContact(contactList.contactToRemove)
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
