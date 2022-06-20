import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

Rectangle {
    id: root
    height: (root.contentType === Constants.messageContentType.imageType) ?
                replyToUsername.height + imageThumbnail.height + Style.current.padding :
                (root.contentType === Constants.messageContentType.stickerType) ?
                    replyToUsername.height + stickerThumbnail.height + Style.current.padding  : 50
    color: Style.current.replyBackground
    radius: Style.dp(16)
    clip: true

    property string userName: ""
    property string message : ""
    property string image: ""
    property string stickerData: ""
    property string messageId: ""
    property int contentType: -1

    signal closeButtonClicked()

    Rectangle {
        color: parent.color
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        height: parent.height / 2
        width: Style.dp(32)
        radius: Style.current.radius
    }

    StyledText {
        id: replyToUsername
        text: "↪ " + userName
        color: Style.current.textColor
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        font.pixelSize: Style.current.additionalTextSize
        font.weight: Font.Medium
    }

    Rectangle {
        anchors.left: replyToUsername.left
        anchors.top: replyToUsername.bottom
        anchors.topMargin: -Style.dp(3)
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.bottom: parent.bottom
        clip: true
        color: Style.current.transparent
        visible: (root.contentType !== Constants.messageContentType.imageType) && (root.contentType !== Constants.messageContentType.stickerType)

        StyledText {
            id: replyText
            text: Utils.getMessageWithStyle(StatusQUtils.Emoji.parse(Utils.linkifyAndXSS(message)), false)
            anchors.fill: parent
            elide: Text.ElideRight
            font.pixelSize: Style.current.additionalTextSize
            font.weight: Font.Normal
            textFormat: Text.RichText
            color: Style.current.textColor
        }
    }

    StatusChatImage {
        id: imageThumbnail
        anchors.left: replyToUsername.left
        anchors.top: replyToUsername.bottom
        anchors.topMargin: Style.dp(2)
        imageWidth: Style.dp(64)
        imageSource: root.image
        chatHorizontalPadding: 0
        container: root.container
        visible: root.contentType === Constants.messageContentType.imageType
        playing: false
    }

    StatusSticker {
        id: stickerThumbnail
        anchors.left: replyToUsername.left
        anchors.top: replyToUsername.bottom
        anchors.topMargin: Style.dp(2)
        imageWidth: Style.dp(64)
        imageHeight: Style.dp(64)
        stickerData: root.stickerData
        color: Style.current.transparent
        contentType: root.contentType
    }

    RoundButton {
        id: closeBtn
        implicitWidth: Style.dp(20)
        implicitHeight: Style.dp(20)
        radius: Style.dp(10)
        padding: 0
        anchors.top: parent.top
        anchors.topMargin: Style.dp(4)
        anchors.right: parent.right
        anchors.rightMargin: 4
        contentItem: SVGImage {
            id: iconImg
            source: Style.svg("close")
            width: closeBtn.width
            height: closeBtn.height

            ColorOverlay {
                anchors.fill: iconImg
                source: iconImg
                color: Style.current.textColor
                antialiasing: true
            }
        }
        background: Rectangle {
            color: "transparent"
            width: closeBtn.width
            height: closeBtn.height
            radius: closeBtn.radius
        }
        onClicked: {
            root.userName = ""
            root.message = ""
            root.messageId = ""
            root.stickerData = ""
            root.image = ""
            root.contentType = -1
            root.closeButtonClicked()
        }
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onPressed: mouse.accepted = false
        }
    }

}
