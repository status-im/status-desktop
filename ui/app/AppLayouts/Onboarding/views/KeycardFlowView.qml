import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import "../controls"
import "../stores"

OnboardingBasePage {
    id: root

    property KeycardStore keycardStore

    Component.onCompleted: {
        keycardStore.startOnboardingKeycardFlow()
    }

    Loader {
        anchors.fill: parent
        sourceComponent: {
            if (keycardStore.keycardModule.flowState === Constants.keycard.state.pluginKeycardState ||
                    keycardStore.keycardModule.flowState === Constants.keycard.state.insertKeycardState ||
                    keycardStore.keycardModule.flowState === Constants.keycard.state.readingKeycardState)
            {
                return keycardInitViewComponent
            }
            else if (keycardStore.keycardModule.flowState === Constants.keycard.state.createKeycardPinState ||
                     keycardStore.keycardModule.flowState === Constants.keycard.state.repeatKeycardPinState ||
                     keycardStore.keycardModule.flowState === Constants.keycard.state.keycardPinSetState)
            {
                return keycardPinViewComponent
            }
            else if (keycardStore.keycardModule.flowState === Constants.keycard.state.displaySeedPhraseState)
            {
                return seedphraseViewComponent
            }
            else if (keycardStore.keycardModule.flowState === Constants.keycard.state.enterSeedPhraseWordsState)
            {
                return seedphraseWordsInputViewComponent
            }
            else if (keycardStore.keycardModule.flowState === Constants.keycard.state.keycardNotEmpty ||
                     keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLocked)
            {
                return keycardNotEmptyViewComponent
            }

            return undefined
        }
    }

    property var keycardInitViewComponent: Component {
        KeycardInitView {
            keycardStore: root.keycardStore
        }
    }

    property var keycardPinViewComponent: Component {
        KeycardPinView {
            keycardStore: root.keycardStore
        }
    }

    property var seedphraseViewComponent: Component {
        SeedPhraseView {
            keycardStore: root.keycardStore
        }
    }

    property var seedphraseWordsInputViewComponent: Component {
        SeedPhraseWordsInputView {
            keycardStore: root.keycardStore
        }
    }

    property var keycardNotEmptyViewComponent: Component {
        KeycardNotEmpty {
            keycardStore: root.keycardStore
        }
    }
}
