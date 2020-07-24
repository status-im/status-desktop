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

    width: parent.width

    model: contacts
    delegate: Contact {
        name: model.name
        address: model.address
        identicon: model.identicon
        isContact: model.isContact
        isBlocked: model.isBlocked
        selectable: contactList.selectable
        profileClick: profilePopup.openPopup.bind(profilePopup)
        visible: searchString === "" ||
                 model.name.toLowerCase().includes(lowerCaseSearchString) ||
                 model.address.toLowerCase().includes(lowerCaseSearchString)
    }

    ProfilePopup {
      id: profilePopup
    }

    ButtonGroup {
        id: contactGroup
    }

}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
