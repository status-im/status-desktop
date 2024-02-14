import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0
import shared.stores 1.0
import shared.controls 1.0

ColumnLayout {
    id: root

    //**************************************************************************
    //* This component is not refactored, just pulled out to a shared location *
    //**************************************************************************
    spacing: Style.current.padding
    clip: true

    readonly property bool seedPhraseIsValid: d.allEntriesValid && invalidSeedTxt.text === ""
    property var isSeedPhraseValid: function (mnemonic) { return false }
    property ListModel dictionary: BIP39_en {}

    signal submitSeedPhrase()
    signal seedPhraseUpdated(bool valid, string seedPhrase)

    function setWrongSeedPhraseMessage(message) {
        invalidSeedTxt.text = message
        // Validate again the seed phrase
        // This is needed because the message can be set to empty and the seed phrase is still invalid
        if (message === "")
            d.validate()
    }

    function getSeedPhraseAsString() {
        return d.buildMnemonicString()
    }

    QtObject {
        id: d

        property bool allEntriesValid: false
        property var mnemonicInput: []
        property var incorrectWordAtIndex: []
        readonly property var tabs: [12, 18, 24]
        readonly property alias seedPhrases_en: root.dictionary

        onIncorrectWordAtIndexChanged: d.validate()

        onAllEntriesValidChanged: {
            let mnemonicString = ""

            if (d.allEntriesValid) {

                mnemonicString = buildMnemonicString()
                if (!Utils.isMnemonic(mnemonicString) || !root.isSeedPhraseValid(mnemonicString)) {
                    root.setWrongSeedPhraseMessage(qsTr("Invalid seed phrase"))
                    d.allEntriesValid = false
                }
            }
            root.seedPhraseUpdated(d.allEntriesValid, mnemonicString)
        }

        function validate() {
            if (d.incorrectWordAtIndex.length > 0) {
                invalidSeedTxt.text = qsTr("The phrase you’ve entered is invalid")
                return
            }

            invalidSeedTxt.text = ""
        }

        function checkMnemonicLength() {
            d.allEntriesValid = d.mnemonicInput.length === d.tabs[switchTabBar.currentIndex] && d.incorrectWordAtIndex.length === 0
        }

        function buildMnemonicString() {
            const sortTable = mnemonicInput.sort((a, b) => a.pos - b.pos)
            return sortTable.map(x => x.seed).join(" ")
        }

        function checkWordExistence(word, pos) {
            if (word !== "" && !ModelUtils.contains(d.seedPhrases_en, "seedWord", word)) {
                const incorrectWordAtIndex = d.incorrectWordAtIndex
                incorrectWordAtIndex.push(pos)
                d.incorrectWordAtIndex = incorrectWordAtIndex
                return
            }
            
            d.incorrectWordAtIndex = d.incorrectWordAtIndex.filter(function(value) {
                return value !== pos
            })
        }

        function pasteWords () {
            const clipboardText = Utils.getFromClipboard()

            // Split words separated by commas and or blank spaces (spaces, enters, tabs)
            const words = clipboardText.trim().split(/[, \s]+/)
            
            let index = d.tabs.indexOf(words.length)
            if (index === -1) {
                return false
            }

            let timeout = 0
            if (switchTabBar.currentIndex !== index) {
                switchTabBar.currentIndex = index
                // Set the teimeout to 100 so the grid has time to generate the new items
                timeout = 100
            }

            d.mnemonicInput = []
            timer.setTimeout(() => {
                                 // Populate mnemonicInput
                                 for (let i = 0; i <  words.length; i++) {
                                     grid.addWord(i + 1, words[i], true)
                                 }
                                 // Populate grid
                                 for (let j = 0; j <  grid.count; j++) {
                                     const item = grid.itemAtIndex(j)
                                     if (!item || !item.leftComponentText) {
                                         // The grid has gaps in it and also sometimes doesn't return the item correctly when offscreen
                                         // in those cases, we just add the word in the array but not in the grid.
                                         // The button will still work and import correctly. The Grid itself will be partly empty, but offscreen
                                         // With the re-design of the grid, this should be fixed
                                         continue
                                     }
                                     const pos = item.mnemonicIndex
                                     item.setWord(words[pos - 1])
                                 }
                                 d.checkMnemonicLength()
                             }, timeout)
            return true
        }
    }



    Timer {
        id: timer
    }

    StatusSwitchTabBar {
        id: switchTabBar
        objectName: "enterSeedPhraseSwitchBar"
        Layout.alignment: Qt.AlignHCenter
        Repeater {
            model: d.tabs
            StatusSwitchTabButton {
                text: qsTr("%n word(s)", "", modelData)
                id: seedPhraseWords
                objectName: `${modelData}SeedButton`
            }
        }
        onCurrentIndexChanged: {
            d.mnemonicInput = d.mnemonicInput.filter(function(value) {
                return value.pos <= d.tabs[switchTabBar.currentIndex]
            })
            d.incorrectWordAtIndex = d.incorrectWordAtIndex.filter(function(value) {
                return value <= d.tabs[switchTabBar.currentIndex]
            })
            d.checkMnemonicLength()
        }
    }

    StatusGridView {
        id: grid
        readonly property var wordIndex: [
            ["1", "3", "5", "7", "9", "11", "2", "4", "6", "8", "10", "12"]
            ,["1", "4", "7", "10", "13", "16", "2", "5", "8",
              "11", "14", "17", "3", "6", "9", "12", "15", "18"]
            ,["1", "5", "9", "13", "17", "21", "2", "6", "10", "14", "18", "22",
              "3", "7", "11", "15", "19", "23", "4", "8", "12", "16", "20", "24"]
        ]
        
        objectName: "enterSeedPhraseGridView"
        Layout.fillWidth: true
        Layout.preferredHeight: 312
        clip: false
        flow: GridView.FlowTopToBottom
        cellWidth: (parent.width/(count/6))
        cellHeight: 52
        interactive: false
        model: switchTabBar.currentItem.text.substring(0,2)

        function addWord(pos, word, ignoreGoingNext = false) {

            const words = d.mnemonicInput

            words.push({pos: pos, seed: word.replace(/\s/g, '')})

            for (let j = 0; j < words.length; j++) {
                if (words[j].pos === pos && words[j].seed !== word) {
                    words[j].seed = word
                    break
                }
            }
            //remove duplicates
            const valueArr = words.map(item => item.pos)
            const isDuplicate = valueArr.some((item, idx) => {
                                                  if (valueArr.indexOf(item) !== idx) {
                                                      words.splice(idx, 1)
                                                  }
                                                  return valueArr.indexOf(item) !== idx
                                              })
            if (!ignoreGoingNext) {
                for (let i = 0; i < grid.count; i++) {
                    const item = grid.itemAtIndex(i)
                    if (!item || item.mnemonicIndex !== (pos + 1)) {
                        continue
                    }

                    grid.currentIndex = item.itemIndex
                    item.textEdit.input.edit.forceActiveFocus()

                    if (grid.currentIndex !== 12) {
                        continue
                    }

                    grid.positionViewAtEnd()

                    if (grid.count === 20) {
                        grid.contentX = 1500
                    }
                }
            }
            d.mnemonicInput = words
            d.checkWordExistence(word, pos)
            d.checkMnemonicLength()
            root.seedPhraseUpdated(d.allEntriesValid, d.buildMnemonicString())
        }

        delegate: StatusSeedPhraseInput {
            id: seedWordInput

            textEdit.input.edit.objectName: `enterSeedPhraseInputField${seedWordInput.leftComponentText}`
            width: (grid.cellWidth - 8)
            height: (grid.cellHeight - 8)
            Behavior on width { NumberAnimation { duration: 180 } }
            textEdit.text: {
                const pos = seedWordInput.mnemonicIndex
                for (let i in d.mnemonicInput) {
                    const p = d.mnemonicInput[i]
                    if (p.pos === pos) {
                        return p.seed
                    }
                }
                return ""
            }

            readonly property int mnemonicIndex: grid.wordIndex[(grid.count / 6) - 2][index]

            leftComponentText: mnemonicIndex
            inputList: d.seedPhrases_en

            property int itemIndex: index
            onDoneInsertingWord: {
                grid.addWord(mnemonicIndex, word)
            }
            onEditingFinished: {
                if (text === "") {
                    return
                }

                grid.addWord(mnemonicIndex, text, true)
            }
            onEditClicked: {
                grid.currentIndex = index
                grid.itemAtIndex(index).textEdit.input.edit.forceActiveFocus()
            }
            onKeyPressed: {
                grid.currentIndex = index

                if (event.key === Qt.Key_Backtab) {
                    for (let i = 0; i < grid.count; i++) {
                        if (grid.itemAtIndex(i).mnemonicIndex === ((mnemonicIndex - 1) >= 0 ? (mnemonicIndex - 1) : 0)) {
                            grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus(Qt.BacktabFocusReason)
                            textEdit.input.tabNavItem = grid.itemAtIndex(i).textEdit.input.edit
                            event.accepted = true
                            break
                        }
                    }
                } else if (event.key === Qt.Key_Tab) {
                    for (let i = 0; i < grid.count; i++) {
                        if (grid.itemAtIndex(i).mnemonicIndex === ((mnemonicIndex + 1) <= grid.count ? (mnemonicIndex + 1) : grid.count)) {
                            grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus(Qt.TabFocusReason)
                            textEdit.input.tabNavItem = grid.itemAtIndex(i).textEdit.input.edit
                            event.accepted = true
                            break
                        }
                    }
                }

                if (event.matches(StandardKey.Paste)) {
                    if (d.pasteWords()) {
                        // Paste was done by splitting the words
                        event.accepted = true
                    }
                    return
                }

                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    event.accepted = true
                    if (d.allEntriesValid) {
                        root.submitSeedPhrase()
                        return
                    }
                }

                if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
                    const wordIndex = d.mnemonicInput.findIndex(x => x.pos === mnemonicIndex)
                    if (wordIndex > -1) {
                        d.mnemonicInput.splice(wordIndex, 1)
                        d.checkMnemonicLength()
                    }
                }
            }
            Component.onCompleted: {
                const item = grid.itemAtIndex(0)
                if (item) {
                    item.textEdit.input.edit.forceActiveFocus()
                }
            }
        }
    }

    StatusBaseText {
        id: invalidSeedTxt
        objectName: "enterSeedPhraseInvalidSeedText"
        Layout.alignment: Qt.AlignHCenter
        color: Theme.palette.dangerColor1
    }
}
