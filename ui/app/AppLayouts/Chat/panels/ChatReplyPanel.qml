import QtQuick 2.14
import QtQuick.Shapes 1.13
import QtGraphicalEffects 1.13

import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import "../controls"

import utils 1.0

Loader {
    id: root

    property int nameMargin: 6
    property int textFieldWidth: item ? item.textField.width : 0
    property int textFieldImplicitWidth: 0
    property int authorWidth: item ? item.authorMetrics.width : 0
    property bool longReply: false
    property color elementsColor: isCurrentUser ? Style.current.chatReplyCurrentUser : Style.current.secondaryText
    property var container
    property int chatHorizontalPadding
    property var stickerData
    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage, var image, bool emojiOnly, bool hideEmojiPicker, bool isReply)

//    TODO bring those back and remove dynamic scoping
//    property bool isCurrentUser: false
//    property int repliedMessageType
//    property string repliedMessageImage
//    property string repliedMessageUserIdenticon
//    property bool repliedMessageIsEdited
//    property string repliedMessageUserImage
//    property string repliedMessageAuthor
//    property string repliedMessageContent
//    property string responseTo: ""
//    signal scrollToBottom(bool isit, var container)

    sourceComponent: Component {
        Item {
            property alias textField: lblReplyMessage
            property alias authorMetrics: txtAuthorMetrics
            property var messageEdited: function(id, content) {
                if (responseTo === id){
                    lblReplyMessage.text = Utils.getReplyMessageStyle(Emoji.parse(Utils.linkifyAndXSS(content + Constants.editLabel), Emoji.size.small), isCurrentUser, localAccountSensitiveSettings.useCompactMode)
                }
            }

            id: chatReply
            // childrenRect.height shows a binding loop for some reason, so we use heights instead
            height: {
                const h = userImage.height + 4
                if (repliedMessageType === Constants.imageType) {
                    return h + imgReplyImage.height
                }
                if (repliedMessageType === Constants.stickerType) {
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
                anchors.leftMargin: 20 - 1
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
                imageHeight: 20
                imageWidth: 20
                active: true
                anchors.left: replyCorner.right
                anchors.leftMargin: Style.current.halfPadding
//                identiconImageSource: repliedMessageUserIdenticon
                isReplyImage: true
//                profileImage: repliedMessageUserImage
//                isCurrentUser: isCurrentUser
                onClickMessage: {
                    root.clickMessage(true, false, false, null, false, false, isReplyImage)
                }
            }

            StyledTextEdit {
                id: lblReplyAuthor
                text: repliedMessageAuthor
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
                visible: repliedMessageType === Constants.imageType
                imageWidth: 50
                imageSource: repliedMessageImage
                anchors.top: lblReplyAuthor.bottom
                anchors.topMargin: nameMargin
                anchors.left: userImage.left
                chatHorizontalPadding: 0
                container: root.container
                allCornersRounded: true
            }

            Loader {
                id: stickerLoader
                active: repliedMessageType === Constants.stickerType
                anchors.top: lblReplyAuthor.bottom
                anchors.topMargin: nameMargin
                anchors.left: userImage.left
                sourceComponent: Component {
                    StatusSticker {
                        id: stickerId
                        imageHeight: 56
                        imageWidth: 56
                        stickerData: root.stickerData
                        contentType: repliedMessageType
                        onLoaded: {
                            scrollToBottom(true, root.container)
                        }
                    }
                }
            }

            StyledTextEdit {
                id: lblReplyMessage
                visible: repliedMessageType !== Constants.imageType && repliedMessageType !== Constants.stickerType
                Component.onCompleted: textFieldImplicitWidth = implicitWidth
                anchors.top: lblReplyAuthor.bottom
                anchors.topMargin: nameMargin
                text: {
                    if (repliedMessageIsEdited){
                        let index = repliedMessageContent.length - 4
                        return Utils.getReplyMessageStyle(Emoji.parse(Utils.linkifyAndXSS(repliedMessageContent.slice(0, index) + Constants.editLabel + repliedMessageContent.slice(index)), Emoji.size.small), isCurrentUser, localAccountSensitiveSettings.useCompactMode)
                    } else {
                        return Utils.getReplyMessageStyle(Emoji.parse(Utils.linkifyAndXSS(repliedMessageContent), Emoji.size.small), isCurrentUser, localAccountSensitiveSettings.useCompactMode)
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

