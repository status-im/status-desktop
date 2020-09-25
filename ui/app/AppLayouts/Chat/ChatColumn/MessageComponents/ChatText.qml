import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Item {
    property bool longChatText: true
    property bool veryLongChatText: chatsModel.plainText(message).length >
                                    (appSettings.compactMode ? Constants.limitLongChatTextCompactMode : Constants.limitLongChatText)
    property bool readMore: false
    property alias textField: chatText

    id: root
    visible: contentType == Constants.messageType || isEmoji
    z: 51
    height: childrenRect.height
    width: longChatText ? undefined : chatText.width

    StyledTextEdit {
        id: chatText
        textFormat: Text.RichText
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.Wrap
        font.pixelSize: 15
        readOnly: true
        selectByMouse: true
        color: Style.current.textColor
        width: longChatText ? parent.width : implicitWidth
        height: root.veryLongChatText && !root.readMore ? 200 : implicitHeight
        clip: true
        onLinkActivated: function (link) {
            if(link.startsWith("#")) {
                chatsModel.joinChat(link.substring(1), Constants.chatTypePublic);
                return;
            }

            if (link.startsWith('//')) {
                let pk = link.replace("//", "");
                profilePopup.openPopup(chatsModel.userNameOrAlias(pk), pk, chatsModel.generateIdenticon(pk))
                return;
            }

            Qt.openUrlExternally(link)
        }
        text: {
            if(contentType === Constants.stickerType) return "";
            let msg = Utils.linkifyAndXSS(message);
            if(isEmoji) {
                return Emoji.parse(msg, "72x72");
            } else {
                return `<html>`+
                    `<head>`+
                        `<style type="text/css">`+
                        `code {`+
                            `background-color: #1a356b;`+
                            `color: #FFFFFF;`+
                            `white-space: pre;`+
                        `}`+
                        `p {`+
                            `white-space: pre-wrap;`+
                        `}`+
                        `a {`+
                            `color: ${isCurrentUser && !appSettings.compactMode ? Style.current.white : Style.current.textColor};`+
                        `}`+
                        `a.mention {`+
                            `color: ${isCurrentUser ? Style.current.cyan : Style.current.turquoise};`+
                        `}`+
                        `blockquote {`+
                            `margin: 0;`+
                            `padding: 0;`+
                        `}`+
                        `</style>`+
                    `</head>`+
                    `<body>`+
                        `${Emoji.parse(msg, "26x26")}`+
                    `</body>`+
                `</html>`;
            }
        }
    }

    Loader {
        active: root.veryLongChatText
        sourceComponent: showMoreComponent
        anchors.top: chatText.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.left: chatText.horizontalAlignment === Text.AlignLeft ? chatText.left : undefined
        anchors.right: chatText.horizontalAlignment === Text.AlignLeft ? undefined : chatText.right
    }

    Component {
        id: showMoreComponent
        StyledText {
            text: root.readMore ?
                      qsTr("Read less") :
                      qsTr("Read more")
            color: chatText.color
            font.pixelSize: 12
            font.underline: true
            z: 100

            MouseArea {
                z: 101
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.readMore = !root.readMore
                }
            }
        }
    }


}
