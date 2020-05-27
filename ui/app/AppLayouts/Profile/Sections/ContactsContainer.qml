import QtQuick 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "../../../../imports"

Item {
    id: contactsContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    Text {
        id: element2
        text: qsTr("Contacts")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    Component {
        id: contactsList

        Item {
            height: 56
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            Column {
                Row {
                    Text {
                        text: name
                        font.weight: Font.Bold
                        font.pixelSize: 14
                    }
                }
                Row {
                    Text {
                        text: address
                        font.weight: Font.Bold
                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    ListView {
        id: contactListView
        anchors.topMargin: 48
        anchors.top: element2.bottom
        anchors.fill: parent
        model: profileModel.contactList
        delegate: contactsList
    }
}