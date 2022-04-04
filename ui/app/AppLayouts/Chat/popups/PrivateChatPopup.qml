import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import "./"

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    title: qsTr("New chat")
    property var store
    property var contactsStore

    signal joinPrivateChat(string publicKey, string ensName)

    signal profileClicked()
    function doJoin(pubKey, username) {
        popup.joinPrivateChat(pubKey, Utils.isChatKey(pubKey) ? "" : username);
        popup.close();
    }

    onOpened: {
        contactFieldAndList.chatKey.text = ""
        contactFieldAndList.pubKey = ""
        contactFieldAndList.ensUsername = ""
        contactFieldAndList.chatKey.forceActiveFocus(Qt.MouseFocusReason)
        contactFieldAndList.existingContacts.visible = contactsStore.myContactsModel.count > 0
        contactFieldAndList.noContactsRect.visible = !contactFieldAndList.existingContacts.visible
    }

    ContactsListAndSearch {
        id: contactFieldAndList
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        addContactEnabled: false

        contactsStore: popup.contactsStore
        rootStore: popup.store

        onUserClicked: function (pubKey, isAddedContact, username) {
            popup.doJoin(pubKey, username);
        }
    }

    Control {
        width: 124
        height: 36
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        background: Rectangle {
            anchors.fill: parent
            radius: 34
            color: Style.current.blue
        }
        contentItem: Item {
            anchors.fill: parent
            RoundedImage {
                id: dollarEmoji
                width: 32
                height: 32
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                source: Global.getProfileImage(userProfile.pubKey)
            }

            StyledText {
                anchors.left: dollarEmoji.right
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("My Profile")
                font.pixelSize: 15
                color: Style.current.white
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"
            onClicked: {
                popup.profileClicked();
                Global.settingsSubsection = Constants.settingsSubsection.profile;
                popup.close();
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;height:300;width:300}
}
##^##*/
