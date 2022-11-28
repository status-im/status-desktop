import QtQuick 2.0
import QtQuick.Controls 2.14

import utils 1.0
//TODO: remove: used for emojy only
import StatusQ.Core.Utils 0.1 as StatusQUtils
/***
This is the mentions decorator of TextArea object
***/
Item {
    id: root

    //wrapee
    property TextArea textInput

    //TODO: clean the public API
    function parseMessage(message) {
        d.parseMessage(message)
    }

    function insertMention(aliasName, publicKey, lastAtPosition, lastCursorPosition) {
        d.insertMention(aliasName, publicKey, lastAtPosition, lastCursorPosition)
    }

    function copyMentions(start, end) {
        d.copyMentions(start, end)
    }

    function pasteMentions(copiedPlainText, copiedFormattedText) {
        d.pasteMentions(copiedPlainText, copiedFormattedText)
    }

    function updateMentionsPositions() {
        d.updateMentionsPositions()
    }

    function discardCopiedMentions() {
        d.copiedMentionsPos = []
    }

    function getTextWithPublicKeys() {
        return d.getTextWithPublicKeys()
    }

    Keys.onPressed: d.handleKeyPress(event)

    Connections {
        target: textInput
        function onTextChanged() {
            d.updateMentionsPositions()
        }
        function onCursorPositionChanged() {
            d.handleCursorPositionChanged()
        }
    }

    QtObject {
        id: d
        property var mentionsPos: []
        property var copiedMentionsPos: []

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

        function insertMention(aliasName, publicKey, lastAtPosition, lastCursorPosition) {
            let startInd = aliasName.indexOf("(");
            if (startInd > 0){
                aliasName = aliasName.substring(0, startInd-1)
            }

            //TODO: remove emoji dependency
            const hasEmoji = StatusQUtils.Emoji.hasEmoji(textInput.text)
            const spanPlusAlias = `${Constants.mentionSpanTag}@${aliasName}</a></span> `;
            let rightIndex = hasEmoji ? lastCursorPosition + 2 : lastCursorPosition
            textInput.remove(lastAtPosition, rightIndex)
            textInput.insert(lastAtPosition, spanPlusAlias)
            textInput.cursorPosition = lastAtPosition + aliasName.length + 2;
            if (textInput.cursorPosition === 0) {
                // It reset to 0 for some reason, go back to the end
                textInput.cursorPosition = textInput.length
            }
            d.mentionsPos.push({name: aliasName, pubKey: publicKey, leftIndex: lastAtPosition, rightIndex: (lastAtPosition+aliasName.length + 1)});
            d.sortMentions()
        }

        function copyMentions(start, end) {
            d.copiedMentionsPos = []
            for (let k = 0; k < d.mentionsPos.length; k++) {
                if (d.mentionsPos[k].leftIndex >= start && d.mentionsPos[k].rightIndex <= end) {
                    const mention = {
                        name: d.mentionsPos[k].name,
                        pubKey: d.mentionsPos[k].pubKey,
                        leftIndex: d.mentionsPos[k].leftIndex - start,
                        rightIndex: d.mentionsPos[k].rightIndex - start
                    }
                    d.copiedMentionsPos.push(mention)
                }
            }
        }

        function pasteMentions(copiedPlainText, copiedFormattedText) {
            if (copiedPlainText.includes("@")) {
                copiedFormattedText = copiedFormattedText.replace(/span style="/g, "span style=\" text-decoration:none;")

                let lastFoundIndex = -1
                for (let j = 0; j < d.copiedMentionsPos.length; j++) {
                    const name = d.copiedMentionsPos[j].name
                    const indexOfName = copiedPlainText.indexOf(name, lastFoundIndex)
                    lastFoundIndex += name.length

                    if (indexOfName === d.copiedMentionsPos[j].leftIndex + 1) {
                        const mention = {
                            name: name,
                            pubKey: d.copiedMentionsPos[j].pubKey,
                            leftIndex: (d.copiedMentionsPos[j].leftIndex + d.copyTextStart - 1),
                            rightIndex: (d.copiedMentionsPos[j].leftIndex + d.copyTextStart + name.length)
                        }
                        d.mentionsPos.push(mention)
                        d.sortMentions()
                    }
                }
            }
        }

        function handleCursorPositionChanged() {
            if (mentionsPos.length > 0) {
                for (var i = 0; i < mentionsPos.length; i++) {
                    if ((textInput.cursorPosition === (mentionsPos[i].leftIndex + 1)) && (textInput.keyEvent.key === Qt.Key_Right)) {
                        textInput.cursorPosition = mentionsPos[i].rightIndex;
                    } else if (textInput.cursorPosition === (mentionsPos[i].rightIndex - 1)) {
                        if (textInput.keyEvent.key === Qt.Key_Left) {
                            textInput.cursorPosition = mentionsPos[i].leftIndex;
                        } else if ((textInput.keyEvent.key === Qt.Key_Backspace) || (textInput.keyEvent.key === Qt.Key_Delete)) {
                            textInput.remove(mentionsPos[i].rightIndex, mentionsPos[i].leftIndex);
                            d.mentionsPos.pop(i);
                            d.sortMentions()
                        }
                    } else if (((textInput.cursorPosition > mentionsPos[i].leftIndex) &&
                                (textInput.cursorPosition  < mentionsPos[i].rightIndex)) &&
                               ((textInput.keyEvent.key === Qt.Key_Left) && ((textInput.keyEvent.modifiers & Qt.AltModifier) ||
                                                                   (textInput.keyEvent.modifiers & Qt.ControlModifier)))) {
                        textInput.cursorPosition = mentionsPos[i].leftIndex;
                    } else if ((textInput.keyEvent.key === Qt.Key_Up) || (textInput.keyEvent.key === Qt.Key_Down)) {
                        if (textInput.cursorPosition >= mentionsPos[i].leftIndex &&
                                textInput.cursorPosition <= (((mentionsPos[i].leftIndex + mentionsPos[i].rightIndex)/2))) {
                            textInput.cursorPosition = mentionsPos[i].leftIndex;
                        } else if (textInput.cursorPosition <= mentionsPos[i].rightIndex &&
                                   textInput.cursorPosition > (((mentionsPos[i].leftIndex + mentionsPos[i].rightIndex)/2))) {
                            textInput.cursorPosition = mentionsPos[i].rightIndex;
                        }
                    }
                }
            }
        }

        function sortMentions() {
            if (d.mentionsPos.length < 2) {
                return
            }
            d.mentionsPos = d.mentionsPos.sort(function(a, b){
                return a.leftIndex - b.leftIndex
            })
        }

        function updateMentionsPositions() {
            if (d.mentionsPos.length == 0) {
                return
            }

            const unformattedText = textInput.getText(0, textInput.length)
            if (!unformattedText.includes("@")) {
                return
            }

            const keyEvent = textInput.keyEvent
            if ((keyEvent.key === Qt.Key_Right) || (keyEvent.key === Qt.Key_Left)
                    || (keyEvent.key === Qt.Key_Up) || (keyEvent.key === Qt.Key_Down)) {
                return
            }

            let lastRightIndex = -1
            for (var k = 0; k < d.mentionsPos.length; k++) {
                const aliasIndex = unformattedText.indexOf(d.mentionsPos[k].name, lastRightIndex)
                if (aliasIndex === -1) {
                    continue
                }
                lastRightIndex = aliasIndex + d.mentionsPos[k].name.length

                if (aliasIndex - 1 !== d.mentionsPos[k].leftIndex) {
                    d.mentionsPos[k].leftIndex = aliasIndex - 1
                    d.mentionsPos[k].rightIndex = aliasIndex + d.mentionsPos[k].name.length
                }
            }
        }

        function handleKeyPress(event) {
            if (d.mentionsPos.length > 0) {
                for (var i = 0; i < d.mentionsPos.length; i++) {
                    if ((textInput.cursorPosition === (d.mentionsPos[i].leftIndex))
                            && (event.key === Qt.Key_Delete)) {
                        textInput.remove(d.mentionsPos[i].rightIndex, d.mentionsPos[i].leftIndex)
                        d.mentionsPos.pop(i)
                        d.sortMentions()
                    }
                }
            }
        }

        function getTextWithPublicKeys() {
            let result = textInput.text
            if (d.mentionsPos.length > 0) {
                for (var k = 0; k < d.mentionsPos.length; k++) {
                    let leftIndex = result.indexOf(d.mentionsPos[k].name)
                    let rightIndex = leftIndex + d.mentionsPos[k].name.length
                    result = result.substring(0, leftIndex)
                             + d.mentionsPos[k].pubKey
                             + result.substring(rightIndex, result.length)
                }
            }
            return result
        }
    }
}
