import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import QtQuick.Dialogs 1.0
import "../components"
import "../../../../shared"
import "../../../../imports"

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

    Audio {
        id: sendMessageSound
        source: "../../../../sounds/send_message.wav"
        volume: appSettings.volume
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
            chatsModel.sendImage(sendImageArea.image);
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
            sendMsg(event);
        }

        if ((event.key === Qt.Key_V) && (event.modifiers & Qt.ControlModifier)) {
            paste = true;
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
                    if (isSpace(words[i].charAt(j)) === true || isPunct(words[i].charAt(j)) === true) {
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

    function emojiHandler(event) {
        let message = extrapolateCursorPosition();
        pollEmojiEvent(message);

        // state machine to handle different forms of the emoji event state
        if (!emojiEvent && isColonPressed) {
            return (message.data.length <= 1 || isSpace(message.data.charAt(message.cursor - 1))) ? true : false;
        } else if (emojiEvent && isColonPressed) {
            const index = message.data.lastIndexOf(':', message.cursor - 2);
            if (index >= 0 && message.cursor > 0) {
                const shortname = message.data.substr(index, message.cursor);
                const codePoint = Emoji.getEmojiUnicode(shortname);
                if (codePoint !== undefined) {
                    const newMessage = message.data
                        .replace(shortname, Emoji.fromCodePoint(codePoint))
                        .replace(/ /g, "&nbsp;");
                    txtData.remove(0, txtData.cursorPosition);
                    insertInTextInput(0, Emoji.parse(newMessage, '26x26'));
                }
                return false;
            }
            return true;
        } else if (emojiEvent && isKeyValid(event.key) && !isColonPressed) {
            // popup
            return true;
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
            if (isSpace(c) === true || isPunct(c) === true)
                return false;
        }
        return true;
    }

    function isKeyValid(key) {
        if (key === Qt.Key_Space || key ===  Qt.Key_Tab ||
            (key >= Qt.Key_Exclam && key <= Qt.Key_Slash) || 
            (key >= Qt.Key_Semicolon && key <= Qt.Key_Question) ||
            (key >= Qt.Key_BracketLeft && key <= Qt.Key_hyphen))
            return false;
        return true;
    }

    function isSpace(c) {
        if (/( |\t|\n|\r)/.test(c))
            return true;
        return false;
    }

    function isPunct(c) {
        if (/(!|\@|#|\$|%|\^|&|\*|\(|\)|_|\+|\||-|=|\\|{|}|[|]|"|;|'|<|>|\?|,|\.|\/)/.test(c))
            return true;
        return false;
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

    ChatButtons {
        id: sendBtns
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        addToChat: function (text, atCursor) {
            insertInTextInput(atCursor ? txtData.cursorPosition :txtData.length, text)
        }
        onSend: function(){
            sendMsg(false)
        }
    }
}
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
