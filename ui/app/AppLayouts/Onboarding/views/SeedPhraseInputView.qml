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
    property string mnemonicString

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
        implicitWidth: 731
        implicitHeight: 472
        anchors.centerIn: parent

        StatusBaseText {
            id: headlineText
            font.pixelSize: 22
            font.weight: Font.Bold
            color: Theme.palette.directColor1
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
                    text: qsTr("%1 words").arg(modelData )
                }
            }
            onCurrentIndexChanged: {
                root.mnemonicString = "";
                root.mnemonicInput = [];
                submitButton.enabled = false;
            }
        }
        clip: true

        GridView {
            id: grid
            width: parent.width
            property var wordIndex: ["1", "5", "9", "2", "6", "10", "3", "7", "11", "4", "8", "12",
                "13", "17", "21", "14", "18", "22", "15", "19", "23", "16", "20", "24"]
            property var wordIndex18: ["1", "5", "9", "2", "6", "10", "3", "7", "11", "4", "8", "12",
                "13", "", "14", "17", "15", "18", "16", ""]
            height: (grid.count === 20 && !grid.atXBeginning) ? 144 : 244
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: switchTabBar.bottom
            anchors.topMargin: ((grid.count === 20) && !grid.atXBeginning) ? 74 : 24
            flow: GridView.FlowTopToBottom
            cellWidth: (parent.width/4)
            cellHeight: 72
            interactive: false
            z: 100000
            cacheBuffer: 9999
            model: switchTabBar.currentItem.text.substring(0,2) === "12" ? 12 :
                   switchTabBar.currentItem.text.substring(0,2) === "18" ? 20 : 24

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
                width: (grid.cellWidth - 24)
                height: (grid.cellHeight - 28)
                textEdit.input.anchors.leftMargin: 16
                textEdit.input.anchors.rightMargin: 16
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

                visible: grid.count !== 20 || (index !== 13 && index !== 19)
                leftComponentText: (grid.count === 20) ? grid.wordIndex18[index] : grid.wordIndex[index]
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
                    if (event.key === Qt.Key_Backtab) {
                        for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
                            if (parseInt(grid.itemAtIndex(i).leftComponentText) === ((parseInt(leftComponentText)-1) >= 0 ? (parseInt(leftComponentText)-1) : 0)) {
                                grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus(Qt.TabFocusReason);
                                textEdit.input.tabNavItem = grid.itemAtIndex(i).textEdit.input.edit;
                                event.accepted = true
                                break
                            }
                        }
                    } else if (event.key === Qt.Key_Tab) {
                        for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
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

                    grid.currentIndex = index;
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
            anchors.topMargin: (grid.count === 20 && !grid.atXBeginning) ? 74 : 24
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
            property int gridCount: (grid.count === 20) ? 18 : grid.count

            function checkMnemonicLength() {
                submitButton.enabled = (root.mnemonicInput.length >= (grid.atXBeginning ? root.tabs[0] : submitButton.gridCount));
            }

            text: root.existingUser ? qsTr("Restore Status Profile") :
                  ((grid.count > 12) && grid.atXBeginning) ? qsTr("Next") : qsTr("Import")
            onClicked: {
                if ((grid.count > 12) && grid.atXBeginning && root.mnemonicInput.length < gridCount) {
                    grid.positionViewAtEnd();
                    if (grid.count === 20) {
                        grid.contentX = 1500;
                    }
                } else {
                    root.mnemonicString = "";
                    var sortTable = mnemonicInput.sort(function (a, b) {
                        return a.pos - b.pos;
                    });
                    for (var i = 0; i < mnemonicInput.length; i++) {
                        root.mnemonicString += sortTable[i].seed + ((i === (gridCount-1)) ? "" : " ");
                    }
                    if (Utils.isMnemonic(root.mnemonicString) && !OnboardingStore.validateMnemonic(root.mnemonicString)) {
                        OnboardingStore.importMnemonic(root.mnemonicString)
                        root.mnemonicString = "";
                        root.mnemonicInput = [];
                    } else {
                        invalidSeedTxt.visible = true;
                        enabled = false;
                    }
                }
            }
        }
    }

    onBackClicked: {
        root.mnemonicString = "";
        if (!grid.atXBeginning) {
            grid.positionViewAtBeginning();
        } else {
            root.mnemonicInput = [];
            root.exit();
        }
    }
}
