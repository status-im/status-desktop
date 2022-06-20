import QtQuick 2.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0

Item {
    width: parent.width
    height: childrenRect.height

    property bool isContact
    signal addContactClicked()

    Image {
        id: waveImg
        source: Style.png("chat/wave")
        width: Style.dp(80)
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StatusBaseText {
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
        color: Theme.palette.directColor1
    }

    StatusBaseText {
        id: contactText2
        visible: !isContact
        //% "Just click this button to add them as contact. They will receive a notification. Once they accept the request, you'll be able to chat"
        text: qsTrId("just-click-this-button-to-add-them-as-contact--they-will-receive-a-notification--once-they-accept-the-request--you-ll-be-able-to-chat")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.top: contactText1.bottom
        anchors.topMargin: Style.dp(2)
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.3
        color: Theme.palette.directColor1
    }

    StatusButton {
        visible: !isContact
        //% "Add to contacts"
        text: qsTrId("add-to-contacts")
        anchors.top: contactText2.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: addContactClicked()
    }
}
