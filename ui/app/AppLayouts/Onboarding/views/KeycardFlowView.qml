import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import "../controls"
import "../stores"

OnboardingBasePage {
    id: root

    property KeycardStore keycardStore

    Component.onCompleted: {
        if(root.keycardStore.keycardModule.keycardMode === Constants.keycard.mode.generateNewKeysMode ||
           root.keycardStore.keycardModule.keycardMode === Constants.keycard.mode.importSeedPhraseMode) {
            root.keycardStore.runLoadAccountFlow()
        }
        else if(root.keycardStore.keycardModule.keycardMode === Constants.keycard.mode.oldUserLoginMode) {
            root.keycardStore.runRecoverAccountFlow()
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: {
            if (root.keycardStore.keycardModule.flowState === Constants.keycard.state.pluginKeycardState ||
                    root.keycardStore.keycardModule.flowState === Constants.keycard.state.insertKeycardState ||
                    root.keycardStore.keycardModule.flowState === Constants.keycard.state.readingKeycardState)
            {
                return keycardInitViewComponent
            }
            else if (root.keycardStore.keycardModule.flowState === Constants.keycard.state.createKeycardPinState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.repeatKeycardPinState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.keycardPinSetState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.enterKeycardPinState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.wrongKeycardPinState)
            {
                return keycardPinViewComponent
            }
            else if (root.keycardStore.keycardModule.flowState === Constants.keycard.state.displaySeedPhraseState)
            {
                return seedphraseViewComponent
            }
            else if (root.keycardStore.keycardModule.flowState === Constants.keycard.state.enterSeedPhraseState)
            {
                return seedphraseInputViewComponent
            }
            else if (root.keycardStore.keycardModule.flowState === Constants.keycard.state.enterSeedPhraseWordsState)
            {
                return seedphraseWordsInputViewComponent
            }
            else if (root.keycardStore.keycardModule.flowState === Constants.keycard.state.keycardNotEmptyState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.keycardIsEmptyState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLockedFactoryResetState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.maxPairingSlotsReachedState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.maxPinRetriesReachedState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLockedRecoverState ||
                     root.keycardStore.keycardModule.flowState === Constants.keycard.state.recoverKeycardState)
            {
                return keycardStateViewComponent
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

    property var keycardStateViewComponent: Component {
        KeycardStateView {
            keycardStore: root.keycardStore
        }
    }

    property var seedphraseInputViewComponent: Component {
        SeedPhraseInputViewContent {
            state: "importIntoKeycard"
            keycardUsage: true
            keycardStore: root.keycardStore
        }
    }
}
