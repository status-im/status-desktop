import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

SQUtils.QObject {
    id: root

    enum Type {
        NewProfile,
        KeycardRecovery,
        Login
    }

    required property StackView stackView

    required property var passwordStrengthScoreFunction
    required property var isSeedPhraseValid

    signal seedphraseSubmitted(string seedphrase)
    signal setPasswordRequested(string password)
    signal finished

    function init(type = UseRecoveryPhraseFlow.Type.NewProfile) {
        let title = ""

        if (type === UseRecoveryPhraseFlow.Type.NewProfile)
            title = qsTr("Create profile using a recovery phrase")
        else if (type === UseRecoveryPhraseFlow.Type.KeycardRecovery)
            title = qsTr("Enter recovery phrase of lost Keycard")
        else if (type === UseRecoveryPhraseFlow.Type.Login)
            title = qsTr("Log in with your Status recovery phrase")

        root.stackView.push(seedphrasePage, { title })
    }

    Component {
        id: seedphrasePage

        SeedphrasePage {
            isSeedPhraseValid: root.isSeedPhraseValid

            onSeedphraseSubmitted: (seedphrase) => {
                root.seedphraseSubmitted(seedphrase)
                root.stackView.push(createPasswordPage)
            }
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
