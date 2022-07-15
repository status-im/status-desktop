import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import QtQuick.Dialogs 1.3
import DotherSide 0.1

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0

//TODO remove this dependency
import AppLayouts.Chat.panels 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1 as StatusQ

Rectangle {
    id: control
    signal sendTransactionCommandButtonClicked()
    signal receiveTransactionCommandButtonClicked()
    signal stickerSelected(string hashId, string packId)
    signal sendMessage(var event)
    signal unblockChat()

    property var usersStore
    property var store

    property var emojiPopup: null
    // Use this to only enable the Connections only when this Input opens the Emoji popup
    property bool emojiPopupOpened: false
    property bool closeGifPopupAfterSelection: true

    property bool emojiEvent: false;
    property bool paste: false;
    property bool isColonPressed: false;
    property bool isReply: false
    property string replyMessageId: replyArea.messageId

    property bool isImage: false
    property bool isEdit: false
    property bool isContactBlocked: false
    property bool isActiveChannel: false

    property var recentStickers
    property var stickerPackList

    property int extraHeightFactor: calculateExtraHeightFactor()
    property int messageLimit: control.isStatusUpdateInput ? 300 : 2000
    property int messageLimitVisible: control.isStatusUpdateInput ? 50 : 200

    property int chatType

    property string chatInputPlaceholder: qsTr("Message")

    property alias textInput: messageInputField
    property bool isStatusUpdateInput: chatType === Constants.chatType.profile

    property var fileUrls: []

    property var imageErrorMessageLocation: StatusChatInput.ImageErrorMessageLocation.Top

    property var messageContextMenu

    property alias suggestions: suggestionsBox

    enum ImageErrorMessageLocation {
        Top,
        Bottom
    }

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

    color: Style.current.transparent

    function calculateExtraHeightFactor() {
        const factor = (messageInputField.length / 500) + 1;
        return (factor > 5) ? 5 : factor;
    }

    function insertInTextInput(start, text) {
        // Repace new lines with entities because `insert` gets rid of them
        messageInputField.insert(start, text.replace(/\n/g, "<br/>"));
    }

    function togglePopup(popup, btn) {
        if (popup !== stickersPopup) {
            stickersPopup.close()
        }

        if (popup !== gifPopup) {
            gifPopup.close()
        }

        if (popup !== emojiPopup) {
            emojiPopup.close()
        }

        if (popup.opened) {
            popup.close()
            btn.highlighted = false
        } else {
            popup.open()
            btn.highlighted = true
        }
    }

    Connections {
        enabled: control.emojiPopupOpened
        target: emojiPopup

        onEmojiSelected: function (text, atCursor) {
            insertInTextInput(atCursor ? messageInputField.cursorPosition : messageInputField.length, text)
            emojiBtn.highlighted = false
            messageInputField.forceActiveFocus();
        }
        onClosed: {
            emojiBtn.highlighted = false
            control.emojiPopupOpened = false
        }
    }

    property var mentionsPos: []

    function insertMention(aliasName, lastAtPosition, lastCursorPosition) {
        let startInd = aliasName.indexOf("(");
        if (startInd > 0){
            aliasName = aliasName.substring(0, startInd-1)
        }

        const hasEmoji = StatusQUtils.Emoji.hasEmoji(messageInputField.text)
        const spanPlusAlias = `${Constants.mentionSpanTag}@${aliasName}</a></span> `;

        let rightIndex = hasEmoji ? lastCursorPosition + 2 : lastCursorPosition
        messageInputField.remove(lastAtPosition, rightIndex)
        messageInputField.insert(lastAtPosition, spanPlusAlias)
        messageInputField.cursorPosition = lastAtPosition + aliasName.length + 2;
        if (messageInputField.cursorPosition === 0) {
            // It reset to 0 for some reason, go back to the end
            messageInputField.cursorPosition = messageInputField.length
        }
        mentionsPos.push({"name": aliasName,"leftIndex": lastAtPosition, "rightIndex": (lastAtPosition+aliasName.length+1)});
    }

    function isUploadFilePressed(event) {
        return (event.key === Qt.Key_U) && (event.modifiers & Qt.ControlModifier) && imageBtn.visible && !imageDialog.visible
    }

    function checkTextInsert() {
        if (emojiSuggestions.visible) {
            replaceWithEmoji(extrapolateCursorPosition(), emojiSuggestions.shortname, emojiSuggestions.unicode);
            return true
        }
        if (suggestionsBox.visible) {
            suggestionsBox.selectCurrentItem();
            return true
        }
        return false
    }

    function onKeyPress(event) {
        if (event.modifiers === Qt.NoModifier && (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
            if (checkTextInsert()) {
                event.accepted = true;
                return
            }

            if (control.isStatusUpdateInput) {
                return // Status update require the send button to be clicked
            }
            if (messageInputField.length < messageLimit) {
                control.sendMessage(event)
                control.hideExtendedArea();
                event.accepted = true
                return;
            }
            if (event) {
                event.accepted = true
                messageTooLongDialog.open()
            }
        }

        if (event.key === Qt.Key_Tab) {
            if (checkTextInsert()) {
                event.accepted = true;
                return
            }
        }

        const message = control.extrapolateCursorPosition();

        // handle new line in blockquote
        if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return) && (event.modifiers & Qt.ShiftModifier) && message.data.startsWith(">")) {
            if(message.data.startsWith(">") && !message.data.endsWith("\n\n")) {
                let newMessage1 = ""
                if (message.data.endsWith("\n> ")) {
                    newMessage1 = message.data.substr(0, message.data.lastIndexOf("> ")) + "\n\n"
                } else {
                    newMessage1 = message.data + "\n> ";
                }
                messageInputField.remove(0, messageInputField.cursorPosition);
                insertInTextInput(0, StatusQUtils.Emoji.parse(newMessage1));
            }
            event.accepted = true
        }
        // handle backspace when entering an existing blockquote
        if ((event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete)) {
            if(message.data.startsWith(">") && message.data.endsWith("\n\n")) {
                const newMessage = message.data.substr(0, message.data.lastIndexOf("\n")) + "> ";
                messageInputField.remove(0, messageInputField.cursorPosition);
                insertInTextInput(0, StatusQUtils.Emoji.parse(newMessage));
                event.accepted = true
            }
        }

        if ((event.key === Qt.Key_C) && (event.modifiers & Qt.ControlModifier)) {
            if (messageInputField.selectedText !== "") {
                copiedTextPlain = messageInputField.getText(messageInputField.selectionStart, messageInputField.selectionEnd);
                copiedTextFormatted = messageInputField.getFormattedText(messageInputField.selectionStart, messageInputField.selectionEnd);
            }
        }

        if ((event.key === Qt.Key_V) && (event.modifiers & Qt.ControlModifier)) {
            if (copiedTextPlain === QClipboardProxy.text) {
                copyTextStart = messageInputField.cursorPosition;
                paste = true;
            } else {
                copiedTextPlain = "";
                copiedTextFormatted = "";
            }
        }

        // ⌘⇧U
        if (isUploadFilePressed(event)) {
            imageBtn.clicked()
            event.accepted = true
        }

        if (event.key === Qt.Key_Down) {
            return emojiSuggestions.listView.incrementCurrentIndex()
        }
        if (event.key === Qt.Key_Up) {
            return emojiSuggestions.listView.decrementCurrentIndex()
        }

        isColonPressed = (event.key === Qt.Key_Colon) && (event.modifiers & Qt.ShiftModifier);

        if (suggestionsBox.visible) {
            let aliasName = suggestionsBox.formattedPlainTextFilter;
            let lastCursorPosition = suggestionsBox.suggestionFilter.cursorPosition;
            let lastAtPosition = suggestionsBox.suggestionFilter.lastAtPosition;
            if (aliasName.toLowerCase() === suggestionsBox.suggestionsModel.get(suggestionsBox.listView.currentIndex).name.toLowerCase()
                && (event.key !== Qt.Key_Backspace) && (event.key !== Qt.Key_Delete)) {
                insertMention(aliasName, lastAtPosition, lastCursorPosition);
            } else if (event.key === Qt.Key_Space) {
                var plainTextToReplace = messageInputField.getText(lastAtPosition, lastCursorPosition);
                messageInputField.remove(lastAtPosition, lastCursorPosition);
                messageInputField.insert(lastAtPosition, plainTextToReplace);
                suggestionsBox.hide();
            }
        }
    }

    function wrapSelection(wrapWith) {
        if (messageInputField.selectionStart - messageInputField.selectionEnd === 0) return

        // calulate the new selection start and end positions
        var newSelectionStart = messageInputField.selectionStart + wrapWith.length
        var newSelectionEnd = messageInputField.selectionEnd - messageInputField.selectionStart + newSelectionStart

        insertInTextInput(messageInputField.selectionStart, wrapWith);
        insertInTextInput(messageInputField.selectionEnd, wrapWith);

        messageInputField.select(newSelectionStart, newSelectionEnd)
    }

    function unwrapSelection(unwrapWith, selectedTextWithFormationChars) {
            if (messageInputField.selectionStart - messageInputField.selectionEnd === 0) return

            // calulate the new selection start and end positions
            var newSelectionStart = messageInputField.selectionStart -  unwrapWith.length
            var newSelectionEnd = messageInputField.selectionEnd-messageInputField.selectionStart + newSelectionStart

            selectedTextWithFormationChars = selectedTextWithFormationChars.trim()
            // Check if the selectedTextWithFormationChars has formation chars and if so, calculate how many so we can adapt the start and end pos
            const selectTextDiff = (selectedTextWithFormationChars.length - messageInputField.selectedText.length) / 2

            // Remove the deselected option from the before and after the selected text
            const prefixChars = messageInputField.getText((messageInputField.selectionStart - selectTextDiff), messageInputField.selectionStart)
            const updatedPrefixChars = prefixChars.replace(unwrapWith, '')
            const postfixChars = messageInputField.getText(messageInputField.selectionEnd, (messageInputField.selectionEnd + selectTextDiff))
            const updatedPostfixChars = postfixChars.replace(unwrapWith, '')

            // Create updated selected string with pre and post formatting characters
            const updatedSelectedStringWithFormatChars = updatedPrefixChars + messageInputField.selectedText + updatedPostfixChars

            messageInputField.remove(messageInputField.selectionStart - selectTextDiff, messageInputField.selectionEnd + selectTextDiff)

            insertInTextInput(messageInputField.selectionStart, updatedSelectedStringWithFormatChars)

            messageInputField.select(newSelectionStart, newSelectionEnd)
    }

    function getPlainText() {
        const textWithoutMention = messageInputField.text.replace(/<span style="[ :#0-9a-z;\-\.,\(\)]+">(@([a-z\.]+(\ ?[a-z]+\ ?[a-z]+)?))<\/span>/ig, "\[\[mention\]\]$1\[\[mention\]\]")

        const deparsedEmoji = StatusQUtils.Emoji.deparse(textWithoutMention);

        return globalUtils.plainText(deparsedEmoji)
    }

    function removeMentions(currentText) {
        return currentText.replace(/\[\[mention\]\]/g, '')
    }

    function parseMarkdown(markdownText) {
        const htmlText = markdownText
        .replace(/\~\~([^*]+)\~\~/gim, '~~<span style="text-decoration: line-through">$1</span>~~')
        .replace(/\*\*([^*]+)\*\*/gim, ':asterisk::asterisk:<b>$1</b>:asterisk::asterisk:')
        .replace(/\`([^*]+)\`/gim, '`<code>$1</code>`')
        .replace(/\*([^*]+)\*/gim, ':asterisk:<i>$1</i>:asterisk:')
        return htmlText.replace(/\:asterisk\:/gim, "*")
    }

    function getFormattedText(start, end) {
        start = start || 0
        end = end || messageInputField.length

        const oldFormattedText = messageInputField.getFormattedText(start, end)

        const found = oldFormattedText.match(/<!--StartFragment-->([\w\W\s]*)<!--EndFragment-->/m);

        return found[1]
    }

    function setFormatInInput(formationFunction, startTag, endTag, formationChar, numFormationChars) {
        const inputText = getFormattedText()
        const plainInputText = messageInputField.getText(0, messageInputField.length)

        let lengthDifference

        try {
            const result = formationFunction(inputText)

            if (!result) {
                return
            }
            const parsed = JSON.parse(result)

            let substring
            let nbEmojis
            parsed.forEach(function (match) {
                match[1] += 1
                const truncatedInputText = inputText.substring(0, match[1] + numFormationChars)
                const truncatedPlainText = plainInputText.substring(0, messageInputField.cursorPosition)

                const lengthDifference = truncatedInputText.length - truncatedPlainText.length

                nbEmojis = StatusQUtils.Emoji.nbEmojis(truncatedInputText)


                match[1] += (nbEmojis * -2)
                match[0] += (nbEmojis * -2)
                substring = inputText.substring(match[0], match[1])

                if (plainInputText.charAt(match[0] - 1) !== formationChar) {
                    match[0] -= lengthDifference
                    match[1] -= lengthDifference
                } else {
                    match[1] -= lengthDifference
                }

                messageInputField.remove(match[0], match[1])
                insertInTextInput(match[0], `${startTag}${substring}${endTag}`)
            })
        } catch (e) {
            //
        }
    }

    //mentions helper properties
    property int copyTextStart: 0
    property string copiedTextPlain: ""
    property string copiedTextFormatted: ""
    ListView {
        id: dummyContactList
        model: control.usersStore ? control.usersStore.usersModel : []
        delegate: Item {
            property string contactName: model.name
        }
    }

    function onRelease(event) {
        if (event.key === Qt.Key_Backspace && textFormatMenu.opened) {
            textFormatMenu.close()
        }
        // the text doesn't get registered to the textarea fast enough
        // we can only get it in the `released` event

        if (paste) {
            if (copiedTextPlain.includes("@")) {
                copiedTextFormatted = copiedTextFormatted.replace(/underline/g, "none").replace(/span style="/g, "span style=\" text-decoration:none;");
                for (var j = 0; j < dummyContactList.count; j++) {
                    var name = dummyContactList.itemAtIndex(j).contactName;
                    if (copiedTextPlain.indexOf(name) > -1) {
                        var subStr = name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                        var regex = new RegExp(subStr, 'gi'), result, indices = [];
                        while ((result = regex.exec(copiedTextPlain))) {
                            mentionsPos.push({"name": name, "leftIndex": (result.index + copyTextStart - 1), "rightIndex": (result.index + copyTextStart + name.length)});
                        }
                    }
                }
            }
            messageInputField.remove(copyTextStart, (copyTextStart + copiedTextPlain.length));
            insertInTextInput(copyTextStart, copiedTextFormatted);
            paste = false;
        }

        if (event.key !== Qt.Key_Escape) {
            emojiEvent = emojiHandler(event);
            if (!emojiEvent) {
                emojiSuggestions.close()
            }
        }
    }

    // since emoji length is not 1 we need to match that position that TextArea returns
    // to the actual position in the string.
    function extrapolateCursorPosition() {
        // we need only the message part to be html
        const text = getPlainText()
        const completelyPlainText = removeMentions(text)
        const plainText = StatusQUtils.Emoji.parse(text);

        var bracketEvent = false;
        var almostMention = false;
        var mentionEvent = false;
        var length = 0;

        // This loop calculates the cursor position inside the plain text which contains the image tags (<img>) and the mention tags ([[mention]])
        const cursorPos = messageInputField.cursorPosition
        let character = ""
        for (var i = 0; i < plainText.length; i++) {
            if (length >= cursorPos) break;

            character = plainText.charAt(i)
            if (!bracketEvent && character !== '<' && !mentionEvent && character !== '[')  {
                length++;
            } else if (!bracketEvent && character === '<') {
                bracketEvent = true;
            } else if (bracketEvent && character === '>') {
                bracketEvent = false;
                length++;
            } else if (!mentionEvent && almostMention && plainText.charAt(i) === '[') {
                almostMention = false
                mentionEvent = true
            } else if (!mentionEvent && !almostMention && plainText.charAt(i) === '[') {
                almostMention = true
            } else if (!mentionEvent && almostMention && plainText.charAt(i) !== '[') {
                almostMention = false
            } else if (mentionEvent && !almostMention && plainText.charAt(i) === ']') {
                almostMention = true
            } else if (mentionEvent && almostMention && plainText.charAt(i) === ']') {
                almostMention = false
                mentionEvent = false
            }
        }

        let textBeforeCursor = StatusQUtils.Emoji.deparseFromParse(plainText.substr(0, i));

        return {
            cursor: countEmojiLengths(plainText.substr(0, i)) + messageInputField.cursorPosition + text.length - completelyPlainText.length,
            data: textBeforeCursor,
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
                const codePoint = StatusQUtils.Emoji.getEmojiUnicode(shortname);
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
        const match = StatusQUtils.Emoji.getEmojis(value);
        var length = 0;

        if (match && match.length > 0) {
            for (var i = 0; i < match.length; i++) {
                length += StatusQUtils.Emoji.deparseFromParse(match[i]).length;
            }
            length = length - match.length;
        }
        return length;
    }

    function replaceWithEmoji(message, shortname, codePoint) {
        const encodedCodePoint = StatusQUtils.Emoji.getEmojiCodepoint(codePoint)
        messageInputField.remove(messageInputField.cursorPosition - shortname.length, messageInputField.cursorPosition);
        insertInTextInput(messageInputField.cursorPosition, StatusQUtils.Emoji.parse(encodedCodePoint) + " ");
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
        imageArea.imageSource = [];
        replyArea.userName = ""
        replyArea.message = ""
        for (let i=0; i<validators.children.length; i++) {
            const validator = validators.children[i]
            validator.images = []
        }
    }

    function validateImages(imagePaths) {
        // needed because imageArea.imageSource is not a normal js array
        const existing = (imageArea.imageSource || []).map(x => x.toString())
        let validImages = Utils.deduplicate(existing.concat(imagePaths))
        for (let i=0; i<validators.children.length; i++) {
            const validator = validators.children[i]
            validator.images = validImages
            validImages = validImages.filter(validImage => validator.validImages.includes(validImage))
        }
        return validImages
    }

    function showImageArea(imagePaths) {
        isImage = true;
        isReply = false;
        imageArea.imageSource = imagePaths
        control.fileUrls = imageArea.imageSource
    }

    function showReplyArea(messageId, userName, message, contentType, image, sticker) {
        isReply = true
        replyArea.userName = userName
        replyArea.message = message
        replyArea.contentType = contentType
        replyArea.image = image
        replyArea.stickerData = sticker
        replyArea.messageId = messageId
        messageInputField.forceActiveFocus();
    }

    function forceInputActiveFocus() {
        messageInputField.forceActiveFocus();
    }

    Connections {
        enabled: control.isActiveChannel
        target: Global.appMain.dragAndDrop
        ignoreUnknownSignals: true
        onDroppedOnValidScreen: (drop) => {
                                    let validImages = validateImages(drop.urls)
                                    if (validImages.length > 0) {
                                        showImageArea(validImages)
                                        drop.acceptProposedAction()
                                    }
                                }
    }

    FileDialog {
        id: imageDialog
        title: qsTr("Please choose an image")
        folder: shortcuts.pictures
        selectMultiple: true
        nameFilters: [
            qsTr("Image files (%1)").arg(Constants.acceptedDragNDropImageExtensions.map(img => "*" + img).join(" "))
        ]
        onAccepted: {
            imageBtn.highlighted = false
            imageBtn2.highlighted = false
            let validImages = validateImages(imageDialog.fileUrls)
            if (validImages.length > 0) {
                control.showImageArea(validImages)
            }
            messageInputField.forceActiveFocus();
        }
        onRejected: {
            imageBtn.highlighted = false
            imageBtn2.highlighted = false
        }
    }

    MessageDialog {
        id: messageTooLongDialog
        title: qsTr("Your message is too long.")
        icon: StandardIcon.Critical
        text: qsTr("Please make your message shorter. We have set the limit to 2000 characters to be courteous of others.")
        standardButtons: StandardButton.Ok
    }

    StatusEmojiSuggestionPopup {
        id: emojiSuggestions
        messageInput: messageInput
        onClicked: function (index) {
            if (index === undefined) {
                index = emojiSuggestions.listView.currentIndex
            }

            const unicode = emojiSuggestions.modelList[index].unicode_alternates || emojiSuggestions.modelList[index].unicode
            replaceWithEmoji(extrapolateCursorPosition(), emojiSuggestions.shortname, unicode);
        }
    }

    SuggestionBoxPanel {
        id: suggestionsBox
        model: control.usersStore ? control.usersStore.usersModel : []
        x : messageInput.x
        y: -height - Style.current.smallPadding
        width: messageInput.width
        filter: messageInputField.text
        cursorPosition: messageInputField.cursorPosition
        property: ["name", "nickname", "ensName", "alias"]
        inputField: messageInputField
        onItemSelected: function (item, lastAtPosition, lastCursorPosition) {
            messageInputField.forceActiveFocus();
            let name = item.name.replace("@", "")
            insertMention(name, lastAtPosition, lastCursorPosition)
            suggestionsBox.suggestionsModel.clear()
        }
        onVisibleChanged: {
            if (!visible) {
                messageInputField.forceActiveFocus();
            }
        }
    }

    ChatCommandsPopup {
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
        onOpened: {
            chatCommandsBtn.highlighted = true
        }
    }

    StatusGifPopup {
        id: gifPopup
        width: 360
        height: 440
        x: parent.width - width - Style.current.halfPadding
        y: -height
        gifSelected: function (event, url) {
            messageInputField.text += "\n" + url
            control.sendMessage(event)
            gifBtn.highlighted = false
            messageInputField.forceActiveFocus()
            if (control.closeGifPopupAfterSelection)
                gifPopup.close()
        }
        onClosed: {
            gifBtn.highlighted = false
        }
    }

    StatusStickersPopup {
        id: stickersPopup
        x: parent.width - width - Style.current.halfPadding
        y: -height
        store: control.store
        enabled: !!control.recentStickers && !!control.stickerPackList
        recentStickers: control.recentStickers
        stickerPackList: control.stickerPackList
        onStickerSelected: {
            control.stickerSelected(hashId, packId)
            control.hideExtendedArea();
            messageInputField.forceActiveFocus();
        }
        onClosed: {
            stickersBtn.highlighted = false
        }
    }

    StatusQ.StatusFlatRoundButton {
        id: chatCommandsBtn
        width: 32
        height: 32
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        icon.name: "chat-commands"
        type: StatusQ.StatusFlatRoundButton.Type.Tertiary
        visible: RootStore.isWalletEnabled && !isEdit && control.chatType === Constants.chatType.oneToOne && !control.isStatusUpdateInput
        enabled: !control.isContactBlocked
        onClicked: {
            chatCommandsPopup.opened ?
                chatCommandsPopup.close() :
                chatCommandsPopup.open()
        }
    }

    StatusQ.StatusFlatRoundButton {
        id: imageBtn
        width: 32
        height: 32
        anchors.left: chatCommandsBtn.visible ? chatCommandsBtn.right : parent.left
        anchors.leftMargin: chatCommandsBtn.visible ? 2 : 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        icon.name: "image"
        type: StatusQ.StatusFlatRoundButton.Type.Tertiary
        visible: !isEdit && control.chatType !== Constants.chatType.publicChat && !control.isStatusUpdateInput
        enabled: !control.isContactBlocked
        onClicked: {
            highlighted = true
            imageDialog.open()
        }
    }

    Rectangle {
        id: messageInput
        enabled: !control.isContactBlocked
        property int maxInputFieldHeight: control.isStatusUpdateInput ? 124 : 112
        property int defaultInputFieldHeight: control.isStatusUpdateInput ? 56 : 40
        anchors.left: imageBtn.visible ? imageBtn.right : parent.left
        anchors.leftMargin: imageBtn.visible ? 5 : Style.current.smallPadding
        anchors.top: control.isStatusUpdateInput ? parent.top : undefined
        anchors.bottom: !control.isStatusUpdateInput ? parent.bottom : undefined
        anchors.bottomMargin: control.isStatusUpdateInput ? 0 : 12
        anchors.right: unblockBtn.visible ? unblockBtn.left : parent.right
        anchors.rightMargin: Style.current.smallPadding
        height: {
            if (messageInputField.implicitHeight <= messageInput.defaultInputFieldHeight) {
                return messageInput.defaultInputFieldHeight
            }
            if (messageInputField.implicitHeight >= messageInput.maxInputFieldHeight) {
                return messageInput.maxInputFieldHeight
            }
            return messageInputField.implicitHeight
        }

        color: isEdit ? Theme.palette.statusChatInput.secondaryBackgroundColor : Style.current.inputBackground
        radius: control.isStatusUpdateInput ? 36 :
                                              height > defaultInputFieldHeight + 1 || extendedArea.visible ? 16 : 32

        ColumnLayout {
            id: validators
            anchors.bottom: control.imageErrorMessageLocation === StatusChatInput.ImageErrorMessageLocation.Top ? extendedArea.top : undefined
            anchors.bottomMargin: control.imageErrorMessageLocation === StatusChatInput.ImageErrorMessageLocation.Top ? -4 : undefined
            anchors.top: control.imageErrorMessageLocation === StatusChatInput.ImageErrorMessageLocation.Bottom ? extendedArea.bottom : undefined
            anchors.topMargin: control.imageErrorMessageLocation === StatusChatInput.ImageErrorMessageLocation.Bottom ? (isImage ? -4 : 4) : undefined
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            z: 1
            StatusChatImageExtensionValidator {
                Layout.alignment: Qt.AlignHCenter
            }
            StatusChatImageSizeValidator {
                Layout.alignment: Qt.AlignHCenter
            }
            StatusChatImageQtyValidator {
                Layout.alignment: Qt.AlignHCenter
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
            anchors.bottom: control.isStatusUpdateInput ? undefined : messageInput.top
            anchors.top: control.isStatusUpdateInput ? messageInput.bottom : undefined
            anchors.topMargin: control.isStatusUpdateInput ? -Style.current.halfPadding : 0
            color: isEdit ? Style.current.secondaryInputBackground : Style.current.inputBackground
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
                anchors.topMargin: Style.current.halfPadding
                visible: isImage
                width: messageInputField.width - actions.width
                onImageClicked: Global.openImagePopup(chatImage, messageContextMenu)
                onImageRemoved: {
                    if (control.fileUrls.length > index && control.fileUrls[index]) {
                        control.fileUrls.splice(index, 1)
                    }
                    isImage = control.fileUrls.length > 0
                    validateImages(control.fileUrls)
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
                // Not Refactored Yet
//                stickerData: sticker
                onCloseButtonClicked: {
                    isReply = false
                }
            }
        }

        StatusSmartIdenticon {
            id: profileImage
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: parent.top
            anchors.topMargin: Style.current.halfPadding
            image.source: userProfile.icon
            visible: control.isStatusUpdateInput
        }

        ScrollView {
            id: scrollView
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: profileImage.visible ? profileImage.right : parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.right: actions.left
            anchors.rightMargin: Style.current.halfPadding
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            TextArea {
                id: messageInputField
                property var lastClick: 0
                property int cursorWhenPressed: 0
                textFormat: Text.RichText
                font.pixelSize: 15
                font.family: Style.current.fontRegular.name
                wrapMode: TextArea.Wrap
                placeholderText: control.chatInputPlaceholder
                placeholderTextColor: Style.current.secondaryText
                selectByMouse: true
                color: isEdit ? Theme.palette.directColor1 : Style.current.textColor
                topPadding: control.isStatusUpdateInput ? 18 : Style.current.smallPadding
                bottomPadding: control.isStatusUpdateInput ? 14 : 12
                Keys.onPressed: {
                    keyEvent = event;
                    onKeyPress(event)
                    cursorWhenPressed = cursorPosition;
                }
                Keys.onReleased: onRelease(event) // gives much more up to date cursorPosition
                Keys.onShortcutOverride: event.accepted = isUploadFilePressed(event)
                leftPadding: 0
                selectionColor: Style.current.primarySelectionColor
                persistentSelection: true
                property var keyEvent
                onCursorPositionChanged: {
                    if (mentionsPos.length > 0) {
                        for (var i = 0; i < mentionsPos.length; i++) {
                            if ((messageInputField.cursorPosition === (mentionsPos[i].leftIndex + 1)) && (keyEvent.key === Qt.Key_Right)) {
                                messageInputField.cursorPosition = mentionsPos[i].rightIndex;
                            } else if (messageInputField.cursorPosition === (mentionsPos[i].rightIndex - 1)) {
                                if (keyEvent.key === Qt.Key_Left) {
                                    messageInputField.cursorPosition = mentionsPos[i].leftIndex;
                                } else if ((keyEvent.key === Qt.Key_Backspace) || (keyEvent.key === Qt.Key_Delete)) {
                                    messageInputField.remove(mentionsPos[i].rightIndex, mentionsPos[i].leftIndex);
                                    mentionsPos.pop(i);
                                }
                            } else if (((messageInputField.cursorPosition > mentionsPos[i].leftIndex) &&
                                        (messageInputField.cursorPosition  < mentionsPos[i].rightIndex)) &&
                                       ((keyEvent.key === Qt.Key_Left) && ((keyEvent.modifiers & Qt.AltModifier) ||
                                                                           (keyEvent.modifiers & Qt.ControlModifier)))) {
                                messageInputField.cursorPosition = mentionsPos[i].leftIndex;
                            } else if ((keyEvent.key === Qt.Key_Up) || (keyEvent.key === Qt.Key_Down)) {
                                if (messageInputField.cursorPosition >= mentionsPos[i].leftIndex &&
                                    messageInputField.cursorPosition <= (((mentionsPos[i].leftIndex + mentionsPos[i].rightIndex)/2))) {
                                    messageInputField.cursorPosition = mentionsPos[i].leftIndex;
                                  } else if (messageInputField.cursorPosition <= mentionsPos[i].rightIndex &&
                                           messageInputField.cursorPosition > (((mentionsPos[i].leftIndex + mentionsPos[i].rightIndex)/2))) {
                                    messageInputField.cursorPosition = mentionsPos[i].rightIndex;
                                }
                            }
                        }
                    }
                    if ((mentionsPos.length > 0) && (cursorPosition < length) && getText(cursorPosition, length).includes("@")
                         && (keyEvent.key !== Qt.Key_Right) && (keyEvent.key !== Qt.Key_Left) && (keyEvent.key !== Qt.Key_Up)
                         && (keyEvent.key !== Qt.Key_Down)) {
                        var unformattedText = getText(cursorPosition, length);
                        for (var k = 0; k < mentionsPos.length; k++) {
                            if ((unformattedText.indexOf(mentionsPos[k].name) !== -1) && (unformattedText.indexOf(mentionsPos[k].name) !== mentionsPos[k].leftIndex)) {
                                mentionsPos[k].leftIndex = (cursorPosition + unformattedText.indexOf(mentionsPos[k].name) - 1);
                                mentionsPos[k].rightIndex = (cursorPosition + unformattedText.indexOf(mentionsPos[k].name) + mentionsPos[k].name.length);
                            }
                        }
                    }
                }
                onTextChanged: {
                    if (length <= control.messageLimit) {
                        var symbols = ":='xX><0O;*dB8-D#%\\";
                        if ((length > 1) && (symbols.indexOf(getText((cursorPosition - 2), (cursorPosition - 1))) !== -1)
                                && (!getText((cursorPosition - 7), cursorPosition).includes("http"))) {
                            const emojis = EmojiJSON.emoji_json.filter(function (emoji) {
                                if (emoji.aliases_ascii.includes(getText((cursorPosition - 2), cursorPosition)) ||
                                        emoji.aliases_ascii.includes(getText((cursorPosition - 3), cursorPosition))) {
                                    var has2Chars = emoji.aliases_ascii.includes(getText((cursorPosition - 2), cursorPosition));
                                    replaceWithEmoji("", getText(cursorPosition - (has2Chars ? 2 : 3), cursorPosition), emoji.unicode);
                                }
                            })
                        }
                        if (text === "") {
                            mentionsPos = [];
                        }
                    } else {
                        var removeFrom = (cursorPosition < messageLimit) ? cursorWhenPressed : messageLimit;
                        remove(removeFrom, cursorPosition);
                    }
                    messageLengthLimit.remainingChars = (messageLimit - length);
                }

                onReleased: function (event) {
                    const now = Date.now()
                    if (messageInputField.selectedText.trim() !== "") {
                        // If it's a double click, just check the mouse position
                        // If it's a mouse select, use the start and end position average)
                        let x = now < messageInputField.lastClick + 500 ? x = event.x :
                                                                          (messageInputField.cursorRectangle.x + event.x) / 2
                        x -= textFormatMenu.width / 2

                        textFormatMenu.popup(x, -messageInputField.height-2)
                        messageInputField.forceActiveFocus();
                    }
                    lastClick = now
                }

                StatusSyntaxHighlighter {
                   quickTextDocument: messageInputField.textDocument
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    enabled: parent.hoveredLink
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
                }
                StatusTextFormatMenu {
                    id: textFormatMenu

                    StatusChatInputTextFormationAction {
                        wrapper: "**"
                        icon.name: "bold"
                        text: qsTr("Bold")
                        selectedTextWithFormationChars: RootStore.getSelectedTextWithFormationChars(messageInputField)
                        onActionTriggered: checked ?
                                         unwrapSelection(wrapper, RootStore.getSelectedTextWithFormationChars(messageInputField)) :
                                         wrapSelection(wrapper)
                    }
                    StatusChatInputTextFormationAction {
                        wrapper: "*"
                        icon.name: "italic"
                        text: qsTr("Italic")
                        selectedTextWithFormationChars: RootStore.getSelectedTextWithFormationChars(messageInputField)
                        checked: (surroundedBy("*") && !surroundedBy("**")) || surroundedBy("***")
                        onActionTriggered: checked ?
                                         unwrapSelection(wrapper, RootStore.getSelectedTextWithFormationChars(messageInputField)) :
                                         wrapSelection(wrapper)
                    }
                    StatusChatInputTextFormationAction {
                        wrapper: "~~"
                        icon.name: "strikethrough"
                        text: qsTr("Strikethrough")
                        selectedTextWithFormationChars: RootStore.getSelectedTextWithFormationChars(messageInputField)
                        onActionTriggered: checked ?
                                         unwrapSelection(wrapper, RootStore.getSelectedTextWithFormationChars(messageInputField)) :
                                         wrapSelection(wrapper)
                    }
                    StatusChatInputTextFormationAction {
                        wrapper: "`"
                        icon.name: "code"
                        text: qsTr("Code")
                        selectedTextWithFormationChars: RootStore.getSelectedTextWithFormationChars(messageInputField)
                        onActionTriggered: checked ?
                                         unwrapSelection(wrapper, RootStore.getSelectedTextWithFormationChars(messageInputField)) :
                                         wrapSelection(wrapper)
                    }
                    onClosed: {
                        messageInputField.deselect();
                    }
                }
            }

            Shortcut {
                enabled: messageInputField.activeFocus
                sequence: StandardKey.Bold
                onActivated: wrapSelection("**")
            }
            Shortcut {
                enabled: messageInputField.activeFocus
                sequence: StandardKey.Italic
                onActivated: wrapSelection("*")
            }
            Shortcut {
                enabled: messageInputField.activeFocus
                sequence: "Ctrl+Shift+Alt+C"
                onActivated: wrapSelection("```")
            }
            Shortcut {
                enabled: messageInputField.activeFocus
                sequence: "Ctrl+Shift+C"
                onActivated: wrapSelection("`")
            }
            Shortcut {
                enabled: messageInputField.activeFocus
                sequence: "Ctrl+Alt+-"
                onActivated: wrapSelection("~~")
            }
            Shortcut {
                enabled: messageInputField.activeFocus
                sequence: "Ctrl+Shift+X"
                onActivated: wrapSelection("~~")
            }
            Shortcut {
                enabled: messageInputField.activeFocus
                sequence: "Ctrl+Meta+Space"
                onActivated: emojiBtn.clicked(null)
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
            property int remainingChars: -1
            anchors.right: parent.right
            anchors.bottom: actions.top
            anchors.rightMargin: control.isStatusUpdateInput ? Style.current.padding : Style.current.radius
            leftPadding: Style.current.halfPadding
            rightPadding: Style.current.halfPadding
            visible: ((messageInputField.length >= control.messageLimitVisible) && (messageInputField.length <= control.messageLimit))
            color: (remainingChars <=  messageLimitVisible) ? Style.current.danger : Style.current.textColor
            text: visible ? remainingChars.toString() : ""
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

            StatusQ.StatusFlatRoundButton {
                id: imageBtn2
                implicitHeight: 32
                implicitWidth: 32
                anchors.right: sendBtn.left
                anchors.rightMargin: 2
                anchors.bottom: parent.bottom
                icon.name: "image"
                type: StatusQ.StatusFlatRoundButton.Type.Tertiary
                visible: control.isStatusUpdateInput

                onClicked: {
                    highlighted = true
                    imageDialog.open()
                }
            }

            StatusQ.StatusFlatButton {
                id: sendBtn
                icon.name: "send"
                text: qsTr("Send")
                size: StatusQ.StatusBaseButton.Size.Small
                anchors.right: parent.right
                anchors.rightMargin: Style.current.halfPadding
                anchors.verticalCenter: parent.verticalCenter
                visible: imageBtn2.visible
                enabled: (globalUtils.plainText(StatusQUtils.Emoji.deparse(messageInputField.text)).length > 0 || isImage) && messageInputField.length < messageLimit
                onClicked: function (event) {
                    control.sendMessage(event)
                    control.hideExtendedArea();
                }
            }

            StatusQ.StatusFlatRoundButton {
                id: emojiBtn
                enabled: !control.emojiPopupOpened
                implicitHeight: 32
                implicitWidth: 32
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                visible: !imageBtn2.visible
                icon.name: "emojis"
                type: StatusQ.StatusFlatRoundButton.Type.Tertiary
                color: "transparent"
                onClicked: {
                    control.emojiPopupOpened = true
                    togglePopup(emojiPopup, emojiBtn)
                    emojiPopup.x = Global.applicationWindow.width - emojiPopup.width - Style.current.halfPadding
                    emojiPopup.y = Global.applicationWindow.height - emojiPopup.height - control.height
                }
            }

            StatusQ.StatusFlatRoundButton {
                id: gifBtn
                implicitHeight: 32
                implicitWidth: 32
                anchors.right: emojiBtn.left
                anchors.rightMargin: 2
                anchors.bottom: parent.bottom
                visible: !isEdit && RootStore.isGifWidgetEnabled
                icon.name: "gif"
                type: StatusQ.StatusFlatRoundButton.Type.Tertiary
                color: "transparent"
                onClicked: togglePopup(gifPopup, gifBtn)
            }

            StatusQ.StatusFlatRoundButton {
                id: stickersBtn
                implicitHeight: 32
                implicitWidth: 32
                width: visible ? 32 : 0
                anchors.left: emojiBtn.right
                anchors.leftMargin: 2
                anchors.bottom: parent.bottom
                icon.name: "stickers"
                type: StatusQ.StatusFlatRoundButton.Type.Tertiary
                visible: !isEdit && emojiBtn.visible
                color: "transparent"
                onClicked: togglePopup(stickersPopup, stickersBtn)
            }
        }
    }

    StatusQ.StatusButton {
        id: unblockBtn
        visible: control.isContactBlocked
        anchors.right: parent.right
        anchors.rightMargin: Style.current.halfPadding
        anchors.bottom: messageInput.bottom
        text: qsTr("Unblock")
        type: StatusQ.StatusBaseButton.Type.Danger
        onClicked: function (event) {
            control.unblockChat()
        }
    }
}
