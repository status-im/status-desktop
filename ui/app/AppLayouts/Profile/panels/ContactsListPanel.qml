import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.popups 1.0
import "../../Chat/popups"

import "."

ListView {
    id: contactList
    property var contactsModel

    property string searchStr: ""
    property string searchString: ""
    property string lowerCaseSearchString: searchString.toLowerCase()
    property string contactToRemove: ""
    property bool hideBlocked: false

    signal contactClicked(var contact)
    signal openProfilePopup(var contact)
    signal sendMessageActionTriggered(var contact)
    signal unblockContactActionTriggered(var contact)
    signal blockContactActionTriggered(var contact)
    signal removeContactActionTriggered(var contact)

    width: parent.width

    model: contactList.contactsModel

    delegate: ContactPanel {
        id: panelDelegate
        name: model.name
        publicKey: model.pubKey
        icon: model.icon
        isIdenticon: model.isIdenticon
        isContact: model.isContact
        isBlocked: model.isBlocked

        onClicked: contactList.contactClicked(model)
        onOpenProfilePopup: contactList.openProfilePopup(model)
        onSendMessageActionTriggered: contactList.sendMessageActionTriggered(model)
        onUnblockContactActionTriggered: contactList.unblockContactActionTriggered(model)
        onBlockContactActionTriggered: contactList.blockContactActionTriggered(model)
        onRemoveContactActionTriggered: contactList.removeContactActionTriggered(model)

        visible: {
          if (hideBlocked && model.isBlocked) {
            return false
          }

          return searchString === "" ||
            panelDelegate.name.toLowerCase().includes(lowerCaseSearchString) ||
            panelDelegate.publicKey.toLowerCase().includes(lowerCaseSearchString)
        }
    }
}
