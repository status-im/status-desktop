import QtQuick 2.13
import "../../../../../shared"
import "../../../../../imports"
import QtGraphicalEffects 1.0

Item {
    property bool longChatText: true
    property bool veryLongChatText: chatsModel.plainText(message).length >
                                    (appSettings.compactMode ? Constants.limitLongChatTextCompactMode : Constants.limitLongChatText)
    property bool readMore: false
    property alias textField: chatText

    id: root
    visible: contentType == Constants.messageType || isEmoji
    z: 51

    height: visible ? (showMoreLoader.active ? childrenRect.height - 10 : chatText.height) : 0

    // This function is to avoid the binding loop warning
    function setWidths() {
        if (longChatText) {
            root.width = undefined
            chatText.width = Qt.binding(function () {return root.width})
        } else {
            chatText.width = Qt.binding(function () {return chatText.implicitWidth})
            root.width = Qt.binding(function () {return chatText.width})
        }
    }

    Component.onCompleted: {
        root.setWidths()
    }

    StyledTextEdit {
        id: chatText
        visible: !showMoreLoader.active || root.readMore
        textFormat: Text.RichText
        wrapMode: Text.Wrap
        font.pixelSize: Style.current.primaryTextFontSize
        readOnly: true
        selectByMouse: true
        color: Style.current.textColor
        height: root.veryLongChatText && !root.readMore ? Math.min(implicitHeight, 200) : implicitHeight
        clip: true
        onLinkActivated: function (link) {
            if(link.startsWith("#")) {
                chatsModel.joinChat(link.substring(1), Constants.chatTypePublic);
                return;
            }

            if (link.startsWith('//')) {
                let pk = link.replace("//", "");
                const userProfileImage = appMain.getProfileImage(pk)
                openProfilePopup(chatsModel.userNameOrAlias(pk), pk, userProfileImage || utilsModel.generateIdenticon(pk))
                return;
            }

            appMain.openLink(link)
        }

        onLinkHovered: {
            cursorShape: Qt.PointingHandCursor
        }

        text: {
            if(contentType === Constants.stickerType) return "";
            let msg = Utils.linkifyAndXSS(message);
            if(isEmoji) {
                return Emoji.parse(msg, Emoji.size.middle);
            } else {
                return `<style type="text/css">` +
                            `p, img, a, del, code, blockquote { margin: 0; padding: 0; }` +
                            `code {` +
                                `background-color: ${Style.current.codeBackground};` +
                                `color: ${Style.current.white};` +
                                `white-space: pre;` +
                            `}` +
                            `p {` +
                                `line-height: 22px;` +
                            `}` +
                            `a {` +
                                `color: ${isCurrentUser && !appSettings.compactMode ? Style.current.white : Style.current.textColor};` +
                            `}` +
                            `a.mention {` +
                                `color: ${isCurrentUser ? Style.current.cyan : Style.current.turquoise};` +
                            `}` +
                            `del {` +
                                `text-decoration: line-through;` +
                            `}` +
                            `table.blockquote td {` +
                                `padding-left: 10px;` +
                                `color: ${isCurrentUser ? Style.current.chatReplyCurrentUser : Style.current.secondaryText};` +
                            `}` +
                            `table.blockquote td.quoteline {` +
                                `background-color: ${isCurrentUser ? Style.current.chatReplyCurrentUser : Style.current.secondaryText};` +
                                `height: 100%;` +
                                `padding-left: 0;` +
                            `}` +
                            `.emoji {` +
                                `vertical-align: bottom;` +
                            `}` +
                        `</style>` +
                        `${Emoji.parse(msg)}`
            }
        }
    }


    Loader {
        id: mask
        anchors.fill: chatText
        active: showMoreLoader.active
        visible: false
        sourceComponent: LinearGradient {
            start: Qt.point(0, 0)
            end: Qt.point(0, chatText.height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 0.85; color: "white" }
                GradientStop { position: 1; color: "transparent" }
            }
        }
    }

    Loader {
        id: opMask
        active: showMoreLoader.active && !root.readMore
        anchors.fill: chatText
        sourceComponent: OpacityMask {
            source: chatText
            maskSource: mask
        }
    }

    Loader {
        id: showMoreLoader
        active: root.veryLongChatText
        anchors.top: chatText.bottom
        anchors.topMargin: - Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: Component {
            SVGImage {
                id: emojiImage
                width: 256
                height: 44
                fillMode: Image.PreserveAspectFit
                source: "../../../../img/read-more.svg"
                z: 100
                rotation: root.readMore ? 180 : 0
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
}
