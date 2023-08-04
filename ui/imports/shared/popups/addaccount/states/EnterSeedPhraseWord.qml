import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property AddAccountStore store

    implicitHeight: layout.implicitHeight
    state: root.store.currentState.stateType

    Component.onCompleted: {
        if (root.store.seedPhraseWord1WordNumber === -1) {
            let randomNo1 = Math.floor(Math.random() * 12)
            let randomNo2 = randomNo1
            while (randomNo2 == randomNo1) {
                randomNo2 = Math.floor(Math.random() * 12)
            }
            if (randomNo1 < randomNo2) {
                root.store.seedPhraseWord1WordNumber = randomNo1
                root.store.seedPhraseWord2WordNumber = randomNo2
            }
            else {
                root.store.seedPhraseWord1WordNumber = randomNo2
                root.store.seedPhraseWord2WordNumber = randomNo1
            }
        }
    }

    onStateChanged: {
        d.updateEntry()
    }

    QtObject {
        id: d

        readonly property int step: root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord1? 2 : 3
        readonly property var seedPhrase: root.store.getSeedPhrase().split(" ")

        function updateEntry() {
            if (root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord1) {
                if (!root.store.seedPhraseWord1Valid) {
                    if (word.text.trim() !== "") {
                        word.reset()
                    }
                }
                else if (root.store.seedPhraseWord1WordNumber >= -1 && root.store.seedPhraseWord1WordNumber < d.seedPhrase.length) {
                    word.text = d.seedPhrase[root.store.seedPhraseWord1WordNumber]
                }
            }
            else {
                if (!root.store.seedPhraseWord2Valid) {
                    if (word.text.trim() !== "") {
                        word.reset()
                    }
                }
                else if (root.store.seedPhraseWord2WordNumber >= -1 && root.store.seedPhraseWord2WordNumber < d.seedPhrase.length) {
                    word.text = d.seedPhrase[root.store.seedPhraseWord2WordNumber]
                }
            }

            word.validate()
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
    }

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * Style.current.padding
        spacing: Style.current.halfPadding

        StatusStepper {
            Layout.preferredWidth: Constants.addAccountPopup.stepperWidth
            Layout.preferredHeight: Constants.addAccountPopup.stepperHeight
            Layout.topMargin: Style.current.padding
            Layout.alignment: Qt.AlignCenter
            title: qsTr("Step %1 of 4").arg(d.step)
            titleFontSize: Constants.addAccountPopup.labelFontSize1
            totalSteps: 4
            completedSteps: d.step
            leftPadding: 0
            rightPadding: 0
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Constants.addAccountPopup.labelFontSize1
            color: Theme.palette.directColor1
            text: qsTr("Confirm word #%1 of your seed phrase").arg(root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord1?
                                                                       root.store.seedPhraseWord1WordNumber + 1 :
                                                                       root.store.seedPhraseWord2WordNumber + 1)
        }

        StatusInput {
            id: word
            objectName: "AddAccountPopup-EnterSeedPhraseWord"
            Layout.fillWidth: true
            Layout.topMargin: Style.current.xlPadding
            validationMode: StatusInput.ValidationMode.Always
            label: qsTr("Word #%1").arg(root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord1?
                                            root.store.seedPhraseWord1WordNumber + 1 :
                                            root.store.seedPhraseWord2WordNumber + 1)
            placeholderText: qsTr("Enter word")
            validators: [
                StatusValidator {
                    validate: function (t) {
                        if (!d.seedPhrase || d.seedPhrase.length === 0 || word.text.length === 0)
                            return false
                        if (root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord1) {
                            return (d.seedPhrase[root.store.seedPhraseWord1WordNumber] === word.text)
                        }
                        return (d.seedPhrase[root.store.seedPhraseWord2WordNumber] === word.text)
                    }
                    errorMessage: (word.text.length) > 0 ? qsTr("Incorrect word") : ""
                }
            ]
            input.tabNavItem: word.input.edit

            onTextChanged: {
                text = d.processText(text)
                if (root.store.currentState.stateType === Constants.addAccountPopup.state.enterSeedPhraseWord1) {
                    root.store.seedPhraseWord1Valid = word.valid
                    return
                }
                root.store.seedPhraseWord2Valid = word.valid
            }

            onKeyPressed: {
                root.store.submitPopup(event)
            }
        }
    }
}
