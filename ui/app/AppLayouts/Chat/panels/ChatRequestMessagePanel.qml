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
        width: 80
        height: 80
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StatusBaseText {
        id: contactText1
        text: qsTr("You need to be mutual contacts with this person for them to receive your messages")
        // text: !isContact ? qsTr("You need to be mutual contacts with this person for them to receive your messages") :
        // qsTr("Waiting for %1 to accept your request").arg(Utils.removeStatusEns(chatsModel.channelView.activeChannel.name))
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
        text: qsTr("Just click this button to add them as contact. They will receive a notification. Once they accept the request, you'll be able to chat")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.top: contactText1.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.3
        color: Theme.palette.directColor1
    }

    StatusButton {
        visible: !isContact
        text: qsTr("Add to contacts")
        anchors.top: contactText2.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: addContactClicked()
    }
}
