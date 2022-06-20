import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

Rectangle {
    id: root
    property string chatId: ""
    property string name: "channelName"
    property string message: "My latest message\n with a return"
    property int chatType: Constants.chatType.publicChat

    color: "#F7F7F7"
    width: Style.dp(366)
    height: Style.dp(75)

    anchors.top: Global.applicationWindow.top
    radius: Style.current.radius

    Loader {
        id: identicon
        sourceComponent: localAccountSensitiveSettings.notificationMessagePreviewSetting === Constants.settingsSection.notificationsBubble.previewAnonymous ?  statusIdenticon : userOrChannelIdenticon
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        height: Style.dp(40)
        width: Style.dp(40)
    }

    Component {
        id: userOrChannelIdenticon
        StatusSmartIdenticon {
            id: contactImage
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.verticalCenter: parent.verticalCenter
            image: StatusImageSettings {
                width: Style.dp(40)
                height: Style.dp(40)
            }
            icon: StatusIconSettings {
                width: Style.dp(40)
                height: Style.dp(40)
                letterSize: Style.current.primaryTextFontSize
                color: Theme.palette.miscColor5
            }
            name: root.name
        }
    }

    Component {
        id: statusIdenticon
        SVGImage {
            source: Style.svg("status-logo-icon")
            width: Style.dp(40)
            height: Style.dp(40)
        }
    }

    StyledText {
        id: name
        anchors.bottom: messagePreview.top
        anchors.bottomMargin: Style.dp(2)
        anchors.left: identicon.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: openButton.left
        anchors.rightMargin: Style.current.smallPadding
        elide: Text.ElideRight
        text: root.name
        font.weight: Font.Medium
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.evenDarkerGrey
    }

    StyledText {
        id: messagePreview
        anchors.bottom: identicon.bottom
        anchors.bottomMargin: Style.dp(2)
        anchors.left: identicon.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: openButton.left
        anchors.rightMargin: Style.current.padding
        elide: Text.ElideRight
        clip: true // This is needed because emojis don't ellide correctly
        font.pixelSize: Style.current.secondaryTextFontSize
        color: Style.current.evenDarkerGrey
        text: root.message
    }

    Rectangle {
        id: openButton
        anchors.right: parent.right
        height: parent.height
        width: Style.dp(85)
        color: "transparent"

        Rectangle {
            height: parent.height
            width: 1.2
            anchors.left: parent.left
            color: "#D9D9D9"
        }

        StyledText {
            font.weight: Font.Medium
            font.pixelSize: Style.current.secondaryTextFontSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            //% "Open"
            text: qsTrId("open")
            color: Style.current.darkerGrey
        }
    }
}

