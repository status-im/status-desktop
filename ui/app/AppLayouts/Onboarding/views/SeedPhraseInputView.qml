import QtQuick 2.12
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.stores 1.0
import shared.controls 1.0

import "../controls"
import "../stores"

Item {
    id: root

    property StartupStore startupStore

    property var mnemonicInput: []

    signal seedValidated()

    readonly property var tabs: [12, 18, 24]

    Timer {
        id: timer
    }

    function pasteWords () {
        const clipboardText = globalUtils.getFromClipboard()
        // Split words separated by commas and or blank spaces (spaces, enters, tabs)
        const words = clipboardText.split(/[, \s]+/)

        let index = root.tabs.indexOf(words.length)
        if (index === -1) {
            return false
        }
        
        let timeout = 0
        if (switchTabBar.currentIndex !== index) {
            switchTabBar.currentIndex = index
            // Set the teimeout to 100 so the grid has time to generate the new items
            timeout = 100
        }

        root.mnemonicInput = []
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
            submitButton.checkMnemonicLength()
        }, timeout)
        return true
    }

    Item {
        implicitWidth: 565
        implicitHeight: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        StatusBaseText {
            id: headlineText
            font.pixelSize: 22
            font.weight: Font.Bold
            color: Theme.palette.directColor1
            anchors.top: parent.top
            anchors.topMargin: (root.height - parent.childrenRect.height)/2
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Enter seed phrase")
        }

        StatusSwitchTabBar {
            id: switchTabBar
            objectName: "onboardingSeedPhraseSwitchBar"
            anchors.top: headlineText.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 24
            Repeater {
                model: root.tabs
                 StatusSwitchTabButton {
                    text: qsTr("%n word(s)", "", modelData)
                    id: seedPhraseWords
                    objectName: `${modelData}SeedButton`
                }
            }
            onCurrentIndexChanged: {
                root.mnemonicInput = root.mnemonicInput.filter(function(value) {
                    return value.pos <= root.tabs[switchTabBar.currentIndex]
                })
                submitButton.checkMnemonicLength()
            }
        }
        clip: true

        StatusGridView {
            id: grid
            objectName: "seedPhraseGridView"
            width: parent.width
            readonly property var wordIndex: [
                ["1", "3", "5", "7", "9", "11", "2", "4", "6", "8", "10", "12"]
               ,["1", "4", "7", "10", "13", "16", "2", "5", "8",
                 "11", "14", "17", "3", "6", "9", "12", "15", "18"]
               ,["1", "5", "9", "13", "17", "21", "2", "6", "10", "14", "18", "22",
                 "3", "7", "11", "15", "19", "23", "4", "8", "12", "16", "20", "24"]
            ]
            height: 312
            clip: false
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: switchTabBar.bottom
            anchors.topMargin: 24
            flow: GridView.FlowTopToBottom
            cellWidth: (parent.width/(count/6)) - 8
            cellHeight: 52
            interactive: false
            z: 100000
            cacheBuffer: 9999
            model: switchTabBar.currentItem.text.substring(0,2)

            function addWord(pos, word, ignoreGoingNext = false) {
                mnemonicInput.push({pos: pos, seed: word.replace(/\s/g, '')})

                for (let j = 0; j < mnemonicInput.length; j++) {
                    if (mnemonicInput[j].pos === pos && mnemonicInput[j].seed !== word) {
                        mnemonicInput[j].seed = word
                        break
                    }
                }
                //remove duplicates
                const valueArr = mnemonicInput.map(item => item.pos)
                const isDuplicate = valueArr.some((item, idx) => {
                    if (valueArr.indexOf(item) !== idx) {
                        root.mnemonicInput.splice(idx, 1)
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
                submitButton.checkMnemonicLength()
            }

            delegate: StatusSeedPhraseInput {
                id: seedWordInput
                textEdit.input.edit.objectName: `statusSeedPhraseInputField${seedWordInput.leftComponentText}`
                width: (grid.cellWidth - 8)
                height: (grid.cellHeight - 8)
                Behavior on width { NumberAnimation { duration: 180 } }
                textEdit.text: {
                    const pos = seedWordInput.mnemonicIndex
                    for (let i in root.mnemonicInput) {
                        const p = root.mnemonicInput[i]
                        if (p.pos === pos) {
                            return p.seed
                        }
                    }
                    return ""
                }

                readonly property int mnemonicIndex: grid.wordIndex[(grid.count / 6) - 2][index]

                leftComponentText: mnemonicIndex
                inputList: BIP39_en {}

                property int itemIndex: index
                z: (grid.currentIndex === index) ? 150000000 : 0
                onTextChanged: {
                    invalidSeedTxt.visible = false
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
                        if (root.pasteWords()) {
                            // Paste was done by splitting the words
                            event.accepted = true
                        }
                        return
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true
                        if (submitButton.enabled) {
                            submitButton.clicked(null)
                            return
                        }
                    }

                    if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
                        const wordIndex = mnemonicInput.findIndex(x => x.pos === mnemonicIndex)
                        if (wordIndex > -1) {
                            mnemonicInput.splice(wordIndex, 1)
                            submitButton.checkMnemonicLength()
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
            objectName: "onboardingInvalidSeedText"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: grid.bottom
            anchors.topMargin: 24
            color: Theme.palette.dangerColor1
            visible: false
            text: qsTr("Invalid seed")
        }

        StatusButton {
            id: submitButton
            objectName: "seedPhraseViewSubmitButton"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: invalidSeedTxt.bottom
            anchors.topMargin: 24
            enabled: false
            function checkMnemonicLength() {
                submitButton.enabled = (root.mnemonicInput.length === root.tabs[switchTabBar.currentIndex])
            }
            text: {
                if (root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunNewUserImportSeedPhrase) {
                    return qsTr("Import")
                }
                else if (root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunOldUserImportSeedPhrase) {
                    return qsTr("Restore Status Profile")
                }
                else if (root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunOldUserKeycardImport ||
                         root.startupStore.currentStartupState.flowType === Constants.startupFlow.appLogin) {
                    return qsTr("Recover Keycard")
                }
                else if (root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunNewUserImportSeedPhraseIntoKeycard) {
                    return qsTr("Next")
                }
                return ""
            }
            onClicked: {
                let mnemonicString = ""
                const sortTable = mnemonicInput.sort((a, b) => a.pos - b.pos)
                for (let i = 0; i < mnemonicInput.length; i++) {
                    mnemonicString += sortTable[i].seed + ((i === (grid.count-1)) ? "" : " ")
                }

                if (Utils.isMnemonic(mnemonicString) && root.startupStore.validMnemonic(mnemonicString)) {
                    root.mnemonicInput = []
                    root.startupStore.doPrimaryAction()
                } else {
                    invalidSeedTxt.visible = true
                    enabled = false
                }
            }
        }
    }
}
