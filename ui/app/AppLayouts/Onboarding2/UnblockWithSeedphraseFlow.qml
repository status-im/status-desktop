import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Backpressure 0.1

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

SQUtils.QObject {
    id: root

    required property StackView stackView

    required property var isSeedPhraseValid
    required property int keycardPinInfoPageDelay

    signal seedphraseSubmitted(string seedphrase)
    signal keycardPinCreated(string pin)

    function init() {
        root.stackView.push(seedphrasePage)
    }

    Component {
        id: seedphrasePage

        SeedphrasePage {
            title: qsTr("Unblock Keycard using the recovery phrase")
            btnContinueText: qsTr("Unblock Keycard")
            isSeedPhraseValid: root.isSeedPhraseValid
            onSeedphraseSubmitted: (seedphrase) => {
                root.seedphraseSubmitted(seedphrase)
                root.stackView.push(keycardCreatePinPage)
            }
        }
    }

    Component {
        id: keycardCreatePinPage

        KeycardCreatePinPage {
            onKeycardPinCreated: (pin) => {
                Backpressure.debounce(root, root.keycardPinInfoPageDelay, () => {
                    root.keycardPinCreated(pin)
                })()
            }
        }
    }
}
