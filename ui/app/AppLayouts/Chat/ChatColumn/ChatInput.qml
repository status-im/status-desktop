import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import QtQuick.Dialogs 1.0
import "../components"
import "../../../../shared"
import "../../../../imports"
import "../components/emojiList.js" as EmojiJSON

Rectangle {
    id: rectangle
    property alias textInput: txtData
    border.width: 0
    height: 52
    color: Style.current.transparent

    visible: chatsModel.activeChannel.chatType !== Constants.chatTypePrivateGroupChat || chatsModel.activeChannel.isMember(profileModel.profile.pubKey)

    property bool emojiEvent: false;

    Audio {
        id: sendMessageSound
        source: "../../../../sounds/send_message.wav"
        volume: 0.2
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
    }

    function onRelease(event) {
        emojiEvent = emojiHandler(emojiEvent, event);
    }

    function onMouseClicked() {
        emojiEvent = emojiHandler(emojiEvent, {key: null});
    }

    function emojiHandler(emojiEvent, event) {
        var msg = chatsModel.plainText(Emoji.deparse(txtData.text).trim());

        // check if user has placed cursor near valid emoji colon token
        var index = msg.lastIndexOf(':', txtData.cursorPosition);
        if (index > 0) {
            var substr = msg.substr(index, txtData.cursorPosition - index);
            console.log("MESSAGE: ", msg, txtData.cursorPosition, index, substr, validSubstr(substr));
            emojiEvent = validSubstr(substr)
        } 

        console.log("EVENT: ", event.key, Qt.Key_Colon, event.key === Qt.Key_Colon, emojiEvent);

        // state machine to handle different forms of the emoji event state
        if (emojiEvent === false && event.key === Qt.Key_Colon) {
            if (msg.length <= 1 || isSpace(msg.charAt(txtData.cursorPosition - 1)) === true) {
                return true;
            }
            return false;
        } else if (emojiEvent === true && event.key === Qt.Key_Colon) {
            var index = msg.lastIndexOf(':', txtData.cursorPosition - 2);
            if (index >= 0) {
                var shortname = msg.substr(index, txtData.cursorPosition);
                var codePoint = getEmojiUnicodeFromShortname(shortname);
                var newText = (codePoint !== undefined) ? Emoji.fromCodePoint(codePoint) : shortname;

                txtData.remove(index, txtData.cursorPosition);
                txtData.insert(index, newText);

                if (event) event.accepted = true;
                return false;
            }
            return true;
        } else if (emojiEvent === true && isKeyValid(event.key) === true) {
            console.log('popup');
            return true;
        } 

        else if (emojiEvent === true && isKeyValid(event.key) === false) {
            console.log('emoji event stopped');
            return false;
        }

        return false;
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
        {
            return false;
        }
        return true;
    }

    function isSpace(c) {
        if (/( |\t|\n|\r)/.test(c))
            return true
        return false
    }

    function isPunct(c) {
        if (/(!|\@|#|\$|%|\^|&|\*|\(|\)|_|\+|\||-|=|\\|{|}|[|]|"|;|'|<|>|\?|,|\.|\/)/.test(c))
            return true;
        return false;
    }

    function isKeyAlpha(key) {
        if (key >= Qt.Key_A && key <= Qt.Key_Z)
            return true;
        return false;
    }

    function isKeyDigit(key) {
        if (key >= Qt.Key_0 && key <= Qt.Key_9)
            return true;
        return false;
    }

    // search for shortname
    function getEmojiUnicodeFromShortname(shortname) {
        var _emoji;
        EmojiJSON.emoji_json.forEach(function(emoji) {
            if (emoji.shortname === shortname)
                _emoji = emoji;
        })

        if (_emoji !== undefined)
            return _emoji.unicode;
        return undefined;
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
        addToChat: function (text) {
            txtData.insert(txtData.length, text)
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
