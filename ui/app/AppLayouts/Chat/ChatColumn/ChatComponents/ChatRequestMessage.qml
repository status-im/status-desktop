import QtQuick 2.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

Item {
    visible: chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne && !isContact
    width: parent.width
    height: childrenRect.height

    Image {
        id: waveImg
        source: "../../../../img/wave.png"
        width: 80
        height: 80
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StyledText {
        id: contactText1
        text: qsTr("You need to be mutual contacts with this person for them to receive your messages")
        anchors.top: waveImg.bottom
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.3
    }

    StyledText {
        id: contactText2
        text: qsTr("Just click this button to add them as contact. They will receive a notification all once they accept you as contact as well, you'll be able to chat")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.top: contactText1.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 1.3
    }

    StatusButton {
        text: qsTr("Add to contacts")
        anchors.top: contactText2.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: profileModel.contacts.addContact(activeChatId)
    }
}
