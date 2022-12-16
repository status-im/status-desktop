import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

Item {
    id: root

    property var sharedKeycardModule

    signal validation(bool result)

    QtObject {
        id: d

        property bool allEntriesValid: false
        readonly property var seedPhrase: root.sharedKeycardModule.getMnemonic().split(" ")
        readonly property var wordNumbers: {
            let numbers = []
            while (numbers.length < 3) {
                let randomNo = Math.floor(Math.random() * 12)
                if(numbers.indexOf(randomNo) == -1)
                    numbers.push(randomNo)
            }
            numbers.sort((a, b) => { return a < b? -1 : a > b? 1 : 0 })
            return numbers
        }

        function processText(text) {
            if(text.length === 0)
                return ""
            if(/(^\s|^\r|^\n)|(\s$|^\r$|^\n$)/.test(text)) {
                return text.trim()
            }
            else if(/\s|\r|\n/.test(text)) {
                return ""
            }
            return text
        }

        function updateValidity() {
            d.allEntriesValid = word0.valid && word1.valid && word2.valid
            root.validation(d.allEntriesValid)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.padding
        clip: true

        StatusBaseText {
            id: title
            Layout.preferredHeight: Constants.keycard.general.titleHeight
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Confirm seed phrase words")
            font.pixelSize: Constants.keycard.general.fontSize1
            font.weight: Font.Bold
            color: Theme.palette.directColor1
        }

        StatusInput {
            id: word0
            Layout.fillWidth: true
            validationMode: StatusInput.ValidationMode.Always
            label: qsTr("Word #%1").arg(d.wordNumbers[0] + 1)
            placeholderText: qsTr("Enter word")
            validators: [
                StatusValidator {
                    validate: function (t) {
                        if (!d.seedPhrase || d.seedPhrase.length === 0 || word0.text.length === 0)
                            return false
                        return (d.seedPhrase[d.wordNumbers[0]] === word0.text)
                    }
                    errorMessage: (word0.text.length) > 0 ? qsTr("This word doesn’t match") : ""
                }
            ]

            input.acceptReturn: true
            input.tabNavItem: word1.input.edit

            onTextChanged: {
                text = d.processText(text)
                d.updateValidity()
            }

            onKeyPressed: {
                if (d.allEntriesValid &&
                        (input.edit.keyEvent === Qt.Key_Return ||
                         input.edit.keyEvent === Qt.Key_Enter)) {
                    event.accepted = true
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }
        }

        StatusInput {
            id: word1
            Layout.fillWidth: true
            validationMode: StatusInput.ValidationMode.Always
            label: qsTr("Word #%1").arg(d.wordNumbers[1] + 1)
            placeholderText: qsTr("Enter word")
            validators: [
                StatusValidator {
                    validate: function (t) {
                        if (!d.seedPhrase || d.seedPhrase.length === 0 || word1.text.length === 0)
                            return false
                        return (d.seedPhrase[d.wordNumbers[1]] === word1.text)
                    }
                    errorMessage: (word1.text.length) > 0 ? qsTr("This word doesn’t match") : ""
                }
            ]

            input.acceptReturn: true
            input.tabNavItem: word2.input.edit

            onTextChanged: {
                text = d.processText(text)
                d.updateValidity()
            }

            onKeyPressed: {
                if (d.allEntriesValid &&
                        (input.edit.keyEvent === Qt.Key_Return ||
                         input.edit.keyEvent === Qt.Key_Enter)) {
                    event.accepted = true
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }
        }

        StatusInput {
            id: word2
            Layout.fillWidth: true
            validationMode: StatusInput.ValidationMode.Always
            label: qsTr("Word #%1").arg(d.wordNumbers[2] + 1)
            placeholderText: qsTr("Enter word")
            validators: [
                StatusValidator {
                    validate: function (t) {
                        if (!d.seedPhrase || d.seedPhrase.length === 0 || word2.text.length === 0)
                            return false
                        return (d.seedPhrase[d.wordNumbers[2]] === word2.text)
                    }
                    errorMessage: (word2.text.length) > 0 ? qsTr("This word doesn’t match") : ""
                }
            ]

            input.acceptReturn: true

            onTextChanged: {
                text = d.processText(text)
                d.updateValidity()
            }

            onKeyPressed: {
                if (d.allEntriesValid &&
                        (input.edit.keyEvent === Qt.Key_Return ||
                         input.edit.keyEvent === Qt.Key_Enter)) {
                    event.accepted = true
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
