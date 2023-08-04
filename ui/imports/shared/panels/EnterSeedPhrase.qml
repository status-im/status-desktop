import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
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

    property var isSeedPhraseValid: function (mnemonic) { return false }

    signal submitSeedPhrase()
    signal seedPhraseUpdated(bool valid, string seedPhrase)

    function setWrongSeedPhraseMessage(message) {
        invalidSeedTxt.text = message
    }

    QtObject {
        id: d

        property bool allEntriesValid: false
        property var mnemonicInput: []
        readonly property var tabs: [12, 18, 24]
        readonly property ListModel seedPhrases_en: BIP39_en {}

        onAllEntriesValidChanged: {
            let mnemonicString = ""
            if (d.allEntriesValid) {
                const sortTable = mnemonicInput.sort((a, b) => a.pos - b.pos)
                for (let i = 0; i < mnemonicInput.length; i++) {
                    d.checkWordExistence(sortTable[i].seed)
                    mnemonicString += sortTable[i].seed + ((i === (grid.count-1)) ? "" : " ")
                }

                if (!Utils.isMnemonic(mnemonicString) || !root.isSeedPhraseValid(mnemonicString)) {
                    root.setWrongSeedPhraseMessage(qsTr("Invalid seed phrase"))
                    d.allEntriesValid = false
                }
            }
            root.seedPhraseUpdated(d.allEntriesValid, mnemonicString)
        }

        function checkMnemonicLength() {
            d.allEntriesValid = d.mnemonicInput.length === d.tabs[switchTabBar.currentIndex]
        }

        function checkWordExistence(word) {
            d.allEntriesValid = d.allEntriesValid && d.seedPhrases_en.words.includes(word)
            if (d.allEntriesValid) {
                root.setWrongSeedPhraseMessage("")
            }
            else {
                root.setWrongSeedPhraseMessage(qsTr("The phrase you’ve entered is invalid"))
            }
        }

        function pasteWords () {
            const clipboardText = globalUtils.getFromClipboard()
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
        Layout.preferredWidth: parent.width
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
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 312
        clip: false
        flow: GridView.FlowTopToBottom
        cellWidth: (parent.width/(count/6))
        cellHeight: 52
        interactive: false
        z: 100000
        cacheBuffer: 9999
        model: switchTabBar.currentItem.text.substring(0,2)

        function addWord(pos, word, ignoreGoingNext = false) {
            d.mnemonicInput.push({pos: pos, seed: word.replace(/\s/g, '')})

            for (let j = 0; j < d.mnemonicInput.length; j++) {
                if (d.mnemonicInput[j].pos === pos && d.mnemonicInput[j].seed !== word) {
                    d.mnemonicInput[j].seed = word
                    break
                }
            }
            //remove duplicates
            const valueArr = d.mnemonicInput.map(item => item.pos)
            const isDuplicate = valueArr.some((item, idx) => {
                                                  if (valueArr.indexOf(item) !== idx) {
                                                      d.mnemonicInput.splice(idx, 1)
                                                  }
                                                  return valueArr.indexOf(item) !== idx
                                              })
            if (!ignoreGoingNext) {
                for (let i = 0; i < grid.count; i++) {
                    if (grid.itemAtIndex(i).mnemonicIndex !== (pos + 1)) {
                        continue
                    }

                    grid.currentIndex = grid.itemAtIndex(i).itemIndex
                    grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus()

                    if (grid.currentIndex !== 12) {
                        continue
                    }

                    grid.positionViewAtEnd()

                    if (grid.count === 20) {
                        grid.contentX = 1500
                    }
                }
            }
            d.checkMnemonicLength()
        }

        delegate: StatusSeedPhraseInput {
            id: seedWordInput
            textEdit.input.edit.objectName: `statusSeedPhraseInputField${seedWordInput.leftComponentText}`
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
            z: (grid.currentIndex === index) ? 150000000 : 0
            onTextChanged: {
                d.checkWordExistence(text)
            }
            onDoneInsertingWord: {
                grid.addWord(mnemonicIndex, word)
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
        visible: text !== ""
        Layout.alignment: Qt.AlignHCenter
        color: Theme.palette.dangerColor1
    }
}
