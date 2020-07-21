import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../Chat/components"
import "./Contacts"

Item {
    id: contactsContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    Item {
        anchors.top: parent.top
        anchors.topMargin: 32
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        anchors.bottom: parent.bottom

        SearchBox {
            id: searchBox
        }

        Item {
            id: addNewContact
            anchors.top: searchBox.bottom
            anchors.topMargin: Style.current.bigPadding
            width: parent.width
            height: addButton.height

            AddButton {
                id: addButton
                clickable: false
                anchors.verticalCenter: parent.verticalCenter
            }
            StyledText {
                id: usernameText
                text: qsTr("Add new contact")
                color: Style.current.blue
                anchors.left: addButton.right
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: addButton.verticalCenter
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // TODO implement adding a contact
                    console.log('Add a contact')
                }
            }
        }

        ContactList {
            id: contactListView
            anchors.top: addNewContact.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.bottom: parent.bottom
            contacts: profileModel.contactList
            selectable: false
            searchString: searchBox.text
        }

        Item {
            id: element
            visible: profileModel.contactList.rowCount() === 0
            anchors.fill: parent

            StyledText {
                id: noFriendsText
                text: qsTr("You don’t have any contacts yet")
                anchors.verticalCenterOffset: -Style.current.bigPadding
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                color: Style.current.darkGrey
            }

            StyledButton {
                anchors.horizontalCenter: noFriendsText.horizontalCenter
                anchors.top: noFriendsText.bottom
                anchors.topMargin: Style.current.bigPadding
                label: qsTr("Invite firends")
                onClicked: function () {
                    inviteFriendsPopup.open()
                }
            }

            InviteFriendsPopup {
                id: inviteFriendsPopup
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.6600000262260437;height:480;width:600}
}
##^##*/
