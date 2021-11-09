import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import "../../Chat/popups"

import "."

ListView {
    id: contactList
    property var contacts
    property var store
    property string searchStr: ""
    property string searchString: ""
    property string lowerCaseSearchString: searchString.toLowerCase()
    property string contactToRemove: ""
    property bool hideBlocked: false

    property Component profilePopupComponent: ProfilePopup {
        id: profilePopup
        store: contactList.store
        onClosed: destroy()
    }

    signal contactClicked(var contact)
    signal sendMessageActionTriggered(var contact)
    signal unblockContactActionTriggered(var contact)
    signal blockContactActionTriggered(var contact)
    signal removeContactActionTriggered(var contact)

    width: parent.width

    model: contacts

    delegate: ContactPanel {
        name: Utils.removeStatusEns(model.name)
        address: model.address
        localNickname: model.localNickname
        identicon: model.thumbnailImage || model.identicon
        isContact: model.isContact
        isBlocked: model.isBlocked
        profileClick: function (showFooter, userName, fromAuthor, identicon, textParam, nickName) {
            var popup = profilePopupComponent.createObject(contactList);
            popup.openPopup(showFooter, userName, fromAuthor, identicon, textParam, nickName);
        }
        onClicked: contactList.contactClicked(model)
        onSendMessageActionTriggered: contactList.sendMessageActionTriggered(model)
        onUnblockContactActionTriggered: contactList.unblockContactActionTriggered(model)
        onBlockContactActionTriggered: contactList.blockContactActionTriggered(model)
        onRemoveContactActionTriggered: contactList.removeContactActionTriggered(model)

        visible: {
          if (hideBlocked && model.isBlocked) {
            return false
          }

          return searchString === "" ||
            model.name.toLowerCase().includes(lowerCaseSearchString) ||
            model.address.toLowerCase().includes(lowerCaseSearchString)
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

