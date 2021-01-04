import QtQuick 2.14
import "../../../../../shared"
import "../../../../../imports"

Loader {
    property int textFieldWidth: item ? item.textField.width : 0
    property int authorWidth: item ? item.authorMetrics.width : 0

    property bool longReply: false
    property color elementsColor: isCurrentUser ? Style.current.chatReplyCurrentUser : Style.current.secondaryText
    property var container
    property int chatHorizontalPadding

    id: root
    active: responseTo != "" && replyMessageIndex > -1

    sourceComponent: Component {
        Rectangle {
            property alias textField: lblReplyMessage
            property alias authorMetrics: txtAuthorMetrics

            id: chatReply
            visible: responseTo != "" && replyMessageIndex > -1
            // childrenRect.height shows a binding loop for soem reason, so we use heights instead
            height: this.visible ? lblReplyAuthor.height + ((repliedMessageType === Constants.imageType ? imgReplyImage.height : lblReplyMessage.height) + 5 + 8) : 0
            color: Style.current.transparent

            TextMetrics {
                id: txtAuthorMetrics
                font: lblReplyAuthor.font
                text: lblReplyAuthor.text
            }

            StyledTextEdit {
                id: lblReplyAuthor
                text: "↳" + repliedMessageAuthor
                color: root.elementsColor
                readOnly: true
                selectByMouse: true
                wrapMode: Text.Wrap
                anchors.left: parent.left
                anchors.right: parent.right
            }

            ChatImage {
                id: imgReplyImage
                visible: repliedMessageType == Constants.imageType
                imageWidth: 50
                imageSource: repliedMessageImage
                anchors.top: lblReplyAuthor.bottom
                anchors.topMargin: 5
                anchors.left: parent.left
                chatHorizontalPadding: 0
                container: root.container
            }

            StyledTextEdit {
                id: lblReplyMessage
                visible: repliedMessageType != Constants.imageType
                anchors.top: lblReplyAuthor.bottom
                anchors.topMargin: 5
                text: `<style type="text/css">`+
                        `a {`+
                            `color: ${isCurrentUser && !appSettings.compactMode ? Style.current.white : Style.current.textColor};`+
                        `}`+
                        `a.mention {`+
                            `color: ${isCurrentUser ? Style.current.cyan : Style.current.turquoise};`+
                        `}`+
                        `</style>`+
                    `</head>`+
                    `<body>`+
                        `${Emoji.parse(Utils.linkifyAndXSS(repliedMessageContent), "26x26")}`+
                    `</body>`+
                `</html>`
                textFormat: Text.RichText
                color: root.elementsColor
                readOnly: true
                selectByMouse: true
                wrapMode: Text.Wrap
                font.pixelSize: Style.current.secondaryTextFontSize
                anchors.left: parent.left
                anchors.right: root.longReply ? parent.right : undefined
                z: 51
            }

            Separator {
                anchors.top: repliedMessageType == Constants.imageType ? imgReplyImage.bottom : lblReplyMessage.bottom
                anchors.topMargin: repliedMessageType == Constants.imageType ? 15 : 8
                anchors.left: lblReplyMessage.left
                anchors.right: lblReplyMessage.right
                anchors.rightMargin: root.chatHorizontalPadding
                color: root.elementsColor
            }
        }
    }
}

