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
            _internal.mnemonicInput.push({"pos": leftComponentText, "seed": word.replace(/\s/g, '')});
            for (var j = 0; j < _internal.mnemonicInput.length; j++) {
                if (_internal.mnemonicInput[j].pos === leftComponentText && _internal.mnemonicInput[j].seed !== word) {
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
            for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
                if (parseInt(grid.itemAtIndex(i).leftComponentText) === (parseInt(leftComponentText)+1)) {
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
            grid.isValid = (_internal.mnemonicInput.length === grid.model);
        }
        onEditClicked: {
            grid.currentIndex = index;
            grid.itemAtIndex(index).textEdit.input.edit.forceActiveFocus();
        }
        onKeyPressed: {
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right) {
                for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
                    if (parseInt(grid.itemAtIndex(i).leftComponentText) === ((parseInt(leftComponentText)+1) <= grid.count ? (parseInt(leftComponentText)+1) : grid.count)) {
                        grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus();
                        textEdit.input.tabNavItem = grid.itemAtIndex(i).textEdit.input.edit;
                    }
                }
            } else if (event.key === Qt.Key_Left) {
                for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
                    if (parseInt(grid.itemAtIndex(i).leftComponentText) === ((parseInt(leftComponentText)-1) >= 0 ? (parseInt(leftComponentText)-1) : 0)) {
                        grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus();
                    }
                }
            } else if (event.key === Qt.Key_Down) {
                grid.itemAtIndex((index+1 < grid.count) ? (index+1) : (grid.count-1)).textEdit.input.edit.forceActiveFocus();
            } else if (event.key === Qt.Key_Up) {
                grid.itemAtIndex((index-1 >= 0) ? (index-1) : 0).textEdit.input.edit.forceActiveFocus();
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
        width: grid.width - Style.current.padding
        height: button.height + errorMessage.height + Style.current.padding*2
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
            id: button
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


