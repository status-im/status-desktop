import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import QtQuick.Dialogs 1.3
import "../components"
import "../../../../shared"
import "../../../../imports"


import "../components/emojiList.js" as EmojiJSON

Rectangle {
    id: root
    property alias textInput: txtData
    border.width: 0
    height: 52
    color: Style.current.transparent

    visible: chatsModel.activeChannel.chatType !== Constants.chatTypePrivateGroupChat || chatsModel.activeChannel.isMember

    property bool emojiEvent: false;
    property bool paste: false;
    property bool isColonPressed: false;

    property int extraHeightFactor: calculateExtraHeightFactor()
    property int messageLimit: 2000
    property int messageLimitVisible: 200

    Audio {
        id: sendMessageSound
        source: "../../../../sounds/send_message.wav"
        volume: appSettings.volume
    }

    function calculateExtraHeightFactor() {
        const factor = (txtData.length / 500) + 1;
        return (factor > 5) ? 5 : factor;
    }

    function insertInTextInput(start, text) {
        // Repace new lines with entities because `insert` gets rid of them
        txtData.insert(start, text.replace(/\n/g, "<br/>"));
    }

    function interpretMessage(msg) {
        if (msg === "/shrug") {
            return "¯\\\\\\_(ツ)\\_/¯"
        }
        if (msg === "/tableflip") {
            return "(╯°□°）╯︵ ┻━┻"
        }

        return msg
    }

    function sendMsg(event){
        if(chatColumn.isImage){
            const error = chatsModel.sendImage(sendImageArea.image);
            if (error) {
                toastMessage.title = error
                toastMessage.source = "../../../img/block-icon.svg"
                toastMessage.iconColor = Style.current.danger
                toastMessage.linkText = ""
                toastMessage.open()
            }
        }
        var msg = chatsModel.plainText(Emoji.deparse(txtData.text).trim()).trim()
        if(msg.length > 0){
            msg = interpretMessage(msg)
            chatsModel.sendMessage(msg, chatColumn.isReply ? SelectedMessage.messageId : "", Utils.isOnlyEmoji(msg) ? Constants.emojiType : Constants.messageType);
            txtData.text = "";
            if(event) event.accepted = true
            sendMessageSound.stop()
            Qt.callLater(sendMessageSound.play);
        }
        chatColumn.hideExtendedArea();
    }

    function onEnter(event){
        if (event.modifiers === Qt.NoModifier && (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
            if (emojiSuggestions.visible) {
                emojiSuggestions.addEmoji();
                event.accepted = true;
                return
            }
            if (txtData.length < messageLimit) {
                sendMsg(event);
                return;
            }
            if(event) event.accepted = true
            messageTooLongDialog.open()
        }

        if ((event.key === Qt.Key_V) && (event.modifiers & Qt.ControlModifier)) {
            paste = true;
        }

        if (event.key === Qt.Key_Down) {
            return emojiList.incrementCurrentIndex()
        }
        if (event.key === Qt.Key_Up) {
            return emojiList.decrementCurrentIndex()
        }

        isColonPressed = (event.key === Qt.Key_Colon) && (event.modifiers & Qt.ShiftModifier);
    }

    function onRelease(event) {
        // the text doesn't get registered to the textarea fast enough
        // we can only get it in the `released` event
        if (paste) {
            paste = false;
            interrogateMessage();
        }

        emojiEvent = emojiHandler(event);
        if (!emojiEvent) {
            emojiSuggestions.close()
        }
    }

    function onMouseClicked() {
        emojiEvent = emojiHandler({key: null});
    }

    function interrogateMessage() {
        const text = chatsModel.plainText(Emoji.deparse(txtData.text));
        var words = text.split(' ');

        for (var i = 0; i < words.length; i++) {
            var transform = true;
            if (words[i].charAt(0) === ':') {
                for (var j = 0; j < words[i].length; j++) {
                    if (Utils.isSpace(words[i].charAt(j)) === true || Utils.isPunct(words[i].charAt(j)) === true) {
                        transform = false;
                    }
                }

                if (transform) {
                    const codePoint = Emoji.getEmojiUnicode(words[i]);
                    words[i] = words[i].replace(words[i], (codePoint !== undefined) ? Emoji.fromCodePoint(codePoint) : words[i]);
                }
            }
        }

        txtData.remove(0, txtData.length);
        insertInTextInput(0, Emoji.parse(words.join('&nbsp;'), '26x26'));
    }

    function replaceWithEmoji(message, shortname, codePoint) {
        const encodedCodePoint = Emoji.getEmojiCodepoint(codePoint)
        const newMessage = message.data
            .replace(shortname, encodedCodePoint)
            .replace(/ /g, "&nbsp;");
        txtData.remove(0, txtData.cursorPosition);
        insertInTextInput(0, Emoji.parse(newMessage, '26x26'));
        emojiSuggestions.close()
        emojiEvent = false
    }

    function emojiHandler(event) {
        let message = extrapolateCursorPosition();
        pollEmojiEvent(message);

        // state machine to handle different forms of the emoji event state
        if (!emojiEvent && isColonPressed) {
            return (message.data.length <= 1 || Utils.isSpace(message.data.charAt(message.cursor - 1))) ? true : false;
        } else if (emojiEvent && isColonPressed) {
            const index = message.data.lastIndexOf(':', message.cursor - 2);
            if (index >= 0 && message.cursor > 0) {
                const shortname = message.data.substr(index, message.cursor);
                const codePoint = Emoji.getEmojiUnicode(shortname);
                if (codePoint !== undefined) {
                    replaceWithEmoji(message, shortname, codePoint);
                }
                return false;
            }
            return true;
        } else if (emojiEvent && isKeyValid(event.key) && !isColonPressed) {
            // popup
            const index2 = message.data.lastIndexOf(':', message.cursor - 1);
            if (index2 >= 0 && message.cursor > 0) {
                const emojiPart = message.data.substr(index2, message.cursor);
                if (emojiPart.length > 2) {
                    const emojis = EmojiJSON.emoji_json.filter(function (emoji) {
                        return emoji.name.includes(emojiPart) ||
                                emoji.shortname.includes(emojiPart) ||
                                emoji.aliases.some(a => a.includes(emojiPart))
                    })

                    emojiSuggestions.openPopup(emojis, emojiPart)
                }
                return true;
            }
        } else if (emojiEvent && !isKeyValid(event.key) && !isColonPressed) {
            return false;
        }
        return false;
    }

    // since emoji length is not 1 we need to match that position that TextArea returns
    // to the actual position in the string.
    function extrapolateCursorPosition() {
        // we need only the message part to be html
        const text = chatsModel.plainText(Emoji.deparse(txtData.text));
        const plainText = Emoji.parse(text, '26x26');

        var bracketEvent = false;
        var length = 0;

        for (var i = 0; i < plainText.length;) {
            if (length >= txtData.cursorPosition) break;

            if (!bracketEvent && plainText.charAt(i) !== '<')  {
                i++;
                length++;
            } else if (!bracketEvent && plainText.charAt(i) === '<') {
                bracketEvent = true;
                i++;
            } else if (bracketEvent && plainText.charAt(i) !== '>') {
                i++;
            } else if (bracketEvent && plainText.charAt(i) === '>') {
                bracketEvent = false;
                i++;
                length++;
            }
        }

        let textBeforeCursor = Emoji.deparseFromParse(plainText.substr(0, i));
        return {
            cursor: countEmojiLengths(plainText.substr(0, i)) + txtData.cursorPosition,
            data: Emoji.deparseFromParse(textBeforeCursor),
        };
    }

    function countEmojiLengths(value) {
        const match = Emoji.getEmojis(value);
        var length = 0;

        if (match && match.length > 0) {
            for (var i = 0; i < match.length; i++) {
                length += Emoji.deparseFromParse(match[i]).length;
            }
            length = length - match.length;
        }
        return length;
    }

    // check if user has placed cursor near valid emoji colon token
    function pollEmojiEvent(message) {
        const index = message.data.lastIndexOf(':', message.cursor);
        if (index >= 0) {
            emojiEvent = validSubstr(message.data.substr(index, message.cursor - index));
        }
    }

    function validSubstr(substr) {
        for(var i = 0; i < substr.length; i++) {
            var c = substr.charAt(i);
            if (c !== '_'  && (Utils.isSpace(c) === true || Utils.isPunct(c) === true)) {
                return false;
            }
        }
        return true;
    }

    function isKeyValid(key) {
        if (key !== Qt.Key_Underscore &&
                (key === Qt.Key_Space || key ===  Qt.Key_Tab ||
                (key >= Qt.Key_Exclam && key <= Qt.Key_Slash) ||
                (key >= Qt.Key_Semicolon && key <= Qt.Key_Question) ||
                (key >= Qt.Key_BracketLeft && key <= Qt.Key_hyphen)))
            return false;
        return true;
    }

    FileDialog {
        id: imageDialog
        //% "Please choose an image"
        title: qsTrId("please-choose-an-image")
        folder: shortcuts.pictures
        nameFilters: [
            //% "Image files (*.jpg *.jpeg *.png)"
            qsTrId("image-files----jpg---jpeg---png-")
        ]
        onAccepted: {
            chatColumn.showImageArea(imageDialog.fileUrls);
            txtData.forceActiveFocus();
        }
        onRejected: {
            chatColumn.hideExtendedArea();
        }
    }

    Popup {
        property var emojis
        property string shortname

        function openPopup(emojisParam, shortnameParam) {
            emojis = emojisParam
            shortname = shortnameParam
            emojiSuggestions.open()
        }

        function addEmoji(index) {
            if (index === undefined) {
                index = emojiList.currentIndex
            }

            const message = extrapolateCursorPosition();
            const unicode = emojiSuggestions.emojis[index].unicode_alternates || emojiSuggestions.emojis[index].unicode
            replaceWithEmoji(message, emojiSuggestions.shortname, unicode)
        }

        id: emojiSuggestions
        width: parent.width - Style.current.padding * 2
        height: Math.min(400, emojiList.contentHeight + Style.current.smallPadding * 2)
        x : Style.current.padding / 2
        y: -height - Style.current.smallPadding
        background: Rectangle {
            visible: !!emojiSuggestions.emojis && emojiSuggestions.emojis.length > 0
            color: Style.current.secondaryBackground
            border.width: 1
            border.color: Style.current.borderSecondary
            radius: 8
        }

        ListView {
            id: emojiList
            model: emojiSuggestions.emojis || []
            keyNavigationEnabled: true
            anchors.fill: parent
            clip: true

            delegate: Rectangle {
                id: rectangle
                color: emojiList.currentIndex === index ? Style.current.inputBorderFocus : Style.current.transparent
                border.width: 0
                width: parent.width
                height: 42
                radius: 8

                SVGImage {
                    id: emojiImage
                    source: `../../../../imports/twemoji/26x26/${modelData.unicode}.png`
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Style.current.smallPadding
                }

                StyledText {
                    text: modelData.shortname
                    color: emojiList.currentIndex === index ? Style.current.currentUserTextColor : Style.current.textColor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: emojiImage.right
                    anchors.leftMargin: Style.current.smallPadding
                    font.pixelSize: 15
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        emojiList.currentIndex = index
                    }
                    onClicked: {
                        emojiSuggestions.addEmoji(index)
                    }
                }
            }
        }
    }

    ScrollView {
        id: scrollView
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: sendBtns.left
        anchors.rightMargin: 0
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        topPadding: Style.current.padding

        StyledTArea {
            textFormat: Text.RichText
            id: txtData
            text: ""
            selectByMouse: true
            wrapMode: TextArea.Wrap
            font.pixelSize: 15
            //% "Type a message..."
            placeholderText: qsTrId("type-a-message")
            Keys.onPressed: onEnter(event)
            Keys.onReleased: onRelease(event) // gives much more up to date cursorPosition
            background: Rectangle {
                color: Style.current.transparent
            }

            TapHandler {
                id: mousearea
                onTapped: onMouseClicked()
            }
        }
    }

    StyledText {
        id: messageLengthLimit
        property int remainingChars: messageLimit - txtData.length
        text: remainingChars.toString()
        visible: remainingChars <= root.messageLimitVisible
        color: (remainingChars <= 0) ? Style.current.danger : Style.current.textColor
        anchors.right: parent.right
        anchors.bottom: sendBtns.top
        anchors.rightMargin: Style.current.padding
        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding
    }

    ChatButtons {
        id: sendBtns
        height: 36
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.bottom: parent.bottom
        addToChat: function (text, atCursor) {
            insertInTextInput(atCursor ? txtData.cursorPosition :txtData.length, text)
        }
        onSend: function(){
            if (txtData.length < messageLimit) {
                sendMsg(false);
                return;
            }
            messageTooLongDialog.open()
        }
    }

    MessageDialog {
        id: messageTooLongDialog
        //% "Your message is too long."
        title: qsTrId("your-message-is-too-long.")
        icon: StandardIcon.Critical
        //% "Please make your message shorter. We have set the limit to 2000 characters to be courteous of others."
        text: qsTrId("please-make-your-message-shorter.-we-have-set-the-limit-to-2000-characters-to-be-courteous-of-others.")
        standardButtons: StandardButton.Ok
    }
}
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
