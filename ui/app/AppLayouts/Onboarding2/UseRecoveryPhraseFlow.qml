import QtQuick

import AppLayouts.Onboarding2.pages
import AppLayouts.Onboarding.enums

OnboardingStackView {
    id: root

    enum Type {
        NewProfile,
        KeycardRecovery,
        Login
    }

    required property int type

    // functions
    required property var passwordStrengthScoreFunction // (string) => int
    required property var isSeedPhraseValid // (string) => bool
    required property var isSeedPhraseDuplicate // (string) => bool

    signal seedphraseSubmitted(string seedphrase)
    signal setPasswordRequested(string password)
    signal importLocalBackupRequested(url importFilePath)
    signal finished

    initialItem: type === UseRecoveryPhraseFlow.Type.KeycardRecovery ? conversionAckPage : seedPhrasePage

    Component {
        id: conversionAckPage
        ConvertKeycardAccountAcksPage {
            onContinueRequested: root.push(seedPhrasePage)
        }
    }

    Component {
        id: seedPhrasePage
        SeedphrasePage {
            isSeedPhraseValid: root.isSeedPhraseValid

            title: {
                switch (root.type) {
                case UseRecoveryPhraseFlow.Type.NewProfile:
                    return qsTr("Create profile using a recovery phrase")
                case UseRecoveryPhraseFlow.Type.KeycardRecovery:
                    return qsTr("Enter recovery phrase of lost Keycard")
                case UseRecoveryPhraseFlow.Type.Login:
                    return qsTr("Log in with your Status recovery phrase")
                }

                return ""
            }

            onSeedphraseUpdated: function(valid, seedphrase) {
                if (root.type === UseRecoveryPhraseFlow.Type.KeycardRecovery) {
                    if (!valid)
                        setWrongSeedPhraseMessage(qsTr("Recovery phrase doesn’t match the profile of an existing Keycard user on this device"))
                    else
                        setWrongSeedPhraseMessage("")
                } else {  // different error messages when trying to import a duplicate seedphrase
                    if (valid && root.isSeedPhraseDuplicate(seedphrase)) {
                        setWrongSeedPhraseMessage(qsTr("The entered recovery phrase is already added"))
                    } else if (valid) {
                        setWrongSeedPhraseMessage("")
                    }
                }
            }

            onSeedphraseSubmitted: function(seedphrase) {
                root.seedphraseSubmitted(seedphrase)
                root.push(createPasswordPage)
            }
        }
    }

    Component {
        id: createPasswordPage

        CreatePasswordPage {
            passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

            onSetPasswordRequested: function(password) {
                root.setPasswordRequested(password)
                if (root.type === UseRecoveryPhraseFlow.Type.Login)
                    root.push(importLocalBackupPage)
                else
                    root.finished()
            }
        }
    }

    Component {
        id: importLocalBackupPage
        ImportLocalBackupPage {
            onImportLocalBackupRequested: function(importFilePath) {
                root.importLocalBackupRequested(importFilePath)
                root.finished()
            }
            onSkipRequested: root.finished()
        }
    }
}
