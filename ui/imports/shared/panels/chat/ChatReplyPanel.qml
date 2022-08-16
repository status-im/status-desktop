import QtQuick 2.14
import QtQuick.Shapes 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls.chat 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

Loader {
    id: root

    property bool amISenderOfTheRepliedMessage
    property int repliedMessageContentType
    property string repliedMessageSenderIcon
    property bool repliedMessageIsEdited
    property string repliedMessageSender
    property string repliedMessageSenderPubkey
    property bool repliedMessageSenderIsAdded
    property string repliedMessageContent
    property string repliedMessageImage
    property bool isCurrentUser: false
    property int nameMargin: 6
    property int textFieldWidth: item ? item.textField.width : 0
    property int textFieldImplicitWidth: 0
    property int authorWidth: item ? item.authorMetrics.width : 0
    property bool longReply: false
    property color elementsColor: amISenderOfTheRepliedMessage ? Style.current.chatReplyCurrentUser : Style.current.secondaryText
    property var container
    property int chatHorizontalPadding
    property string stickerData

    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage, var image, bool isEmoji, bool hideEmojiPicker, bool isReply)
    signal scrollToBottom(bool isit, var container)

    sourceComponent: Component {
        Item {
            property alias textField: lblReplyMessage
            property alias authorMetrics: txtAuthorMetrics

            id: chatReply
            // childrenRect.height shows a binding loop for some reason, so we use heights instead
            height: {
                const h = userImage.height + 4
                if (repliedMessageContentType === Constants.messageContentType.imageType) {
                    return h + imgReplyImage.height
                }
                if (repliedMessageContentType === Constants.messageContentType.stickerType) {
                    return h + stickerLoader.height
                }
                return h + lblReplyMessage.height
            }
            width: parent.width
            clip: true

            TextMetrics {
                id: txtAuthorMetrics
                font: lblReplyAuthor.font
                text: lblReplyAuthor.text
            }

            Shape {
                id: replyCorner
                anchors.left: parent.left
                anchors.leftMargin: 24 - 1
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                width: 20
                height: parent.height - anchors.topMargin
                asynchronous: true
                antialiasing: true

                ShapePath {
                    id: capTest

                    strokeColor: Utils.setColorAlpha(root.elementsColor, 0.4)
                    strokeWidth: 3
                    fillColor: "transparent"

                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin

                    startX: 20
                    startY: 0
                    PathLine { x: 10; y: 0 }
                    PathArc {
                           x: 0; y: 10
                           radiusX: 13
                           radiusY: 13
                           direction: PathArc.Counterclockwise
                       }
                    PathLine { x: 0; y: chatReply.height - replyCorner.anchors.topMargin }
                }
            }

            UserImage {
                id: userImage
                anchors.left: replyCorner.right
                anchors.leftMargin: Style.current.halfPadding

                imageHeight: 20
                imageWidth: 20
                active: true

                name: repliedMessageSender
                pubkey: repliedMessageSenderPubkey
                image: repliedMessageSenderIcon

                onClicked: root.clickMessage(true, false, false, null, false, false, true)
            }

            StyledTextEdit {
                id: lblReplyAuthor
                text: repliedMessageSender
                color: root.elementsColor
                readOnly: true
                font.pixelSize: Style.current.secondaryTextFontSize
                selectByMouse: true
                font.weight: Font.Medium
                anchors.verticalCenter: userImage.verticalCenter
                anchors.left: userImage.right
                anchors.leftMargin: 5
            }

            StatusChatImage {
                id: imgReplyImage
                visible: repliedMessageContentType === Constants.messageContentType.imageType
                imageWidth: 50
                imageSource: repliedMessageImage
                anchors.top: lblReplyAuthor.bottom
                anchors.topMargin: nameMargin
                anchors.left: userImage.left
                chatHorizontalPadding: 0
                container: root.container
                allCornersRounded: true
                playing: false
            }

            Loader {
                id: stickerLoader
                active: repliedMessageContentType === Constants.messageContentType.stickerType
                anchors.top: lblReplyAuthor.bottom
                anchors.topMargin: nameMargin
                anchors.left: userImage.left
                sourceComponent: Component {
                    StatusSticker {
                        id: stickerId
                        imageHeight: 56
                        imageWidth: 56
                        stickerData: root.stickerData
                        contentType: repliedMessageContentType
                        onLoaded: {
                            scrollToBottom(true, root.container)
                        }
                    }
                }
            }

            StyledTextEdit {
                id: lblReplyMessage
                visible: repliedMessageContentType !== Constants.messageContentType.imageType && repliedMessageContentType !== Constants.messageContentType.stickerType
                Component.onCompleted: textFieldImplicitWidth = implicitWidth
                anchors.top: lblReplyAuthor.bottom
                anchors.topMargin: nameMargin
                text: {
                    if (repliedMessageIsEdited){
                        let index = repliedMessageContent.length - 4
                        return Utils.getReplyMessageStyle(StatusQUtils.Emoji.parse(Utils.linkifyAndXSS(repliedMessageContent.slice(0, index) + Constants.editLabel + repliedMessageContent.slice(index)), StatusQUtils.Emoji.size.small), amISenderOfTheRepliedMessage)
                    } else {
                        return Utils.getReplyMessageStyle(StatusQUtils.Emoji.parse(Utils.linkifyAndXSS(repliedMessageContent), StatusQUtils.Emoji.size.small), amISenderOfTheRepliedMessage)
                    }
                }
                textFormat: Text.RichText
                color: root.elementsColor
                readOnly: true
                selectByMouse: true
                font.pixelSize: Style.current.additionalTextSize
                font.weight: Font.Medium
                anchors.left: userImage.left
                width: root.longReply ? parent.width : implicitWidth
                height: 20
                clip: true
                z: 51
            }
        }
    }
}

