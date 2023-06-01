import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0

//TODO remove this dependency
import AppLayouts.Chat.panels 1.0

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1 as StatusQ

Rectangle {
    id: control

    signal sendTransactionCommandButtonClicked()
    signal receiveTransactionCommandButtonClicked()
    signal stickerSelected(string hashId, string packId, string url)
    signal sendMessage(var event)
    signal unblockChat()
    signal keyUpPress()

    property var usersStore
    property var store

    property var emojiPopup: null
    property var stickersPopup: null
    // Use this to only enable the Connections only when this Input opens the Emoji popup
    property bool emojiPopupOpened: false
    property bool stickersPopupOpened: false
    property bool closeGifPopupAfterSelection: true

    property bool emojiEvent: false
    property bool isColonPressed: false
    property bool isReply: false
    property string replyMessageId: replyArea.messageId

    property bool isImage: false
    property bool isEdit: false
    property bool isContactBlocked: false
    property bool isActiveChannel: false

    property int messageLimit: 2000
    property int messageLimitVisible: 200

    property int chatType

    property string chatInputPlaceholder: qsTr("Message")

    property alias textInput: messageInputField

    property var fileUrlsAndSources: []

    property var imageErrorMessageLocation: StatusChatInput.ImageErrorMessageLocation.Top // TODO: Remove this proeprty?

    property alias suggestions: suggestionsBox

    enum ImageErrorMessageLocation {
        Top,
        Bottom
    }

    objectName: "statusChatInput"
    function parseMessage(message) {
        let mentionsMap = new Map()
        let index = 0
        while (true) {
            index = message.indexOf("<a href=", index)
            if (index < 0) {
                break
            }
            const startIndex = index
            const endIndex = message.indexOf("</a>", index) + 4
            if (endIndex < 0) {
                index += 8 // "<a href="
                continue
            }
            const addrIndex = message.indexOf("0x", index + 8)
            if (addrIndex < 0) {
                index += 8 // "<a href="
                continue
            }
            const addrEndIndex = message.indexOf("\"", addrIndex)
            if (addrEndIndex < 0) {
                index += 8 // "<a href="
                continue
            }
            const mentionLink = message.substring(startIndex, endIndex)
            const linkTag = message.substring(index, endIndex)
            const linkText = linkTag.replace(/(<([^>]+)>)/ig,"").trim()
            const atSymbol = linkText.startsWith("@") ? '' : '@'
            const mentionTag = Constants.mentionSpanTag + atSymbol + linkText + '</span> '
            mentionsMap.set(mentionLink, mentionTag)
            index += linkTag.length
        }

        let text = message;

        for (let [key, value] of mentionsMap)
            text = text.replace(new RegExp(key, 'g'), value)

        textInput.text = text
        textInput.cursorPosition = textInput.length
    }

    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin
    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

    color: Style.current.transparent

    QtObject {
        id: d

        readonly property string emojiReplacementSymbols: ":='xX><0O;*dB8-D#%\\"

        //mentions helper properties
        property string copiedTextPlain: ""
        property string copiedTextFormatted: ""
        property var copiedMentionsPos: []
        property int copyTextStart: 0

        property int leftOfMentionIndex: -1
        property int rightOfMentionIndex: -1
        readonly property int nbEmojisInClipboard: StatusQUtils.Emoji.nbEmojis(QClipboardProxy.html)
        readonly property StateGroup emojiPopupTakeover: StateGroup {
            states: State {
                when: control.emojiPopupOpened

                PropertyChanges {
                    target: emojiPopup

                    parent: control
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                    x: control.width - emojiPopup.width - Style.current.halfPadding
                    y: -emojiPopup.height
                }
            }
        }
        readonly property StateGroup stickersPopupTakeover: StateGroup {
            states: State {
                when: control.stickersPopupOpened

                PropertyChanges {
                    target: stickersPopup

                    parent: control
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                    x: control.width - stickersPopup.width - Style.current.halfPadding
                    y: -stickersPopup.height
                }
            }
        }

        function copyMentions(start, end) {
            copiedMentionsPos = []
            for (let k = 0; k < mentionsPos.length; k++) {
                if (mentionsPos[k].leftIndex >= start && mentionsPos[k].rightIndex <= end) {
                    const mention = {
                        name: mentionsPos[k].name,
                        pubKey: mentionsPos[k].pubKey,
                        leftIndex: mentionsPos[k].leftIndex - start,
                        rightIndex: mentionsPos[k].rightIndex - start
                    }
                    copiedMentionsPos.push(mention)
                }
            }
        }

        function sortMentions() {
            if (mentionsPos.length < 2) {
                return
            }
            mentionsPos = mentionsPos.sort(function(a, b){
                return a.leftIndex - b.leftIndex
            })
        }

        function updateMentionsPositions() {
            if (mentionsPos.length == 0) {
                return
            }

            const unformattedText = messageInputField.getText(0, messageInputField.length)
            if (!unformattedText.includes("@")) {
                return
            }

            const keyEvent = messageInputField.keyEvent
            if ((keyEvent.key === Qt.Key_Right) || (keyEvent.key === Qt.Key_Left)
                    || (keyEvent.key === Qt.Key_Up) || (keyEvent.key === Qt.Key_Down)) {
                return
            }

            let lastRightIndex = -1
            for (var k = 0; k < mentionsPos.length; k++) {
                const aliasIndex = unformattedText.indexOf(mentionsPos[k].name, lastRightIndex)
                if (aliasIndex === -1) {
                    continue
                }
                lastRightIndex = aliasIndex + mentionsPos[k].name.length

                if (aliasIndex - 1 !== mentionsPos[k].leftIndex) {
                    mentionsPos[k].leftIndex = aliasIndex - 1
                    mentionsPos[k].rightIndex = aliasIndex + mentionsPos[k].name.length
                }
            }

            sortMentions()
        }

        function cleanMentionsPos() {
            if(mentionsPos.length == 0) return

            const unformattedText = messageInputField.getText(0, messageInputField.length)
            mentionsPos = mentionsPos.filter(mention => unformattedText.charAt(mention.leftIndex) === "@")
        }

        function insertMention(aliasName, publicKey, lastAtPosition, lastCursorPosition) {
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

            mentionsPos = mentionsPos.filter(mention => mention.leftIndex !== lastAtPosition)
            mentionsPos.push({name: aliasName, pubKey: publicKey, leftIndex: lastAtPosition, rightIndex: (lastAtPosition+aliasName.length + 1)});
            d.sortMentions()
        }

        function removeMention(mention) {
            const index = mentionsPos.indexOf(mention)
            if(index >= 0) {
                mentionsPos.splice(index, 1)
            }

            messageInputField.remove(mention.leftIndex, mention.rightIndex)
        }

        function getMentionAtPosition(position: int) {
            return mentionsPos.find(mention => mention.leftIndex < position && mention.rightIndex > position)
        }
    }

    function insertInTextInput(start, text) {
        // Repace new lines with entities because `insert` gets rid of them
        messageInputField.insert(start, text.replace(/\n/g, "<br/>"));
    }

    function togglePopup(popup, btn) {
        if (popup !== control.stickersPopup) {
            control.stickersPopup.close()
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

        function onEmojiSelected(text: string, atCursor: bool) {
            insertInTextInput(atCursor ? messageInputField.cursorPosition : messageInputField.length, text)
            emojiBtn.highlighted = false
            messageInputField.forceActiveFocus();
        }
        function onClosed() {
            emojiBtn.highlighted = false
            control.emojiPopupOpened = false
        }
    }

    Connections {
        enabled: control.stickersPopupOpened
        target: control.stickersPopup

        function onStickerSelected(hashId: string, packId: string, url: string ) {
            control.stickerSelected(hashId, packId, url)
            control.hideExtendedArea();
            messageInputField.forceActiveFocus();
        }
        function onClosed() {
            stickersBtn.highlighted = false
            control.stickersPopupOpened = false
        }
    }

    property var mentionsPos: []

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

            if (messageInputField.length <= messageLimit) {
                checkForInlineEmojis(true);
                control.sendMessage(event)
                control.hideExtendedArea();
                event.accepted = true
                return;
            }
            if (event) {
                event.accepted = true
                messageTooLongDialog.open()
            }
        } else if (event.key === Qt.Key_Escape && control.isReply) {
            control.isReply = false
            event.accepted = true
        }

        const symbolPressed = event.text.length > 0 &&
                            event.key !== Qt.Key_Backspace &&
                            event.key !== Qt.Key_Delete &&
                            event.key !== Qt.Key_Escape
        if ((mentionsPos.length > 0) && symbolPressed && (messageInputField.selectedText.length === 0)) {
            for (var i = 0; i < mentionsPos.length; i++) {
                if (messageInputField.cursorPosition === mentionsPos[i].leftIndex) {
                    d.leftOfMentionIndex = i
                    event.accepted = true
                    return
                } else if (messageInputField.cursorPosition === mentionsPos[i].rightIndex) {
                    d.rightOfMentionIndex = i
                    event.accepted = true
                    return
                }
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

        if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
            if(mentionsPos.length > 0) {
                let anticipatedCursorPosition = messageInputField.cursorPosition
                anticipatedCursorPosition += event.key === Qt.Key_Backspace ?
                                               -1 : 1

                const mention = d.getMentionAtPosition(anticipatedCursorPosition)
                if(mention) {
                    d.removeMention(mention)
                    event.accepted = true
                }
            }

            // handle backspace when entering an existing blockquote
            if(message.data.startsWith(">") && message.data.endsWith("\n\n")) {
                const newMessage = message.data.substr(0, message.data.lastIndexOf("\n")) + "> ";
                messageInputField.remove(0, messageInputField.cursorPosition);
                insertInTextInput(0, StatusQUtils.Emoji.parse(newMessage));
                event.accepted = true
            }
        }

        if (event.matches(StandardKey.Copy) || event.matches(StandardKey.Cut)) {
            if (messageInputField.selectedText !== "") {
                d.copiedTextPlain = messageInputField.getText(
                            messageInputField.selectionStart, messageInputField.selectionEnd)
                d.copiedTextFormatted = messageInputField.getFormattedText(
                            messageInputField.selectionStart, messageInputField.selectionEnd)
                d.copyMentions(messageInputField.selectionStart, messageInputField.selectionEnd)
            }
        }

        if (event.matches(StandardKey.Paste)) {
            if (QClipboardProxy.hasImage) {
                const clipboardImage = QClipboardProxy.imageBase64
                validateImagesAndShowImageArea([clipboardImage])
                event.accepted = true
            } else if (QClipboardProxy.hasText) {
                messageInputField.remove(messageInputField.selectionStart, messageInputField.selectionEnd)

                // cursor position must be stored in a helper property because setting readonly to true causes change
                // of the cursor position to the end of the input
                d.copyTextStart = messageInputField.cursorPosition
                messageInputField.readOnly = true

                const clipboardText = Utils.plainText(QClipboardProxy.text)
                const copiedText = Utils.plainText(d.copiedTextPlain)
                if (copiedText === clipboardText) {
                    if (d.copiedTextPlain.includes("@")) {
                        d.copiedTextFormatted = d.copiedTextFormatted.replace(/span style="/g, "span style=\" text-decoration:none;")

                        let lastFoundIndex = -1
                        for (let j = 0; j < d.copiedMentionsPos.length; j++) {
                            const name = d.copiedMentionsPos[j].name
                            const indexOfName = d.copiedTextPlain.indexOf(name, lastFoundIndex)
                            lastFoundIndex += name.length

                            if (indexOfName === d.copiedMentionsPos[j].leftIndex + 1) {
                                const mention = {
                                    name: name,
                                    pubKey: d.copiedMentionsPos[j].pubKey,
                                    leftIndex: (d.copiedMentionsPos[j].leftIndex + d.copyTextStart - 1),
                                    rightIndex: (d.copiedMentionsPos[j].leftIndex + d.copyTextStart + name.length)
                                }
                                mentionsPos.push(mention)
                                d.sortMentions()
                            }
                        }
                    }
                    insertInTextInput(d.copyTextStart, d.copiedTextFormatted)
                } else {
                    d.copiedTextPlain = ""
                    d.copiedTextFormatted = ""
                    d.copiedMentionsPos = []
                    messageInputField.insert(d.copyTextStart, ((d.nbEmojisInClipboard === 0) ?
                    ("<div style='white-space: pre-wrap'>" + Utils.escapeHtml(QClipboardProxy.text) + "</div>")
                    : StatusQUtils.Emoji.deparse(QClipboardProxy.html)));
                }
            }
        }

        // ⌘⇧U
        if (isUploadFilePressed(event)) {
            imageBtn.clicked(null)
            event.accepted = true
        }

        if (event.key === Qt.Key_Down && emojiSuggestions.visible) {
            event.accepted = true
            return emojiSuggestions.listView.incrementCurrentIndex()
        }
        if (event.key === Qt.Key_Up && emojiSuggestions.visible) {
            event.accepted = true
            return emojiSuggestions.listView.decrementCurrentIndex()
        }

        isColonPressed = event.key === Qt.Key_Colon;
    }

    function getLineStartPosition(selectionStart) {
        const text = getPlainText()
        const lastNewLinePos = text.lastIndexOf("\n\n", messageInputField.selectionStart)
        return lastNewLinePos === -1 ? 0 : lastNewLinePos + 2
    }

    function prefixSelectedLine(prefix) {
        const selectedLinePosition = getLineStartPosition(messageInputField.selectionStart)
        insertInTextInput(selectedLinePosition, prefix)
    }

    function unprefixSelectedLine(prefix) {
        if( isSelectedLinePrefixedBy(messageInputField.selectionStart, prefix) ) {
            const selectedLinePosition = getLineStartPosition(messageInputField.selectionStart)
            messageInputField.remove(selectedLinePosition, selectedLinePosition + prefix.length)
        }
    }

    function isSelectedLinePrefixedBy(selectionStart, prefix) {
        const selectedLinePosition = getLineStartPosition(selectionStart)
        const text = getPlainText()
        const selectedLine = text.substring(selectedLinePosition)
        return selectedLine.startsWith(prefix)
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

        return Utils.plainText(deparsedEmoji)
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

    function getTextWithPublicKeys() {
        let result = messageInputField.text

        if (mentionsPos.length > 0) {
            for (var k = 0; k < mentionsPos.length; k++) {
                let leftIndex = result.indexOf(mentionsPos[k].name)
                let rightIndex = leftIndex + mentionsPos[k].name.length
                result = result.substring(0, leftIndex)
                         + mentionsPos[k].pubKey
                         + result.substring(rightIndex, result.length)
            }
        }

        return result
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

    function onRelease(event) {
        if ((event.modifiers & Qt.ControlModifier) || (event.modifiers & Qt.MetaModifier)) // these are likely shortcuts with no meaningful text
            return

        if (event.key === Qt.Key_Backspace && textFormatMenu.opened) {
            textFormatMenu.close()
        }
        // the text doesn't get registered to the textarea fast enough
        // we can only get it in the `released` event

        let eventText = event.text
        if(event.key === Qt.Key_Space) {
            eventText = "&nbsp;"
        }

        if(d.rightOfMentionIndex !== -1) {
            //make sure to add an extra space between mention and text
            let mentionSeparator = event.key === Qt.Key_Space ? "" : "&nbsp;"
            messageInputField.insert(mentionsPos[d.rightOfMentionIndex].rightIndex, mentionSeparator + eventText)

            d.rightOfMentionIndex = -1
        }

        if(d.leftOfMentionIndex !== -1) {
            messageInputField.insert(mentionsPos[d.leftOfMentionIndex].leftIndex, eventText)

            d.leftOfMentionIndex = -1
        }

        if (event.key !== Qt.Key_Escape) {
            emojiEvent = emojiHandler(event)
            if (!emojiEvent) {
                emojiSuggestions.close()
            }
        }

        if (messageInputField.readOnly) {
            messageInputField.readOnly = false;
            messageInputField.cursorPosition = (d.copyTextStart + QClipboardProxy.text.length + d.nbEmojisInClipboard);
        }


        if (suggestionsBox.visible) {
            let aliasName = suggestionsBox.formattedPlainTextFilter;
            let lastCursorPosition = suggestionsBox.suggestionFilter.cursorPosition;
            let lastAtPosition = suggestionsBox.suggestionFilter.lastAtPosition;
            let suggestionItem = suggestionsBox.suggestionsModel.get(suggestionsBox.listView.currentIndex);
            if (aliasName !== "" && aliasName.toLowerCase() === suggestionItem.name.toLowerCase()
                    && (event.key !== Qt.Key_Backspace) && (event.key !== Qt.Key_Delete)) {

                d.insertMention(aliasName, suggestionItem.publicKey, lastAtPosition, lastCursorPosition);
            } else if (event.key === Qt.Key_Space) {
                var plainTextToReplace = messageInputField.getText(lastAtPosition, lastCursorPosition);
                messageInputField.remove(lastAtPosition, lastCursorPosition);
                messageInputField.insert(lastAtPosition, plainTextToReplace);
                suggestionsBox.hide();
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

        let textBeforeCursor = StatusQUtils.Emoji.deparse(plainText.substr(0, i));

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
                    const emojis = StatusQUtils.Emoji.emojiJSON.emoji_json.filter(function (emoji) {
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
                length += StatusQUtils.Emoji.deparse(match[i]).length;
            }
            length = length - match.length;
        }
        return length;
    }

    function checkForInlineEmojis(force = false) {
         // trigger inline emoji replacements after space, or always (force==true) when sending the message
        if (force || messageInputField.getText(messageInputField.cursorPosition, messageInputField.cursorPosition - 1) === " ") {
            // figure out last word (between spaces), max length of 5
            var lastWord = ""
            const cursorPos = messageInputField.cursorPosition - (force ? 1 : 2) // just before the last non-space character
            for (let i = cursorPos; i > cursorPos - 6; i--) { // go back until we found a space or start of line
                const lastChar = messageInputField.getText(i, i+1)
                if (i < 0 || lastChar === " ") { // reached start of line or a space
                    break
                } else {
                    lastWord = lastChar + lastWord // collect the last word
                }
            }

            // check if the word contains any of the trigger chars (emojiReplacementSymbols)
            if (!!lastWord && Array.prototype.some.call(d.emojiReplacementSymbols, (trigger) => lastWord.includes(trigger))) {
                // search the ASCII aliases for a possible match
                const emojiFound = StatusQUtils.Emoji.emojiJSON.emoji_json.find(emoji => emoji.aliases_ascii.includes(lastWord))
                if (emojiFound) {
                    replaceWithEmoji("", lastWord, emojiFound.unicode, force ? 0 : 1 /*offset*/);
                }
            }
        }
    }

    function replaceWithEmoji(message, shortname, codePoint, offset = 0) {
        const encodedCodePoint = StatusQUtils.Emoji.getEmojiCodepoint(codePoint)
        messageInputField.remove(messageInputField.cursorPosition - shortname.length - offset, messageInputField.cursorPosition);
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
            if (Utils.isSpace(c) || Utils.isPunct(c))
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
        control.fileUrlsAndSources = []
        imageArea.imageSource = [];
        replyArea.userName = ""
        replyArea.message = ""
        for (let i=0; i<validators.children.length; i++) {
            const validator = validators.children[i]
            validator.images = []
        }
    }

    function validateImages(imagePaths) {
        if (!imagePaths || !imagePaths.length) {
            return []
        }
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

    function showImageArea(imagePathsOrData) {
        isImage = true;
        imageArea.imageSource = imagePathsOrData
        control.fileUrlsAndSources = imageArea.imageSource
    }

    // Use this to validate and show the images. The concatanation of previous selected images is done automatically
    // Returns true if the images were valid and added
    function validateImagesAndShowImageArea(imagePaths) {
        const validImages = validateImages(imagePaths)

        if (validImages.length > 0) {
            showImageArea(validImages)
            return true
        }
        return false
    }

    function showReplyArea(messageId, userName, message, contentType, image, album, albumCount, sticker) {
        isReply = true
        replyArea.userName = userName
        replyArea.message = message
        replyArea.contentType = contentType
        replyArea.image = image
        replyArea.stickerData = sticker
        replyArea.messageId = messageId
        replyArea.album = album
        replyArea.albumCount = albumCount
        messageInputField.forceActiveFocus();
    }

    function forceInputActiveFocus() {
        messageInputField.forceActiveFocus();
    }

    Connections {
        enabled: control.isActiveChannel
        target: Global.dragArea
        ignoreUnknownSignals: true
        function onDroppedOnValidScreen(drop) {
            if (validateImagesAndShowImageArea(drop.urls)) {
                drop.acceptProposedAction()
            }
        }
    }

    // This is used by Squish tests to not have to access the file dialog
    function selectImageString(filePath) {
        validateImagesAndShowImageArea([filePath])
        messageInputField.forceActiveFocus();
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
            validateImagesAndShowImageArea(imageDialog.fileUrls)
            messageInputField.forceActiveFocus();
        }
        onRejected: {
            imageBtn.highlighted = false
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
        objectName: "suggestionsBox"
        model: control.usersStore ? control.usersStore.usersModel : []
        x : messageInput.x
        y: -height - Style.current.smallPadding
        width: messageInput.width
        filter: messageInputField.text
        cursorPosition: messageInputField.cursorPosition
        property: ["nickname", "ensName", "name"]
        inputField: messageInputField
        onItemSelected: function (item, lastAtPosition, lastCursorPosition) {
            messageInputField.forceActiveFocus();
            const name = item[suggestionsBox.property.find(p => !!item[p])].replace("@", "")
            d.insertMention(name, item.publicKey, lastAtPosition, lastCursorPosition)
            suggestionsBox.suggestionsModel.clear()
        }
        onVisibleChanged: {
            if (!visible) {
                messageInputField.forceActiveFocus();
            }
        }
    }

    // TODO remove that Loader when the Chat Commands are re-implemented and fixed
    // Bonus if we use `openPopup` instead with a Component instead
    Loader {
        active: false
        sourceComponent: ChatCommandsPopup {
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
    }

    StatusGifPopup {
        id: gifPopup
        width: 360
        height: 440
        x: control.width - width - Style.current.halfPadding
        y: -height
        gifSelected: function (event, url) {
            messageInputField.text += "\n" + url
            control.sendMessage(event)
            control.isReply = false
            gifBtn.highlighted = false
            messageInputField.forceActiveFocus()
            if (control.closeGifPopupAfterSelection)
                gifPopup.close()
        }
        onClosed: {
            gifBtn.highlighted = false
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 4

        // TODO remove that Loader when the Chat Commands are re-implemented and fixed
        Loader {
            active: false
            sourceComponent: StatusQ.StatusFlatRoundButton {
                id: chatCommandsBtn
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 4
                icon.name: "chat-commands"
                type: StatusQ.StatusFlatRoundButton.Type.Tertiary
                visible: RootStore.isWalletEnabled && !isEdit && control.chatType === Constants.chatType.oneToOne
                enabled: !control.isContactBlocked
                onClicked: {
                    chatCommandsPopup.opened ?
                                chatCommandsPopup.close() :
                                chatCommandsPopup.open()
                }
            }
        }

        StatusQ.StatusFlatRoundButton {
            id: imageBtn
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
            icon.name: "image"
            type: StatusQ.StatusFlatRoundButton.Type.Tertiary
            visible: !isEdit
            enabled: !control.isContactBlocked
            onClicked: {
                highlighted = true
                imageDialog.open()
            }
        }

        Rectangle {
            id: messageInput

            readonly property int defaultInputFieldHeight: 40

            Layout.fillWidth: true


            implicitHeight: inputLayout.implicitHeight + inputLayout.anchors.topMargin + inputLayout.anchors.bottomMargin
            implicitWidth: inputLayout.implicitWidth + inputLayout.anchors.leftMargin + inputLayout.anchors.rightMargin

            enabled: !control.isContactBlocked
            color: isEdit ? Theme.palette.statusChatInput.secondaryBackgroundColor : Style.current.inputBackground
            radius: 20

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
                StatusChatInputTextFormationAction {
                    wrapper: "> "
                    icon.name: "quote"
                    text: qsTr("Quote")
                    checked: messageInputField.selectedText && isSelectedLinePrefixedBy(messageInputField.selectionStart, wrapper)

                    onActionTriggered: checked
                                       ? unprefixSelectedLine(wrapper)
                                       : prefixSelectedLine(wrapper)
                }
                onClosed: {
                    messageInputField.deselect();
                }
            }
            ColumnLayout {
                id: validators
                anchors.bottom: control.imageErrorMessageLocation === StatusChatInput.ImageErrorMessageLocation.Top ? parent.top : undefined
                anchors.bottomMargin: control.imageErrorMessageLocation === StatusChatInput.ImageErrorMessageLocation.Top ? -4 : undefined
                anchors.top: control.imageErrorMessageLocation === StatusChatInput.ImageErrorMessageLocation.Bottom ? parent.bottom : undefined
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
                // Bottom right corner has different radius
                color: parent.color
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                height: parent.height / 2
                width: 32
                radius: Style.current.radius
            }

            ColumnLayout {
                id: inputLayout
                width: parent.width
                spacing: 4

                StatusChatInputReplyArea {
                    id: replyArea
                    visible: isReply
                    Layout.fillWidth: true
                    Layout.margins: 2
                    onCloseButtonClicked: {
                        isReply = false
                    }
                }

                StatusChatInputImageArea {
                    id: imageArea
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.current.halfPadding
                    Layout.rightMargin: Style.current.halfPadding
                    visible: isImage
                    onImageClicked: {
                        Global.openImagePopup(chatImage)
                    }
                    onImageRemoved: {
                        if (control.fileUrlsAndSources.length > index && control.fileUrlsAndSources[index]) {
                            control.fileUrlsAndSources.splice(index, 1)
                        }
                        isImage = control.fileUrlsAndSources.length > 0
                        validateImages(control.fileUrlsAndSources)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.minimumHeight: (messageInputField.contentHeight + messageInputField.topPadding + messageInputField.bottomPadding)
                    Layout.maximumHeight: 112
                    spacing: Style.current.radius
                    StatusScrollView {
                        id: inputScrollView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        padding: 0
                        contentWidth: availableWidth

                        TextArea {
                            id: messageInputField

                            objectName: "messageInputField"

                            property var lastClick: 0
                            property int cursorWhenPressed: 0
                            property int previousCursorPosition: 0

                            width: inputScrollView.availableWidth

                            textFormat: Text.RichText
                            font.pixelSize: 15
                            font.family: Style.current.baseFont.name
                            wrapMode: TextArea.Wrap
                            placeholderText: control.chatInputPlaceholder
                            placeholderTextColor: Style.current.secondaryText
                            selectByMouse: true
                            color: isEdit ? Theme.palette.directColor1 : Style.current.textColor
                            topPadding: 9
                            bottomPadding: 9
                            leftPadding: 0
                            padding: 0
                            Keys.onUpPressed: {
                                if (isEdit && !activeFocus) {
                                    forceActiveFocus();
                                } else {
                                    if (messageInputField.length === 0) {
                                        control.keyUpPress();
                                    }
                                }
                                if (emojiSuggestions.visible) {
                                    emojiSuggestions.listView.decrementCurrentIndex();
                                }
                                event.accepted = false
                            }
                            Keys.onPressed: {
                                keyEvent = event;
                                onKeyPress(event)
                                cursorWhenPressed = cursorPosition;
                            }
                            Keys.onReleased: onRelease(event) // gives much more up to date cursorPosition
                            Keys.onShortcutOverride: event.accepted = isUploadFilePressed(event)
                            selectionColor: Style.current.primarySelectionColor
                            persistentSelection: true
                            property var keyEvent

                            Component.onDestruction: {
                                // NOTE: Without losing focus the app crashes on apply/cancel message editing.
                                control.forceActiveFocus();
                            }

                            onCursorPositionChanged: {
                                if(mentionsPos.length > 0 && ((keyEvent.key === Qt.Key_Left) || (keyEvent.key === Qt.Key_Right)
                                  || (selectedText.length>0))) {
                                    const mention = d.getMentionAtPosition(cursorPosition)
                                    if (mention) {
                                        const cursorMovingLeft = (cursorPosition < previousCursorPosition);
                                        const newCursorPosition = cursorMovingLeft ?
                                                                    mention.leftIndex :
                                                                    mention.rightIndex
                                        const isSelection = (selectedText.length>0);
                                        isSelection ? moveCursorSelection(newCursorPosition, TextEdit.SelectCharacters) :
                                                      cursorPosition = newCursorPosition
                                    }
                                }

                                inputScrollView.ensureVisible(cursorRectangle)
                                previousCursorPosition = cursorPosition
                            }

                            onTextChanged: {
                                if (length <= control.messageLimit) {
                                    if (length === 0) {
                                        mentionsPos = [];
                                    } else {
                                        checkForInlineEmojis()
                                    }
                                } else {
                                    const removeFrom = (cursorPosition < messageLimit) ? cursorWhenPressed : messageLimit;
                                    remove(removeFrom, cursorPosition);
                                }

                                d.updateMentionsPositions()
                                d.cleanMentionsPos()

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

                                    textFormatMenu.popup(x, messageInputField.y - textFormatMenu.height - 5)
                                    messageInputField.forceActiveFocus();
                                }
                                lastClick = now
                            }

                            onLinkActivated: {
                                const mention = d.getMentionAtPosition(cursorPosition - 1)
                                if(mention) {
                                    select(mention.leftIndex, mention.rightIndex)
                                }
                            }

                            onEnabledChanged: {
                                if (!enabled) {
                                    clear()
                                    control.hideExtendedArea()
                                }
                            }

                            cursorDelegate: StatusCursorDelegate {
                                cursorVisible: messageInputField.cursorVisible
                            }

                            StatusSyntaxHighlighter {
                                quickTextDocument: messageInputField.textDocument
                                codeBackgroundColor: Style.current.codeBackground
                                codeForegroundColor: Style.current.textColor
                            }
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                enabled: parent.hoveredLink
                                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
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

                    Column {
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: 3

                        StyledText {
                            id: messageLengthLimit
                            property int remainingChars: -1
                            leftPadding: Style.current.halfPadding
                            rightPadding: Style.current.halfPadding
                            visible: ((messageInputField.length >= control.messageLimitVisible) && (messageInputField.length <= control.messageLimit))
                            color: (remainingChars <= messageLimitVisible) ? Style.current.danger : Style.current.textColor
                            text: visible ? remainingChars.toString() : ""
                        }

                        Row {
                            id: actions
                            spacing: 2

                            StatusQ.StatusFlatRoundButton {
                                id: emojiBtn
                                objectName: "statusChatInputEmojiButton"
                                implicitHeight: 32
                                implicitWidth: 32
                                icon.name: "emojis"
                                icon.color: (hovered || highlighted) ? Theme.palette.primaryColor1
                                                                     : Theme.palette.baseColor1
                                type: StatusQ.StatusFlatRoundButton.Type.Tertiary
                                color: "transparent"
                                onClicked: {
                                    control.emojiPopupOpened = true

                                    togglePopup(emojiPopup, emojiBtn)
                                }
                            }

                            StatusQ.StatusFlatRoundButton {
                                id: gifBtn
                                objectName: "gifPopupButton"
                                implicitHeight: 32
                                implicitWidth: 32
                                visible: !isEdit && RootStore.isGifWidgetEnabled
                                icon.name: "gif"
                                icon.color: (hovered || highlighted) ? Theme.palette.primaryColor1
                                                                     : Theme.palette.baseColor1
                                type: StatusQ.StatusFlatRoundButton.Type.Tertiary
                                color: "transparent"
                                onClicked: togglePopup(gifPopup, gifBtn)
                            }

                            StatusQ.StatusFlatRoundButton {
                                id: stickersBtn
                                objectName: "statusChatInputStickersButton"
                                implicitHeight: 32
                                implicitWidth: 32
                                width: visible ? 32 : 0
                                icon.name: "stickers"
                                icon.color: (hovered || highlighted) ? Theme.palette.primaryColor1
                                                                     : Theme.palette.baseColor1
                                type: StatusQ.StatusFlatRoundButton.Type.Tertiary
                                visible: !isEdit && emojiBtn.visible
                                color: "transparent"
                                onClicked: {
                                    control.stickersPopupOpened = true

                                    togglePopup(control.stickersPopup, stickersBtn)
                                }
                            }
                        }
                    }
                }
            }
        }

        StatusQ.StatusButton {
            id: unblockBtn
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4
            visible: control.isContactBlocked
            text: qsTr("Unblock")
            type: StatusQ.StatusBaseButton.Type.Danger
            onClicked: control.unblockChat()
        }
    }
}
