import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property KeycardStore keycardStore

    Component.onCompleted: {
        d.dirtyWordAtIndex = [false, false, false, false]
        d.validWordAtIndex = [false, false, false, false]
        d.anyInputDirty = false
        d.allEntriesValid = false

        let seedPhrase = keycardStore.getSeedPhrase()
        if(seedPhrase.length === 0)
            return

        d.seedPhrases = seedPhrase.split(" ")

        let numbers = []
        while (numbers.length < 4) {
            let randomNo = Math.floor(Math.random() * 12)
            if(numbers.indexOf(randomNo) == -1)
                numbers.push(randomNo)
        }
        numbers.sort((a, b) => { return a < b? -1 : a > b? 1 : 0 })
        d.wordNumbers = numbers
    }

    QtObject {
        id: d

        property var seedPhrases: []
        property var wordNumbers: []
        property var dirtyWordAtIndex: [false, false, false, false]
        property var validWordAtIndex: [false, false, false, false]
        property bool anyInputDirty: false
        property bool allEntriesValid: false
        readonly property int numOfColumns: 4
        readonly property int rowSpacing: Style.current.bigPadding
        readonly property int columnSpacing: Style.current.bigPadding

        function updateValidity(index, valid, dirty) {
            dirtyWordAtIndex[index] = dirty
            validWordAtIndex[index] = valid
            let anyDirty = false
            let allValid = true
            for(let i = 0; i < validWordAtIndex.length; ++i) {
                allValid = allValid && validWordAtIndex[i]
                anyDirty = anyDirty || (dirtyWordAtIndex[index] && !validWordAtIndex[index])
            }
            allEntriesValid = allValid
            anyInputDirty = anyDirty
        }
    }

    Item {
        anchors.top: parent.top
        anchors.bottom: footerWrapper.top
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Style.current.padding

            StatusBaseText {
                id: title
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.titleFontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
                text: qsTr("Enter seed phrase words")
            }

            GridLayout {
                id: grid
                Layout.alignment: Qt.AlignHCenter
                columns: d.numOfColumns
                rowSpacing: d.rowSpacing
                columnSpacing: d.columnSpacing

                Component.onCompleted: {
                    for (var i = 0; i < children.length - 1; ++i) {
                        if(children[i].inputField && children[i+1].inputField){
                            children[i].inputField.input.tabNavItem = children[i+1].inputField.input.edit
                        }
                    }
                }

                Repeater {
                    model: d.wordNumbers
                    delegate: Item {
                        Layout.preferredWidth: Constants.keycard.general.seedPhraseCellWidth
                        Layout.preferredHeight: Constants.keycard.general.seedPhraseCellHeight

                        property alias inputField: word
                        property alias wN: wordNumber

                        StatusBaseText {
                            id: wordNumber
                            width: Constants.keycard.general.seedPhraseCellNumberWidth
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Qt.AlignRight
                            font.pixelSize: Constants.keycard.general.seedPhraseCellFontSize
                            color: Theme.palette.directColor1
                            text: "%1.".arg(model.modelData + 1)
                        }

                        StatusInput {
                            id: word
                            anchors.left: wordNumber.right
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Style.current.xlPadding
                            input.edit.font.pixelSize: Constants.keycard.general.seedPhraseCellFontSize
                            input.acceptReturn: true

                            onTextChanged: {
                                if(text.length == 0)
                                    return
                                if(/(^\s|^\r|^\n)|(\s$|^\r$|^\n$)/.test(text)) {
                                    text = text.trim()
                                    return
                                }
                                else if(/\s|\r|\n/.test(text)) {
                                    text = ""
                                    return
                                }
                                valid = d.seedPhrases[model.modelData] === text
                                d.updateValidity(index, valid, text !== "")
                            }

                            onKeyPressed: {
                                if (d.allEntriesValid &&
                                        (input.edit.keyEvent === Qt.Key_Return ||
                                         input.edit.keyEvent === Qt.Key_Enter)) {
                                    event.accepted = true
                                    keycardStore.nextState()
                                }
                            }
                        }
                    }
                }
            }

            StatusBaseText {
                id: info
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.infoFontSize
                color: Theme.palette.dangerColor1
                horizontalAlignment: Qt.AlignHCenter
                text: d.anyInputDirty && !d.allEntriesValid? qsTr("Invalid word") : ""
            }
        }
    }

    Item {
        id: footerWrapper
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Constants.keycard.general.footerWrapperHeight

        StatusButton {
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: d.allEntriesValid
            text: qsTr("Next")
            onClicked: {
                keycardStore.nextState()
            }
        }
    }
}
