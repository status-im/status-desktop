import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"
import "../components"

ModalPopup {
    id: popup

    property var pubKeys: []
    property var goBack

    onOpened: {
        pubKeys = [];
        inviteBtn.enabled = false
        contactList.membersData.clear();
        // TODO remove friends that are already members
        chatView.getContactListObject(contactList.membersData)
        noContactsRect.visible = !profileModel.contactList.hasAddedContacts();
        contactList.visible = !noContactsRect.visible;
    }

    title: qsTr("Invite friends")

    Item {
        anchors.fill: parent

        NoFriendsRectangle {
            id: noContactsRect
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        ContactList {
            id: contactList
            selectMode: true
            onItemChecked: function(pubKey, itemChecked) {
                var idx = pubKeys.indexOf(pubKey)
                if (itemChecked) {
                    if (idx === -1) {
                        pubKeys.push(pubKey)
                    }
                } else {
                    if (idx > -1) {
                        pubKeys.splice(idx, 1);
                    }
                }
                inviteBtn.enabled = pubKeys.length > 0
            }
        }
    }

    footer: Item {
        anchors.fill: parent

        StatusRoundButton {
            id: btnBack
            anchors.left: parent.left
            visible: !!popup.goBack
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked: {
                // Go back? Make it work when it's
                popup.goBack()
            }
        }

        StatusButton {
            id: inviteBtn
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            text: qsTr("Invite")
            onClicked : {
                console.log('invite')
            }
        }
    }
}

