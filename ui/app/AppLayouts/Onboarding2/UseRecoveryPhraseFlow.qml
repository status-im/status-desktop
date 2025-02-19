import QtQuick 2.15

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

OnboardingStackView {
    id: root

    enum Type {
        NewProfile,
        KeycardRecovery,
        Login
    }

    // https://bugreports.qt.io/browse/QTBUG-84269, required can be restored on Qt6
    /*required*/ property int type

    // functions
    required property var passwordStrengthScoreFunction // (string) => int
    required property var isSeedPhraseValid // (string) => bool
    required property var isSeedPhraseDuplicate // (string) => bool

    signal seedphraseSubmitted(string seedphrase)
    signal setPasswordRequested(string password)
    signal finished

    initialItem: SeedphrasePage {
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

        onSeedphraseUpdated: (valid, seedphrase) => {
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

        onSeedphraseSubmitted: (seedphrase) => {
            root.seedphraseSubmitted(seedphrase)
            root.push(createPasswordPage)
        }
    }

    Component {
        id: createPasswordPage

        CreatePasswordPage {
            passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

            onSetPasswordRequested: {
                root.setPasswordRequested(password)
                root.finished()
            }
        }
    }
}
