import QtQuick 2.15
import QtQuick.Controls 2.15

import utils 1.0
import shared 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components.private 0.1

Rectangle {
    id: root
    implicitHeight: (root.contentType === Constants.messageContentType.imageType)
                    ? replyToUsername.height + imageThumbnail.height + Theme.padding
                    : (root.contentType === Constants.messageContentType.stickerType)
                      ? replyToUsername.height + stickerThumbnail.height + Theme.padding
                      : 50

    color: Theme.palette.baseColor3
    radius: 16
    clip: true

    property string userName: ""
    property string message : ""
    property string image: ""
    property string stickerData: ""
    property string messageId: ""
    property int contentType: -1
    property var album: []
    property int albumCount: 0

    signal closeButtonClicked()

    Rectangle {
        color: parent.color
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        height: parent.height / 2
        width: 32
        radius: Theme.radius
    }

    StyledText {
        id: replyToUsername
        text: "↪ " + userName
        color: Theme.palette.textColor
        anchors.top: parent.top
        anchors.topMargin: Theme.halfPadding
        anchors.left: parent.left
        anchors.leftMargin: Theme.smallPadding
        font.pixelSize: Theme.additionalTextSize
        font.weight: Font.Medium
    }

    Rectangle {
        anchors.left: replyToUsername.left
        anchors.top: replyToUsername.bottom
        anchors.topMargin: -3
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.bottom: parent.bottom
        clip: true
        color: Theme.palette.transparent
        visible: (root.contentType !== Constants.messageContentType.imageType) && (root.contentType !== Constants.messageContentType.stickerType)

        StyledText {
            id: replyText
            text: StatusQUtils.Utils.getMessageWithStyle(StatusQUtils.Emoji.parse(StatusQUtils.Utils.linkifyAndXSS(message)), false)
            anchors.fill: parent
            elide: Text.ElideRight
            font.pixelSize: Theme.additionalTextSize
            font.weight: Font.Normal
            textFormat: Text.RichText
            color: Theme.palette.textColor
        }
    }

    StatusMessageImageAlbum {
        id: imageThumbnail
        anchors.left: replyToUsername.left
        anchors.top: replyToUsername.bottom
        anchors.topMargin: 2
        album: root.albumCount > 0 ? root.album : [root.image]
        albumCount: root.albumCount > 0 ? root.albumCount : 1
        imageWidth: 56
        loadingComponentHeight: 56
        shapeType: StatusImageMessage.ShapeType.ROUNDED
    }

    StatusSticker {
        id: stickerThumbnail
        anchors.left: replyToUsername.left
        anchors.top: replyToUsername.bottom
        anchors.topMargin: 2
        imageWidth: 64
        imageHeight: 64
        stickerData: root.stickerData
        color: Theme.palette.transparent
        contentType: root.contentType
    }

    RoundButton {
        id: closeBtn
        implicitWidth: 20
        implicitHeight: 20
        radius: 10
        padding: 0
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.right: parent.right
        anchors.rightMargin: 4
        contentItem: StatusIcon {
            id: iconImg
            source: Theme.svg("close")
            color: Theme.palette.textColor
            sourceSize: Qt.size(width, height)
            width: closeBtn.width
            height: closeBtn.height
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
        StatusMouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onPressed: mouse.accepted = false
        }
    }

}
