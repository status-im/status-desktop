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
            //% "Invalid seed phrase"
            _internal.errorString = qsTrId("custom-seed-phrase")
        } else {
            _internal.errorString = RootStore.vaildateMnemonic(mnemonicString)
            const regex = new RegExp('word [a-z]+ not found in the dictionary', 'i');
            if (regex.test(_internal.errorString)) {
                //% "Invalid seed phrase"
                _internal.errorString = qsTrId("custom-seed-phrase") + '. ' +
                        //% "This seed phrase doesn't match our supported dictionary. Check for misspelled words."
                        qsTrId("custom-seed-phrase-text-1")
            }
        }
        return _internal.errorString === ""
    }

    QtObject {
        id: _internal
        property int seedPhraseInputHeight: 44
        property int seedPhraseInputWidth: 220
        property var mnemonicInput: []
        property string errorString:  ""
        readonly property int twelveWordsModel: 12
        readonly property int twentyFourWordsModel: 24

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

    cellHeight: _internal.seedPhraseInputHeight + Style.current.halfPadding
    cellWidth: _internal.seedPhraseInputWidth + Style.current.halfPadding
    interactive: false
    z: 100000

    model: _internal.twelveWordsModel

    onModelChanged: {
        mnemonicString = "";
        _internal.mnemonicInput = [];
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
        if ((grid.model === _internal.twelveWordsModel && words.length === _internal.twentyFourWordsModel) ||
            (grid.model === _internal.twentyFourWordsModel && words.length === _internal.twelveWordsModel)) {
            footerItem.pressButton()
            // Set the teimeout to 100 so the grid has time to generate the new items
            timeout = 100
        } else if (words.length !== _internal.twentyFourWordsModel && words.length !== _internal.twelveWordsModel) {
            return false
        }

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
        width: _internal.seedPhraseInputWidth
        height: _internal.seedPhraseInputHeight
        textEdit.errorMessageCmp.visible: false
        textEdit.input.anchors.topMargin: 11
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

        function pressButton() {
            changeSeedNbWordsBtn.clicked(null)
        }

        width: grid.width - Style.current.padding
        height: changeSeedNbWordsBtn.height + errorMessage.height + Style.current.padding*2
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
        StatusButton {
            id: changeSeedNbWordsBtn
            anchors.top: errorMessage.bottom
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            text: grid.model === _internal.twelveWordsModel ? qsTr("Use 24 word seed phrase"):
                                                              qsTr("Use 12 word seed phrase")
            onClicked: {
                if(grid.model === _internal.twelveWordsModel) {
                    grid.model = _internal.twentyFourWordsModel
                }
                else {
                    grid.model = _internal.twelveWordsModel
                }
            }
        }
    }
}


