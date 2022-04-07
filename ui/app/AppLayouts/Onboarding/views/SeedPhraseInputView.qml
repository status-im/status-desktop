import QtQuick 2.12
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import utils 1.0
import "../controls"
import "../stores"

OnboardingBasePage {
    id: root

    state: "existingUser"

    property bool existingUser: (root.state === "existingUser")
    property var mnemonicInput: []
    property string mnemonicString

    signal seedValidated()

    Item {
        implicitWidth: 731
        implicitHeight: 472
        anchors.centerIn: parent
        StatusSwitchTabBar {
            id: switchTabBar
            anchors.horizontalCenter: parent.horizontalCenter
            StatusSwitchTabButton {
                text: qsTr("12 words")
            }
            StatusSwitchTabButton {
                text: qsTr("18 words")
            }
            StatusSwitchTabButton {
                text: qsTr("24 words")
            }
            onCurrentIndexChanged: {
                root.mnemonicString = "";
                root.mnemonicInput = [];
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
            model: switchTabBar.currentItem.text.substring(0,2) === "12" ? 12 :
                   switchTabBar.currentItem.text.substring(0,2) === "18" ? 20 : 24
            delegate: StatusSeedPhraseInput {
                id: seedWordInput
                width: (grid.cellWidth - 24)
                height: (grid.cellHeight - 28)
                textEdit.input.anchors.leftMargin: 16
                textEdit.input.anchors.rightMargin: 16
                textEdit.text: {
                    for (var i in root.mnemonicInput) {
                        let p = root.mnemonicInput[i]
                        if (p.pos === seedWordInput.leftComponentText) {
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
                    root.mnemonicInput.push({"pos": leftComponentText, "seed": word.replace(/\s/g, '')});
                    for (var j = 0; j < mnemonicInput.length; j++) {
                        if (mnemonicInput[j].pos === leftComponentText && mnemonicInput[j].seed !== word) {
                            mnemonicInput[j].seed = word;
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
                    for (var i = !grid.atXBeginning ? 12 : 0; i < grid.count; i++) {
                        if (parseInt(grid.itemAtIndex(i).leftComponentText) === (parseInt(leftComponentText)+1)) {
                            grid.currentIndex = grid.itemAtIndex(i).itemIndex;
                            grid.itemAtIndex(i).textEdit.input.edit.forceActiveFocus();
                            if (grid.currentIndex === 12) {
                                grid.positionViewAtEnd();
                                if (grid.count === 20) {
                                    grid.contentX = 1500;
                                }
                            }
                        }
                    }
                    submitButton.enabled = (root.mnemonicInput.length === (grid.atXBeginning ? 12 : submitButton.gridCount));
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
                        var wordIndex = mnemonicInput.findIndex(x => x.pos === leftComponentText);
                        if (wordIndex > -1) {
                            mnemonicInput.splice(wordIndex , 1);
                            submitButton.enabled = (root.mnemonicInput.length === (grid.atXBeginning ? 12 : submitButton.gridCount));
                        }
                    }

                    grid.currentIndex = index;
                }
                Component.onCompleted: { grid.itemAtIndex(0).textEdit.input.edit.forceActiveFocus(); }
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
            text: root.existingUser ? qsTr("Restore Status Profile") :
                  ((grid.count > 12) && grid.atXBeginning) ? qsTr("Next") : qsTr("Import")
            onClicked: {
                if ((grid.count > 12) && grid.atXBeginning) {
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
                        root.seedValidated();
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
