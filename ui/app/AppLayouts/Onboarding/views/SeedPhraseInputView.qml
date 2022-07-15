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

OnboardingBasePage {
    id: root

    state: "existingUser"

    property bool existingUser: (root.state === "existingUser")
    property var mnemonicInput: []

    signal seedValidated()

    readonly property var tabs: ([12, 18, 24])

    Timer {
        id: timer
    }

    function pasteWords () {
        const clipboardText = globalUtils.getFromClipboard()
        // Split words separated by commas and or blank spaces (spaces, enters, tabs)
        let words = clipboardText.split(/[, \s]+/)

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
        timer.setTimeout(function() {
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
                let pos = parseInt(item.leftComponentText)
                item.setWord(words[pos - 1])
            }
            submitButton.checkMnemonicLength()
        }, timeout);
        return true
    }

    Connections {
        target: OnboardingStore.onboardingModuleInst
        onAccountImportError: {
            if (error === Constants.existingAccountError) {
                importSeedError.title = qsTr("Keys for this account already exist")
                importSeedError.text = qsTr("Keys for this account already exist and can't be added again. If you've lost your password, passcode or Keycard, uninstall the app, reinstall and access your keys by entering your seed phrase")
            } else {
                importSeedError.title = qsTr("Error importing seed")
                importSeedError.text = error
            }
            importSeedError.open()
        }
        onAccountImportSuccess: {
            root.seedValidated()
        }
    }

    MessageDialog {
        id: importSeedError
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
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
            anchors.top: headlineText.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 24
            Repeater {
                model: root.tabs
                 StatusSwitchTabButton {
                    text: qsTr("%1 words").arg(modelData)
                    id: seedPhraseWords
                    objectName: qsTr("%1SeedButton").arg(modelData)
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

        GridView {
            id: grid
            width: parent.width
            property var wordIndex: [
                ["1", "3", "5", "7", "9", "11", "2", "4", "6", "8", "10", "12"]
               ,["1", "4", "7", "10", "13", "16", "2", "5", "8",
                 "11", "14", "17", "3", "6", "9", "12", "15", "18"]
               ,["1", "5", "9", "13", "17", "21", "2", "6", "10", "14", "18", "22",
                 "3", "7", "11", "15", "19", "23", "4", "8", "12", "16", "20", "24"]
            ]
            height: 312
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

            function addWord(pos, word, ignoreGoingNext) {
                root.mnemonicInput.push({pos: parseInt(pos), seed: word.replace(/\s/g, '')});
                for (var j = 0; j < mnemonicInput.length; j++) {
                    if (mnemonicInput[j].pos === pos && mnemonicInput[j].seed !== word) {
                        mnemonicInput[j].seed = word;
                        break;
                    }
                }
                //remove duplicates
                var valueArr = mnemonicInput.map(function(item){ return item.pos });
                var isDuplicate = valueArr.some(function(item, idx){
                    if (valueArr.indexOf(item) !== idx) {
                        root.mnemonicInput.splice(idx, 1);
                    }
                    return valueArr.indexOf(item) !== idx
                });
                if (!ignoreGoingNext) {
                    for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
                        if (parseInt(grid.itemAtIndex(i).leftComponentText) !== (parseInt(pos)+1)) {
                            continue
                        }

                        grid.currentIndex = grid.itemAtIndex(i).itemIndex;
                        grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus();

                        if (grid.currentIndex !== 12) {
                            continue
                        }

                        grid.positionViewAtEnd();

                        if (grid.count === 20) {
                            grid.contentX = 1500;
                        }
                    }
                }
                submitButton.checkMnemonicLength()
            }

            delegate: StatusSeedPhraseInput {
                id: seedWordInput
                width: (grid.cellWidth - 8)
                height: (grid.cellHeight - 8)
                Behavior on width { NumberAnimation { duration: 180 } }
                textEdit.text: {
                    let pos = parseInt(seedWordInput.leftComponentText)
                    for (var i in root.mnemonicInput) {
                        let p = root.mnemonicInput[i]
                        if (p.pos === pos) {
                            return p.seed
                        }
                    }
                    return ""
                }
                leftComponentText: grid.wordIndex[(grid.count/6)-2][index]
                inputList: BIP39_en { }
                property int itemIndex: index
                z: (grid.currentIndex === index) ? 150000000 : 0
                onTextChanged: {
                    invalidSeedTxt.visible = false;
                }
                onDoneInsertingWord: {
                    grid.addWord(leftComponentText, word)
                }
                onEditClicked: {
                    grid.currentIndex = index;
                    grid.itemAtIndex(index).textEdit.input.edit.forceActiveFocus();
                }
                onKeyPressed: {
                    grid.currentIndex = index;

                    if (event.key === Qt.Key_Backtab) {
                        for (var i = 0; i < grid.count; i++) {
                            if (parseInt(grid.itemAtIndex(i).leftComponentText) === ((parseInt(leftComponentText)-1) >= 0 ? (parseInt(leftComponentText)-1) : 0)) {
                                grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus(Qt.BacktabFocusReason);
                                textEdit.input.tabNavItem = grid.itemAtIndex(i).textEdit.input.edit;
                                event.accepted = true
                                break
                            }
                        }
                    } else if (event.key === Qt.Key_Tab) {
                        for (var i = 0; i < grid.count; i++) {
                            if (parseInt(grid.itemAtIndex(i).leftComponentText) === ((parseInt(leftComponentText)+1) <= grid.count ? (parseInt(leftComponentText)+1) : grid.count)) {
                                grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus(Qt.TabFocusReason);
                                textEdit.input.tabNavItem = grid.itemAtIndex(i).textEdit.input.edit;
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
                        var wordIndex = mnemonicInput.findIndex(x => x.pos === parseInt(leftComponentText));
                        if (wordIndex > -1) {
                            mnemonicInput.splice(wordIndex , 1);
                            submitButton.checkMnemonicLength()
                        }
                    }
                }
                Component.onCompleted: {
                    let item = grid.itemAtIndex(0)
                    if (item) {
                        item.textEdit.input.edit.forceActiveFocus();
                    }
                }
            }
        }

        StatusBaseText {
            id: invalidSeedTxt
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: grid.bottom
            anchors.topMargin: 24
            color: Theme.palette.dangerColor1
            visible: false
            text: qsTr("Invalid seed")
        }

        StatusButton {
            id: submitButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: invalidSeedTxt.bottom
            anchors.topMargin: 24
            enabled: false
            function checkMnemonicLength() {
                submitButton.enabled = (root.mnemonicInput.length === root.tabs[switchTabBar.currentIndex])
            }
            text: root.existingUser ? qsTr("Restore Status Profile") : qsTr("Import")
            onClicked: {
                let mnemonicString = "";
                var sortTable = mnemonicInput.sort(function (a, b) {
                    return a.pos - b.pos;
                });
                for (var i = 0; i < mnemonicInput.length; i++) {
                    mnemonicString += sortTable[i].seed + ((i === (grid.count-1)) ? "" : " ");
                }
                if (Utils.isMnemonic(mnemonicString) && !OnboardingStore.validateMnemonic(mnemonicString)) {
                    OnboardingStore.importMnemonic(mnemonicString)
                    root.mnemonicInput = [];
                } else {
                    invalidSeedTxt.visible = true;
                    enabled = false;
                }
            }
        }
    }

    onBackClicked: {
        root.mnemonicInput = [];
        root.exit();
    }
}
