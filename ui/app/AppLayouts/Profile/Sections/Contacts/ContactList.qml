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
    property alias selectedContact: contactGroup.checkedButton

    anchors.topMargin: 48
    anchors.top: element2.bottom
    anchors.fill: parent

    model: contacts
    delegate: Contact {
        name: model.name
        address: model.address
        identicon: model.identicon
        isContact: model.isContact
        selectable: contactList.selectable
        profileClick: profilePopup.openPopup.bind(profilePopup)
        ensVerified: model.ensVerified
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
