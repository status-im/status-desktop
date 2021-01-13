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
    signal sendMessage(var event)

    property bool emojiEvent: false;
    property bool paste: false;
    property bool isColonPressed: false;
    property bool isReply: false
    property bool isImage: false

    property var recentStickers
    property var stickerPackList

    property int extraHeightFactor: calculateExtraHeightFactor()
    property int messageLimit: control.isStatusUpdateInput ? 300 : 2000
    property int messageLimitVisible: control.isStatusUpdateInput ? 50 : 200

    property int chatType

    property string chatInputPlaceholder: qsTr("Type a message.")

    property alias textInput: messageInputField
    property bool isStatusUpdateInput: chatType === Constants.chatTypeStatusUpdate

    property var fileUrls: []
    property alias messageSound: sendMessageSound

    property alias suggestionsList: suggestions

    height: {
        if (extendedArea.visible) {
            return messageInput.height + extendedArea.height + (control.isStatusUpdateInput ? 0 : Style.current.bigPadding)
        }
        if (messageInput.height > messageInput.defaultInputFieldHeight) {
            if (messageInput.height >= messageInput.maxInputFieldHeight) {
                return messageInput.maxInputFieldHeight + (control.isStatusUpdateInput ? 0 : Style.current.bigPadding)
            }
            return messageInput.height + (control.isStatusUpdateInput ? 0 : Style.current.bigPadding)
        }
        return control.isStatusUpdateInput ? 56 : 64
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

    property var interpretMessage: function (msg)  {
        if (msg.startsWith("/shrug")) {
            return  msg.replace("/shrug", "") + " ¯\\\\\\_(ツ)\\_/¯"
        }
        if (msg.startsWith("/tableflip")) {
            return msg.replace("/tableflip", "") + " (╯°□°）╯︵ ┻━┻"
        }

        return msg
    }

    function isUploadFilePressed(event) {
        return (event.key === Qt.Key_U) && (event.modifiers & Qt.ControlModifier) && imageBtn.visible && !imageDialog.visible
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
            if (control.isStatusUpdateInput) {
                return // Status update require the send button to be clicked
            }
            if (messageInputField.length < messageLimit) {
                control.sendMessage(event)
                control.hideExtendedArea();
                return;
            }
            if(event) event.accepted = true
            messageTooLongDialog.open()
        }

        const message = control.extrapolateCursorPosition();

        // handle new line in blockquote
        if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return) && (event.modifiers & Qt.ShiftModifier) && message.data.startsWith(">")) {
            if(message.data.startsWith(">") && !message.data.endsWith("\n\n")) {
                let newMessage = ""
                if (message.data.endsWith("\n> ")) {
                    newMessage = message.data.substr(0, message.data.lastIndexOf("> ")) + "\n\n"
                } else {
                    newMessage = message.data + "\n> ";
                }
                messageInputField.remove(0, messageInputField.cursorPosition);
                insertInTextInput(0, Emoji.parse(newMessage));
            }
            event.accepted = true
        }
        // handle backspace when entering an existing blockquote
        if ((event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete)) {
            if(message.data.startsWith(">") && message.data.endsWith("\n\n")) {
                const newMessage = message.data.substr(0, message.data.lastIndexOf("\n")) + "> ";
                messageInputField.remove(0, messageInputField.cursorPosition);
                insertInTextInput(0, Emoji.parse(newMessage));
                event.accepted = true
            }
        }

        if ((event.key === Qt.Key_V) && (event.modifiers & Qt.ControlModifier)) {
            paste = true;
        }

        // ⌘⇧U
        if (isUploadFilePressed(event)) {
            imageBtn.clicked()
            event.accepted = true
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

    function wrapSelection(wrapWith) {
        if (messageInputField.selectionStart - messageInputField.selectionEnd === 0) return
        insertInTextInput(messageInputField.selectionStart, wrapWith);
        insertInTextInput(messageInputField.selectionEnd, wrapWith);
        messageInputField.deselect()
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

        let madeChanges = false
        let transform = true;
        for (var i = 0; i < words.length; i++) {
            transform = true;
            if (words[i].charAt(0) === ':') {
                for (var j = 0; j < words[i].length; j++) {
                    if (Utils.isSpace(words[i].charAt(j)) === true || Utils.isPunct(words[i].charAt(j)) === true) {
                        transform = false;
                    }
                }

                if (transform) {
                    madeChanges = true
                    const codePoint = Emoji.getEmojiUnicode(words[i]);
                    words[i] = words[i].replace(words[i], (codePoint !== undefined) ? Emoji.fromCodePoint(codePoint) : words[i]);
                }
            }
        }

        if (madeChanges) {
            messageInputField.remove(0, messageInputField.length);
        insertInTextInput(0, Emoji.parse(words.join('&nbsp;')));
        }
    }

    // since emoji length is not 1 we need to match that position that TextArea returns
    // to the actual position in the string. 
    function extrapolateCursorPosition() {
        // we need only the message part to be html
        const text = chatsModel.plainText(Emoji.deparse(messageInputField.text));
        const plainText = Emoji.parse(text);

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
        insertInTextInput(0, Emoji.parse(newMessage));
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

    function hideExtendedArea() {
        isImage = false;
        isReply = false;
        control.fileUrls = []
        imageArea.imageSource = "";
        replyArea.userName = ""
        replyArea.identicon = ""
        replyArea.message = ""
    }

    function showImageArea(imagePath) {
        isImage = true;
        isReply = false;
        control.fileUrls = imageDialog.fileUrls
        imageArea.imageSource = control.fileUrls[0]
    }

    function showReplyArea(userName, message, identicon) {
        isReply = true
        replyArea.userName = userName
        replyArea.message = message
        replyArea.identicon = identicon
        messageInputField.forceActiveFocus();
    }

    ListModel {
        id: suggestions
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
            imageBtn2.highlighted = false
            control.showImageArea()
            messageInputField.forceActiveFocus();
        }
        onRejected: {
            imageBtn.highlighted = false
            imageBtn2.highlighted = false
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
        property: "ensName, localNickname, alias"
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

            messageInputField.text = hasEmoji ? Emoji.parse(text) : text
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
        x: parent.width - width - Style.current.halfPadding
        y: -height
        enabled: !!control.recentStickers && !!control.stickerPackList
        recentStickers: control.recentStickers
        stickerPackList: control.stickerPackList
        onStickerSelected: {
            control.stickerSelected(hashId, packId)
            messageInputField.forceActiveFocus();
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
        visible: control.chatType === Constants.chatTypeOneToOne && !control.isStatusUpdateInput
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
        visible: control.chatType !== Constants.chatTypePublic && !control.isStatusUpdateInput

        onClicked: {
            highlighted = true
            imageDialog.open()
        }
    }

    Rectangle {
        id: messageInput
        property int maxInputFieldHeight: control.isStatusUpdateInput ? 123 : 112
        property int defaultInputFieldHeight: control.isStatusUpdateInput ? 56 : 40
        anchors.left: imageBtn.visible ? imageBtn.right : parent.left
        anchors.leftMargin: imageBtn.visible ? 5 : Style.current.smallPadding
        anchors.top: control.isStatusUpdateInput ? parent.top : undefined
        anchors.bottom: !control.isStatusUpdateInput ? parent.bottom : undefined
        anchors.bottomMargin: control.isStatusUpdateInput ? 0 : 12
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        height: scrollView.height
        color: Style.current.inputBackground
        radius: control.isStatusUpdateInput ? 36 :
          height > defaultInputFieldHeight + 1 || extendedArea.visible ? 16 : 32

        Rectangle {
            id: extendedArea
            visible: isImage || isReply
            height: {
              if (visible) {
                  if (isImage) {
                      return imageArea.height + Style.current.halfPadding
                  }

                  if (isReply) {
                      return replyArea.height + replyArea.anchors.topMargin
                  }
              }
              return 0
            }
            anchors.left: messageInput.left
            anchors.right: messageInput.right
            anchors.bottom: control.isStatusUpdateInput ? undefined : messageInput.top
            anchors.top: control.isStatusUpdateInput ? messageInput.bottom : undefined
            anchors.topMargin: control.isStatusUpdateInput ? -Style.current.halfPadding : 0
            color: Style.current.inputBackground
            radius: control.isStatusUpdateInput ? 36 : 16

            Rectangle {
                color: parent.color
                anchors.right: parent.right
                anchors.left: parent.left
                height: control.isStatusUpdateInput ? 64 : 30
                anchors.top: control.isStatusUpdateInput ? parent.top : undefined
                anchors.topMargin: control.isStatusUpdateInput ? -24 : 0
                anchors.bottom: control.isStatusUpdateInput ? undefined : parent.bottom
                anchors.bottomMargin: control.isStatusUpdateInput ? 0 : -height/2
            }

            StatusChatInputImageArea {
                id: imageArea
                anchors.left: parent.left
                anchors.leftMargin: control.isStatusUpdateInput ? profileImage.width + Style.current.padding : Style.current.halfPadding
                anchors.right: parent.right
                anchors.rightMargin: control.isStatusUpdateInput ? actions.width + 2* Style.current.padding : Style.current.halfPadding
                anchors.top: parent.top
                anchors.topMargin: control.isStatusUpdateInput ? 0 : Style.current.halfPadding
                visible: isImage
                onImageRemoved: {
                    control.fileUrls = []
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

        StatusImageIdenticon {
            id: profileImage
            source: profileModel.profile.identicon
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: parent.top
            anchors.topMargin: Style.current.halfPadding
            visible: control.isStatusUpdateInput
        }

        ScrollView {
            id: scrollView
            anchors.bottom: parent.bottom
            anchors.left: profileImage.visible ? profileImage.right : parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.right: actions.left
            anchors.rightMargin: Style.current.halfPadding
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
                height: parent.height
                placeholderText: qsTr("Type a message")
                placeholderTextColor: Style.current.secondaryText
                selectByMouse: true
                color: Style.current.textColor
                topPadding: Style.current.smallPadding
                bottomPadding: 12
                Keys.onPressed: onKeyPress(event)
                Keys.onReleased: onRelease(event) // gives much more up to date cursorPosition
                Keys.onShortcutOverride: event.accepted = isUploadFilePressed(event)
                leftPadding: 0
                background: Rectangle {
                    color: "transparent"
                }
            }
            Action {
                shortcut: StandardKey.Bold
                onTriggered: wrapSelection("**")
            }
            Action {
                shortcut: StandardKey.Italic
                onTriggered: wrapSelection("*")
            }
            Action {
                shortcut: "Ctrl+Shift+Alt+C"
                onTriggered: wrapSelection("```")
            }
            Action {
                shortcut: "Ctrl+Shift+C"
                onTriggered: wrapSelection("`")
            }
            Action {
                shortcut: "Ctrl+Alt+-"
                onTriggered: wrapSelection("~~")
            }
            Action {
                shortcut: "Ctrl+Shift+X"
                onTriggered: wrapSelection("~~")
            }
            Action {
                shortcut: "Ctrl+Meta+Space"
                onTriggered: emojiBtn.clicked()
            }
        }

        Rectangle {
            color: parent.color
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            visible: !control.isStatusUpdateInput
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
            anchors.rightMargin: control.isStatusUpdateInput ? Style.current.padding : Style.current.radius
            leftPadding: Style.current.halfPadding
            rightPadding: Style.current.halfPadding
        }

        Item {
            id: actions
            width: control.isStatusUpdateInput ?
              imageBtn2.width + sendBtn.anchors.leftMargin + sendBtn.width :
              emojiBtn.width + stickersBtn.anchors.leftMargin + stickersBtn.width
            anchors.bottom: control.isStatusUpdateInput && extendedArea.visible ? extendedArea.bottom : parent.bottom
            anchors.bottomMargin: control.isStatusUpdateInput ? Style.current.smallPadding+2: 4
            anchors.right: parent.right
            anchors.rightMargin: Style.current.radius
            height: emojiBtn.height

            StatusIconButton {
                id: imageBtn2
                icon.name: "images_icon"
                icon.height: 18
                icon.width: 20
                anchors.right: sendBtn.left
                anchors.rightMargin: 2
                anchors.bottom: parent.bottom
                visible: control.isStatusUpdateInput

                onClicked: {
                    highlighted = true
                    imageDialog.open()
                }
            }

            StatusButton {
                id: sendBtn
                icon.source: "../../app/img/send.svg"
                color: Style.current.secondaryText
                icon.width: 16
                icon.height: 18
                text: qsTr("Send")
                flat: true
                anchors.right: parent.right
                anchors.rightMargin: Style.current.halfPadding
                anchors.bottom: parent.bottom
                visible: imageBtn2.visible
                highlighted: chatsModel.plainText(Emoji.deparse(messageInputField.text)).length > 0 || isImage
                enabled: highlighted && messageInputField.length < messageLimit
                onClicked: function (event) {
                    control.sendMessage(event)
                    control.hideExtendedArea();
                }
            }

            StatusIconButton {
                id: emojiBtn
                visible: !imageBtn2.visible
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
                visible: profileModel.network.current === Constants.networkMainnet && emojiBtn.visible
                width: visible ? 32 : 0
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
