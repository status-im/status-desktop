import QtQuick

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import shared.panels

Item {
    width: parent.width
    height: childrenRect.height

    property bool isUserAdded
    signal addContactClicked()

    Image {
        id: waveImg
        source: Theme.png("chat/wave")
        width: 80
        height: 80
        anchors.horizontalCenter: parent.horizontalCenter
        cache: false
    }

    StatusBaseText {
        id: contactText1
        text: qsTr("You need to be mutual contacts with this person for them to receive your messages")
        anchors.top: waveImg.bottom
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.topMargin: Theme.padding
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.3
        color: Theme.palette.directColor1
    }

    StatusBaseText {
        id: contactText2
        visible: !isUserAdded
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
        visible: !isUserAdded
        text: qsTr("Add to contacts")
        anchors.top: contactText2.bottom
        anchors.topMargin: Theme.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: addContactClicked()
    }
}
