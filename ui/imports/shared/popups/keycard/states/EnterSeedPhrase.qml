import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme

import utils
import shared.panels as SharedPanels

Item {
    id: root

    property var sharedKeycardModule

    signal validation(bool result)

    QtObject {
        id: d

        property bool wrongSeedPhrase: root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.wrongSeedPhrase
        onWrongSeedPhraseChanged: {
            seedPhrase.setWrongSeedPhraseMessage(wrongSeedPhrase? qsTr("The phrase you’ve entered does not match this Keycard’s recovery phrase") : "")
        }

    }

    StatusBaseText {
        id: title
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Theme.padding
        anchors.leftMargin: Theme.xlPadding
        anchors.rightMargin: Theme.xlPadding
        visible: text != ""
        font.pixelSize: Constants.keycard.general.fontSize1
        font.weight: Font.Bold
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }

    SharedPanels.EnterSeedPhrase {
        id: seedPhrase
        anchors.top: title.visible? title.bottom : parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Theme.xlPadding
        anchors.bottomMargin: Theme.halfPadding
        anchors.leftMargin: Theme.xlPadding
        anchors.rightMargin: Theme.xlPadding

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
            PropertyChanges {
                target: title
                text: {
                    switch (root.sharedKeycardModule.currentState.flowType) {
                    case Constants.keycardSharedFlow.migrateFromKeycardToApp:
                        return qsTr("Enter recovery phrase for %1 key pair").arg(root.sharedKeycardModule.keyPairForProcessing.name)
                    }

                    return ""
                }
            }
        },
        State {
            name: Constants.keycardSharedState.wrongSeedPhrase
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongSeedPhrase
            PropertyChanges {
                target: title
                text: {
                    switch (root.sharedKeycardModule.currentState.flowType) {
                    case Constants.keycardSharedFlow.migrateFromKeycardToApp:
                        return qsTr("Enter recovery phrase for %1 key pair").arg(root.sharedKeycardModule.keyPairForProcessing.name)
                    }

                    return ""
                }
            }
        }
    ]
}
