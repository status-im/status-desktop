import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import StatusQ
import StatusQ.Core
import StatusQ.Core.Utils
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme

import Models
import Storybook

import SortFilterProxyModel
import QtModelsToolkit

import shared
import shared.panels
import utils

Item {
    id: root

    MouseArea {
        anchors.fill: parent

        onClicked: root.focus = true
    }

    function isValid(mnemonic) {
        return mnemonic === sampleValidPhrase
    }

    readonly property string sampleValidPhrase:
        "abandon baby cat dad eager fabric gadget habit ice jacket kangaroo lab"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 150
        border.width: 1
        color: "transparent"

        StatusScrollView {
            id: scrollView

            anchors.fill: parent
            contentWidth: availableWidth

            EnterSeedPhraseNew {
                id: enterSeedPhrase

                property var validSeedPhrase: []

                flickable: scrollView.flickable

                width: scrollView.availableWidth
                dictionary: BIP39_en {}

                onSeedPhraseProvided: (seedPhrase, errorMessageCb) => {
                    if (seedPhrase.join(" ") === sampleValidPhrase)
                        errorMessageCb("")
                    else
                        errorMessageCb("Invalid seed phrase!")
                }

                onSubmitSeedPhrase: validSeedPhrase = seedPhrase
            }
        }
    }

    ColumnLayout {
        anchors.bottom: parent.bottom

        Button {
            text: "Copy valid seed phrase to keyboard: " + root.sampleValidPhrase

            onClicked: ClipboardUtils.setText(root.sampleValidPhrase)
        }

        Label {
            text: "is seedphrase valid: " + enterSeedPhrase.seedPhraseIsValid
        }

        Label {
            text: "valid seed phrase provided: " + enterSeedPhrase.validSeedPhrase.toString()
        }

        Label {
            text: JSON.stringify(enterSeedPhrase.seedPhrase)

            Layout.bottomMargin: 20
        }
    }
}

// category: Panels
// status: good
