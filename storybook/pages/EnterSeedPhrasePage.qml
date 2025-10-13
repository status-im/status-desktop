import QtQuick
import QtQuick.Controls

import shared
import shared.panels

import Storybook

Item {
    QtObject {
        id: mockDriver

        readonly property var seedWords:
            ["apple", "banana", "cat", "country", "catalog", "catch", "category",
            "cattle", "dog", "elephant", "fish", "cat"]

        function isSeedPhraseValid(mnemonic: string): bool {
            return mnemonic === seedWords.join(" ")
        }
    }

    EnterSeedPhrase {
        id: panel
        anchors.centerIn: parent
        isSeedPhraseValid: mockDriver.isSeedPhraseValid

        dictionary: BIP39_en {}

        onSeedPhraseUpdated: (valid, phrase) => {
            console.log(valid, phrase)
        }
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
                    const input = StorybookUtils.findChild(
                                    panel, `enterSeedPhraseInputField${i}`)

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
