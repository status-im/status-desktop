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

    required property var passwordStrengthScoreFunction
    required property var isSeedPhraseValid

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
