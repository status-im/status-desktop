import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./Contacts"

Item {
    id: contactsContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: element2
        text: qsTr("Contacts")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    ContactList {
        id: contactListView
        contacts: profileModel.contactList
        selectable: false
    }
}

/*##^##
Designer {
    D{i:0;width:600}
}
##^##*/
