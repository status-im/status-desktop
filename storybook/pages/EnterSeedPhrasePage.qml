import QtQuick 2.15
import QtQuick.Controls 2.15

import shared.panels 1.0

import Storybook 1.0

Item {
    QtObject {
        id: mockDriver

        readonly property var seedWords: ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"]

        function isSeedPhraseValid(mnemonic: string) {
            return mnemonic === seedWords.join(" ")
        }
    }

    EnterSeedPhrase {
        id: panel
        anchors.centerIn: parent
        isSeedPhraseValid: mockDriver.isSeedPhraseValid
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 8

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: "Valid: %1".arg(panel.seedPhraseIsValid ? "yes" : "no")
        }
        Button {
            text: "Paste seed phrase"
            focusPolicy: Qt.NoFocus
            onClicked: {
                for (let i = 1;; i++) {
                    const input = StorybookUtils.findChild(panel, `enterSeedPhraseInputField${i}`)

                    if (input === null)
                        break

                    input.text = mockDriver.seedWords[i-1]
                }
            }
        }
    }
}

// category: Panels
// status: good
