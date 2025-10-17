import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import shared
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
            seedPhrase.setError(wrongSeedPhrase? qsTr("The phrase you’ve entered does not match this Keycard’s recovery phrase") : "")
        }

    }

    StatusScrollView {
        id: scrollView

        anchors.fill: parent
        contentWidth: availableWidth

        anchors.topMargin: Theme.padding
        anchors.leftMargin: Theme.xlPadding
        anchors.rightMargin: Theme.xlPadding

        ColumnLayout {

            spacing: Theme.xlPadding
            width: scrollView.availableWidth

            StatusBaseText {
                id: title

                Layout.fillWidth: true

                visible: text !== ""
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            SharedPanels.EnterSeedPhraseNew {
                id: seedPhrase

                Layout.fillWidth: true

                dictionary: BIP39_en {}
                flickable: scrollView.flickable

                onSeedPhraseProvided: (seedPhrase, errorMessageCb) => {
                    const phrase = seedPhrase.join(" ")
                    const valid = root.sharedKeycardModule.validSeedPhrase(phrase)

                    if (valid) {
                        errorMessageCb("")
                        root.sharedKeycardModule.setSeedPhrase(phrase)
                    } else {
                        errorMessageCb(qsTr("Invalid recovery phrase"))
                    }

                    root.validation(valid)
                }

                onSubmitSeedPhrase: {
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }
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
