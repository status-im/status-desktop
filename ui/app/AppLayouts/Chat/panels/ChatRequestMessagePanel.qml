import QtQuick 2.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"

Item {
    visible: chatsModel.channelView.activeChannel.chatType === Constants.chatTypeOneToOne && (!isContact /*|| !contactRequestReceived*/)
    width: parent.width
    height: childrenRect.height

    Image {
        id: waveImg
        source: Style.png("wave")
        width: 80
        height: 80
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StyledText {
        id: contactText1
        //% "You need to be mutual contacts with this person for them to receive your messages"
        text: qsTrId("you-need-to-be-mutual-contacts-with-this-person-for-them-to-receive-your-messages")
        //% "You need to be mutual contacts with this person for them to receive your messages"
        // text: !isContact ? qsTrId("you-need-to-be-mutual-contacts-with-this-person-for-them-to-receive-your-messages") :
        //% "Waiting for %1 to accept your request"
        // qsTrId("waiting-for--1-to-accept-your-request").arg(Utils.removeStatusEns(chatsModel.channelView.activeChannel.name))
        anchors.top: waveImg.bottom
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.3
    }

    StyledText {
        id: contactText2
        visible: !isContact
        //% "Just click this button to add them as contact. They will receive a notification. Once they accept the request, you'll be able to chat"
        text: qsTrId("just-click-this-button-to-add-them-as-contact--they-will-receive-a-notification--once-they-accept-the-request--you-ll-be-able-to-chat")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.top: contactText1.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.3
    }

    StatusButton {
        visible: !isContact
        //% "Add to contacts"
        text: qsTrId("add-to-contacts")
        anchors.top: contactText2.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: profileModel.contacts.addContact(activeChatId)
    }
}
