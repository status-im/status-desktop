import QtQuick 2.14

import utils 1.0
import shared.panels 1.0 as SharedPanels

Item {
    id: root

    property var sharedKeycardModule

    signal validation(bool result)

    QtObject {
        id: d

        property bool wrongSeedPhrase: root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.wrongSeedPhrase
        onWrongSeedPhraseChanged: {
            seedPhrase.setWrongSeedPhraseMessage(wrongSeedPhrase? qsTr("The phrase you’ve entered does not match this Keycard’s seed phrase") : "")
        }

    }

    SharedPanels.EnterSeedPhrase {
        id: seedPhrase
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding

        isSeedPhraseValid: function(mnemonic) {
            return root.sharedKeycardModule.validSeedPhrase(mnemonic)
        }

        onSeedPhraseUpdated: {
            if (valid) {
                root.sharedKeycardModule.setSeedPhrase(seedPhrase)
            }
            root.validation(valid)
        }

        onSubmitSeedPhrase: {
            root.sharedKeycardModule.currentState.doPrimaryAction()
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.enterSeedPhrase
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase
        },
        State {
            name: Constants.keycardSharedState.wrongSeedPhrase
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongSeedPhrase
        }
    ]
}
