import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

Rectangle {
    id: root
    property string chatId: ""
    property string name: "channelName"
    property string message: "My latest message\n with a return"
    property int chatType: Constants.chatTypePublic
    property string identicon: ""

    color: "#F7F7F7"
    width: 366
    height: 75

    anchors.top: applicationWindow.top
    radius: Style.current.radius

    Loader {
        id: identicon
        sourceComponent: root.identicon === "" || appSettings.notificationMessagePreviewSetting === Constants.notificationPreviewAnonymous ?  statusIdenticon : userOrChannelIdenticon 
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        height: 40
        width: 40
    }

    Component {
        id: userOrChannelIdenticon
        StatusIdenticon {
            height: 40
            width: 40
            chatName: root.name
            chatType: root.chatType
            identicon: root.identicon
        }
    }

    Component {
        id: statusIdenticon
        SVGImage {
            source: "../../app/img/status-logo-icon.svg"
            width: 40
            height: 40
        }
    }

    StyledText {
        id: name
        anchors.bottom: messagePreview.top
        anchors.bottomMargin: 2
        anchors.left: identicon.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: openButton.left
        anchors.rightMargin: Style.current.smallPadding
        elide: Text.ElideRight
        text: root.name
        font.weight: Font.Medium
        font.pixelSize: 15
        color: Style.current.evenDarkerGrey
    }

    StyledText {
        id: messagePreview
        anchors.bottom: identicon.bottom
        anchors.bottomMargin: 2
        anchors.left: identicon.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: openButton.left
        anchors.rightMargin: Style.current.padding
        elide: Text.ElideRight
        clip: true // This is needed because emojis don't ellide correctly
        font.pixelSize: 14
        color: Style.current.evenDarkerGrey
        text: root.message
    }

    Rectangle {
        id: openButton
        anchors.right: parent.right
        height: parent.height
        width: 85
        color: "transparent"

        Rectangle {
            height: parent.height
            width: 1.2
            anchors.left: parent.left
            color: "#D9D9D9"
        }

        StyledText {
            font.weight: Font.Medium
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            //% "Open"
            text: qsTrId("open")
            color: Style.current.darkerGrey
        }
    }
}

