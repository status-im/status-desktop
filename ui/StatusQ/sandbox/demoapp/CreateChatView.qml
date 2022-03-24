import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Page {
    id: root
    anchors.fill: parent
    anchors.margins: 16
    property ListModel contactsModel: null
    background: null

    header: RowLayout {
        id: headerRow
        width: parent.width
        height: tagSelector.height
        anchors.right: parent.right
        anchors.rightMargin: 8

        StatusTagSelector {
            id: tagSelector
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 17
            maxHeight: root.height
            toLabelText: qsTr("To: ")
            warningText: qsTr("USER LIMIT REACHED")
            listLabel: qsTr("Contacts")
            onTextChanged: {
                sortModel(root.contactsModel);
            }
            Component.onCompleted: { sortModel(root.contactsModel); }
        }

        StatusButton {
            implicitHeight: 44
            Layout.alignment: Qt.AlignTop
            enabled: (tagSelector.namesModel.count > 0)
            text: "Confirm"
        }
    }

    contentItem: Item {
        anchors.fill: parent
        anchors.topMargin: 68

        StatusBaseText {
            visible: (contactsModel.count === 0)
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("You can only send direct messages to your Contacts. \n\n
Send a contact request to the person you would like to chat with, you will be\n able to
chat with them once they have accepted your contact request.")
            Component.onCompleted: {
                if (visible) {
                    tagSelector.enabled = false;
                }
            }
        }
    }
}
