import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import QtQuick.Dialogs 1.3
import "../../imports"
import "../../shared"
import "../../app/AppLayouts/Chat/ChatColumn/samples"
import "../../app/AppLayouts/Chat/ChatColumn"

import "./emojiList.js" as EmojiJSON

Rectangle {
    id: control
    signal sendTransactionCommandButtonClicked()
    signal receiveTransactionCommandButtonClicked()
    signal stickerSelected(string hashId, string packId)

    property bool emojiEvent: false;
    property bool paste: false;
    property bool isColonPressed: false;
    property bool isReply: false
    property bool isImage: false

    property var recentStickers: StickerData {}
    property var stickerPackList: StickerPackData {}

    property int extraHeightFactor: calculateExtraHeightFactor()
    property int messageLimit: 2000
    property int messageLimitVisible: 200

    property int chatType

    property alias textInput: messageInputField

    height: {
        if (extendedArea.visible) {
            return messageInput.height + extendedArea.height + Style.current.bigPadding
        }
        if (messageInput.height > messageInput.defaultInputFieldHeight) {
            if (messageInput.height >= messageInput.maxInputFieldHeight) {
                return messageInput.maxInputFieldHeight + Style.current.bigPadding
            }
            return messageInput.height + Style.current.bigPadding
        }
        return 64
    }
    anchors.left: parent.left
    anchors.right: parent.right

    color: Style.current.background

    Audio {
        id: sendMessageSound
        source: "../../sounds/send_message.wav"
        volume: appSettings.volume
        muted: !appSettings.notificationSoundsEnabled
    }

    function calculateExtraHeightFactor() {
        const factor = (messageInputField.length / 500) + 1;
        return (factor > 5) ? 5 : factor;
    }

    function insertInTextInput(start, text) {
        // Repace new lines with entities because `insert` gets rid of them
        messageInputField.insert(start, text.replace(/\n/g, "<br/>"));
    }

    function interpretMessage(msg) {
        if (msg.startsWith("/shrug")) {
            return  msg.replace("/shrug", "") + " ¯\\\\\\_(ツ)\\_/¯"
        }
        if (msg.startsWith("/tableflip")) {
            return msg.replace("/tableflip", "") + " (╯°□°）╯︵ ┻━┻"
        }

        return msg
    }

    function onKeyPress(event){
        if (event.modifiers === Qt.NoModifier && (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
            if (emojiSuggestions.visible) {
                emojiSuggestions.addEmoji();
                event.accepted = true;
                return
            }
            if (suggestionsBox.visible) {
                suggestionsBox.selectCurrentItem();
                event.accepted = true;
                return
            }
            if (messageInputField.length < messageLimit) {
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
            suggestionsBox.listView.incrementCurrentIndex()
            return emojiSuggestions.listView.incrementCurrentIndex()
        }
        if (event.key === Qt.Key_Up) {
            suggestionsBox.listView.decrementCurrentIndex()
            return emojiSuggestions.listView.decrementCurrentIndex()
        }
        if (event.key === Qt.Key_Escape) {
            suggestionsBox.hide()
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

        if (event.key !== Qt.Key_Escape) {
            emojiEvent = emojiHandler(event);
            if (!emojiEvent) {
                emojiSuggestions.close()
            }
        }
    }

    function interrogateMessage() {
        const text = chatsModel.plainText(Emoji.deparse(messageInputField.text));
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

        messageInputField.remove(0, messageInputField.length);
        insertInTextInput(0, Emoji.parse(words.join('&nbsp;'), '26x26'));
    }

    // since emoji length is not 1 we need to match that position that TextArea returns
    // to the actual position in the string. 
    function extrapolateCursorPosition() {
        // we need only the message part to be html
        const text = chatsModel.plainText(Emoji.deparse(messageInputField.text));
        const plainText = Emoji.parse(text, '26x26');

        var bracketEvent = false;
        var length = 0;

        for (var i = 0; i < plainText.length;) {
            if (length >= messageInputField.cursorPosition) break;

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
            cursor: countEmojiLengths(plainText.substr(0, i)) + messageInputField.cursorPosition,
            data: Emoji.deparseFromParse(textBeforeCursor),
        };
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

    function replaceWithEmoji(message, shortname, codePoint) {
        const encodedCodePoint = Emoji.getEmojiCodepoint(codePoint)
        const newMessage = message.data
            .replace(shortname, encodedCodePoint)
            .replace(/ /g, "&nbsp;");
        messageInputField.remove(0, messageInputField.cursorPosition);
        insertInTextInput(0, Emoji.parse(newMessage, '26x26'));
        emojiSuggestions.close()
        emojiEvent = false
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
            if (Utils.isSpace(c) === true || Utils.isPunct(c) === true)
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

    function sendMsg(event){
        if(control.isImage){
            chatsModel.sendImage(imageArea.imageSource);
        }
        var msg = chatsModel.plainText(Emoji.deparse(messageInputField.text).trim()).trim()
        if(msg.length > 0){
            msg = interpretMessage(msg)
            chatsModel.sendMessage(msg, control.isReply ? SelectedMessage.messageId : "", Utils.isOnlyEmoji(msg) ? Constants.emojiType : Constants.messageType);
            messageInputField.text = "";
            if(event) event.accepted = true
            sendMessageSound.stop()
            Qt.callLater(sendMessageSound.play);
        }
        control.hideExtendedArea();
    }

    function hideExtendedArea() {
        isImage = false;
        isReply = false;
        imageArea.imageSource = "";
        replyArea.userName = ""
        replyArea.identicon = ""
        replyArea.message = ""
    }

    function showImageArea(imagePath) {
        isImage = true;
        isReply = false;
        imageArea.imageSource = imageDialog.fileUrls[0]
    }

    function showReplyArea(userName, message, identicon) {
        isReply = true
        replyArea.userName = userName
        replyArea.message = message
        replyArea.identicon = identicon
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
            imageBtn.highlighted = false
            control.showImageArea()
            messageInputField.forceActiveFocus();
        }
        onRejected: {
            imageBtn.highlighted = false
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

    StatusEmojiSuggestionPopup {
        id: emojiSuggestions
    }

    SuggestionBox {
        id: suggestionsBox
        model: suggestions
        x : messageInput.x
        y: -height - Style.current.smallPadding
        width: messageInput.width
        filter: messageInputField.text
        cursorPosition: messageInputField.cursorPosition
        property: "ensName, alias"
        onItemSelected: function (item, lastAtPosition, lastCursorPosition) {
            let hasEmoji = Emoji.hasEmoji(messageInputField.text)
            let currentText = hasEmoji ?
              chatsModel.plainText(Emoji.deparse(messageInputField.text)) :
              chatsModel.plainText(messageInputField.text);

            let aliasName = item[suggestionsBox.property.split(",").map(p => p.trim()).find(p => !!item[p])]
            aliasName = aliasName.replace(/(\.stateofus)?\.eth/, "")
            let nameLen = aliasName.length + 2 // We're doing a +2 here because of the `@` and the trailing whitespace
            let position = 0;
            let text = ""

            if (currentText === "@") {
                position = nameLen
                text = "@" + aliasName + " "
            } else {
                let left = currentText.substring(0, lastAtPosition)
                let right = currentText.substring(hasEmoji ? lastCursorPosition + 2 : lastCursorPosition)
                text = `${left} @${aliasName} ${right}`
            }

            messageInputField.text = hasEmoji ? Emoji.parse(text, "26x26") : text
            messageInputField.cursorPosition = lastAtPosition + aliasName.length + 2
            suggestionsBox.suggestionsModel.clear()
        }
    }

    StatusChatCommandsPopup {
        id: chatCommandsPopup
        x: 8
        y: -height
        onSendTransactionCommandButtonClicked: {
            control.sendTransactionCommandButtonClicked()
            chatCommandsPopup.close()
        }
        onReceiveTransactionCommandButtonClicked: {
            control.receiveTransactionCommandButtonClicked()
            chatCommandsPopup.close()
        }
        onClosed: {
            chatCommandsBtn.highlighted = false
        }
    }

    StatusEmojiPopup {
        id: emojiPopup
        width: 360
        height: 440
        x: parent.width - width - Style.current.halfPadding
        y: -height
        emojiSelected: function (text, atCursor) {
            insertInTextInput(atCursor ? messageInputField.cursorPosition : messageInputField.length, text)
            emojiBtn.highlighted = false
            messageInputField.forceActiveFocus();
        }
        onClosed: {
            emojiBtn.highlighted = false
        }
    }

    StatusStickersPopup {
        id: stickersPopup
        width: 360
        height: 440
        x: parent.width - width - Style.current.halfPadding
        y: -height
        recentStickers: control.recentStickers
        stickerPackList: control.stickerPackList
        onStickerSelected: {
            control.stickerSelected(hashId, packId)
            messageInputField.forceActiveFocus();
            stickersPopup.close()
        }
        onClosed: {
            stickersBtn.highlighted = false
        }
    }

    StatusIconButton {
        id: chatCommandsBtn
        icon.name: "chat-commands"
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        visible: control.chatType === Constants.chatTypeOneToOne
        onClicked: {
            highlighted = true
            chatCommandsPopup.open()
        }
    }

    StatusIconButton {
        id: imageBtn
        icon.name: "images_icon"
        icon.height: 18
        icon.width: 20
        anchors.left: chatCommandsBtn.visible ? chatCommandsBtn.right : parent.left
        anchors.leftMargin: chatCommandsBtn.visible ? 2 : 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        visible: control.chatType !== Constants.chatTypePublic

        onClicked: {
            highlighted = true
            imageDialog.open()
        }
    }

    Rectangle {
        id: extendedArea
        visible: isImage || isReply
        height: {
          if (visible) {
              if (isImage) {
                  return imageArea.height
              }

              if (isReply) {
                  return replyArea.height + replyArea.anchors.topMargin
              }
          }
          return 0
        }
        anchors.left: messageInput.left
        anchors.right: messageInput.right
        anchors.bottom: messageInput.top
        color: Style.current.inputBackground
        radius: 16

        Rectangle {
            height: 16
            color: parent.color
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        StatusChatInputImageArea {
            id: imageArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            visible: isImage
            onImageRemoved: {
                isImage = false
            }
        }

        StatusChatInputReplyArea {
            id: replyArea
            visible: isReply
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.top: parent.top
            anchors.topMargin: 2
            onCloseButtonClicked: {
                isReply = false
            }
        }
    }

    Rectangle {
        id: messageInput
        property int maxInputFieldHeight: 112
        property int defaultInputFieldHeight: 40
        anchors.left: imageBtn.visible ? imageBtn.right : parent.left
        anchors.leftMargin: imageBtn.visible ? 5 : Style.current.smallPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        height: scrollView.height
        color: Style.current.inputBackground
        radius: height > defaultInputFieldHeight || extendedArea.visible ? 16 : 32

        Rectangle {
            color: parent.color
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            height: 18
            visible: extendedArea.visible
        }

        ScrollView {
            id: scrollView
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.right: actions.left
            anchors.rightMargin: 0
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            height: {
                if (messageInputField.implicitHeight <= messageInput.defaultInputFieldHeight) {
                    return messageInput.defaultInputFieldHeight
                }
                if (messageInputField.implicitHeight >= messageInput.maxInputFieldHeight) {
                    return messageInput.maxInputFieldHeight
                }
                return messageInputField.implicitHeight
            }

            TextArea {
                id: messageInputField
                textFormat: Text.RichText
                verticalAlignment: TextEdit.AlignVCenter
                font.pixelSize: 15
                font.family: Style.current.fontRegular.name
                wrapMode: TextArea.Wrap
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                placeholderText: qsTr("Type a message")
                placeholderTextColor: Style.current.secondaryText
                selectByMouse: true
                color: Style.current.textColor
                topPadding: Style.current.smallPadding
                bottomPadding: 12
                Keys.onPressed: onKeyPress(event)
                Keys.onReleased: onRelease(event) // gives much more up to date cursorPosition
                leftPadding: 0
                background: Rectangle {
                    color: "transparent"
                }
            }
        }

        Rectangle {
            color: parent.color
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            height: parent.height / 2
            width: 32
            radius: Style.current.radius
        }

        StyledText {
            id: messageLengthLimit
            property int remainingChars: messageLimit - messageInputField.length
            text: remainingChars.toString()
            visible: remainingChars <= control.messageLimitVisible
            color: (remainingChars <= 0) ? Style.current.danger : Style.current.textColor
            anchors.right: parent.right
            anchors.bottom: actions.top
            anchors.rightMargin: Style.current.radius
            leftPadding: Style.current.halfPadding
            rightPadding: Style.current.halfPadding
        }

        Item {
            id: actions
            width: childrenRect.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: Style.current.radius
            height: emojiBtn.height

            StatusIconButton {
                id: emojiBtn
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                icon.name: "emojiBtn"
                type: "secondary"
                onClicked: {
                    stickersPopup.close()
                    if (emojiPopup.opened) {
                        emojiPopup.close()
                        highlighted = false
                    } else {
                        emojiPopup.open()
                        highlighted = true
                    }
                }
            }

            StatusIconButton {
                id: stickersBtn
                anchors.left: emojiBtn.right
                anchors.leftMargin: 2
                anchors.bottom: parent.bottom
                icon.name: "stickers_icon"
                type: "secondary"
                onClicked: {
                    emojiPopup.close()
                    if (stickersPopup.opened) {
                        stickersPopup.close()
                        highlighted = false
                    } else {
                        stickersPopup.open()
                        highlighted = true
                    }
                }
            }
        }
    }
}
