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
        noContactsRect.visible = !profileModel.contacts.list.hasAddedContacts();
        contactList.visible = !noContactsRect.visible;
    }

    title: qsTr("Invite friends")

    Item {
        anchors.fill: parent


        TextWithLabel {
            id: shareCommunity
            anchors.top: parent.top
            label: qsTr("Share community")
            text: "https://join.status.im/u/TODO"
            textToCopy: text
        }

        Separator {
            id: sep
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: shareCommunity.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.leftMargin: -Style.current.padding
            anchors.rightMargin: -Style.current.padding
        }

        StyledText {
            text: qsTr("Contacts")
            anchors.left: parent.left
            anchors.top: sep.bottom
            anchors.topMargin: Style.current.smallPadding
            font.pixelSize: 15
            font.weight: Font.Thin
            color: Style.current.secondaryText
        }

        NoFriendsRectangle {
            id: noContactsRect
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        ContactList {
            id: contactList
            selectMode: true
            anchors.top: sep.bottom
            anchors.topMargin: 100
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
        width: parent.width
        height: inviteBtn.height

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
                popup.pubKeys.forEach(function (pubKey) {
                    const error = chatsModel.inviteUserToCommunity(pubKey)
                    if (error) {
                        console.log('do something?')
                    }
                })
            }
        }
    }
}

