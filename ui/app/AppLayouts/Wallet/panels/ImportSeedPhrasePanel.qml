import QtQuick 2.12

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.stores 1.0

import "../stores"

GridView {
    id: grid

    property bool isValid: false
    property string mnemonicString: ""
    property int preferredHeight: (cellHeight * model/2) + footerItem.height
    signal enterPressed()

    function reset() {
        _internal.errorString  = ""
        mnemonicString = ""
        _internal.mnemonicInput = [];
        if (!grid.atXBeginning) {
            grid.positionViewAtBeginning();
        }
        for(var i = 0; i < grid.model; i++) {
            if(grid.itemAtIndex(i)) {
                grid.itemAtIndex(i).textEdit.text =  ""
                grid.itemAtIndex(i).textEdit.reset()
            }
        }
    }

    function validate() {
        _internal.errorString  = ""
        if (!Utils.isMnemonic(mnemonicString)) {
            _internal.errorString = qsTr("Invalid seed phrase")
        } else {
            _internal.errorString = RootStore.vaildateMnemonic(mnemonicString)
            const regex = new RegExp('word [a-z]+ not found in the dictionary', 'i');
            if (regex.test(_internal.errorString)) {
                _internal.errorString = qsTr("Invalid seed phrase") + '. ' +
                        qsTr("This seed phrase doesn't match our supported dictionary. Check for misspelled words.")
            }
        }
        return _internal.errorString === ""
    }

    QtObject {
        id: _internal
        property int seedPhraseInputWidth: (parent.width/2)
        property int seedPhraseInputHeight: 48
        property var mnemonicInput: []
        property string errorString:  ""
        readonly property var seedPhraseWordsOptions: ([12, 18, 24])

        function getSeedPhraseString() {
            var seedPhrase = ""
            for(var i = 0; i < grid.model; i++) {
                if(!!grid.itemAtIndex(i)) {
                    seedPhrase += grid.itemAtIndex(i).text + " "
                }
            }
            return seedPhrase
        }
    }

    cellWidth: _internal.seedPhraseInputWidth
    cellHeight: _internal.seedPhraseInputHeight
    interactive: false
    z: 100000

    onModelChanged: {
        mnemonicString = "";
        let menmonicInputTemp = _internal.mnemonicInput.filter(function(value) {
                        return value.pos <= grid.count
                    })
        _internal.mnemonicInput = []
        for (let i = 0; i < menmonicInputTemp.length; i++) {
            // .pos starts with 1
            grid.itemAtIndex(menmonicInputTemp[i].pos - 1).setWord(menmonicInputTemp[i].seed)
            grid.addWord(menmonicInputTemp[i].pos,
                         menmonicInputTemp[i].seed,
                         true)
        }
    }


    onIsValidChanged:  {
        if(isValid) {
            mnemonicString = _internal.getSeedPhraseString()
        }
    }

    onVisibleChanged:  {
        if(visible) {
            grid.itemAtIndex(0).textEdit.input.edit.forceActiveFocus()
        }
    }

    function pasteWords () {
        const clipboardText = globalUtils.getFromClipboard()
        // Split words separated by commas and or blank spaces (spaces, enters, tabs)
        let words = clipboardText.split(/[, \s]+/)

        let timeout = 0
        let indexOfWordsOption = _internal.seedPhraseWordsOptions.indexOf(words.length)
        if(indexOfWordsOption == -1) {
            return false
        }
        footerItem.switchToIndex(indexOfWordsOption)
        timeout = 100

        timer.setTimeout(function(){
            _internal.mnemonicInput = []
            for (let i = 0; i < words.length; i++) {
                try {
                    grid.itemAtIndex(i).setWord(words[i])
                } catch (e) {
                    // Getting items outside of the current view might not work
                }
                grid.addWord(i, words[i], true)
            }
        }, timeout);
        
        return true
    }

    function addWord(pos, word, ignoreGoingNext) {
        _internal.mnemonicInput.push({"pos": pos, "seed": word.replace(/\s/g, '')});
            for (var j = 0; j < _internal.mnemonicInput.length; j++) {
                if (_internal.mnemonicInput[j].pos === pos && _internal.mnemonicInput[j].seed !== word) {
                    _internal.mnemonicInput[j].seed = word;
                }
            }
            //remove duplicates
            var valueArr = _internal.mnemonicInput.map(function(item){ return item.pos });
            var isDuplicate = valueArr.some(function(item, idx){
                if (valueArr.indexOf(item) !== idx) {
                    _internal.mnemonicInput.splice(idx, 1);
                }
                return valueArr.indexOf(item) !== idx
            });
            if (!ignoreGoingNext) {
                for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
                    if (parseInt(grid.itemAtIndex(i).leftComponentText) === (parseInt(pos)+1)) {
                        grid.currentIndex = grid.itemAtIndex(i).itemIndex;
                        grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus();
                        if (grid.currentIndex === 11) {
                            grid.positionViewAtEnd();
                            if (grid.count === 20) {
                                grid.contentX = 1500;
                            }
                        }
                    }
                }
            }
            grid.isValid = (_internal.mnemonicInput.length === grid.model);
    }

    delegate: StatusSeedPhraseInput {
        id: statusSeedInput
        width: grid.cellWidth - (Style.current.halfPadding/2)
        height: (grid.cellHeight - Style.current.halfPadding)
        textEdit.errorMessageCmp.visible: false
        leftComponentText: index + 1
        inputList: BIP39_en { }
        property int itemIndex: index
        z: (grid.currentIndex === index) ? 150000000 : 0
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
                if (grid.pasteWords()) {
                    // Paste was done by splitting the words
                    event.accepted = true
                }
                return
            }

            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true
                grid.enterPressed()
                return
            }

            if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
                var wordIndex = _internal.mnemonicInput.findIndex(x => x.pos === leftComponentText);
                if (wordIndex > -1) {
                    _internal.mnemonicInput.splice(wordIndex , 1);
                    grid.isValid = _internal.mnemonicInput.length ===  grid.model
                }
            }

            grid.currentIndex = index;
        }
    }
    footer: Item {
        id: footerC
        function switchToIndex(index) {
            changeSeedNbWordsTabBar.currentIndex = index
        }
        width: grid.width - (Style.current.halfPadding/2)
        height: changeSeedNbWordsTabBar.height + errorMessage.height + Style.current.padding*2
        StatusBaseText {
            id: errorMessage

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding

            height: visible ? implicitHeight : 0
            visible: !!text
            text: _internal.errorString

            font.pixelSize: 12
            color: Theme.palette.dangerColor1
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        StatusSwitchTabBar {
            id: changeSeedNbWordsTabBar
            width: parent.width
            anchors.top: errorMessage.bottom
            anchors.topMargin: Style.current.padding
            Repeater {
                model: _internal.seedPhraseWordsOptions
                 StatusSwitchTabButton {
                    text: qsTr("%1 words").arg(modelData)
                }
            }
            onCurrentIndexChanged: {
                grid.model = _internal.seedPhraseWordsOptions[changeSeedNbWordsTabBar.currentIndex]
            }
        }
    }
}


