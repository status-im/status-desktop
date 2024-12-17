import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Onboarding2.pages 1.0


SQUtils.QObject {
    id: root

    required property StackView stackView

    required property var passwordStrengthScoreFunction
    required property var isSeedPhraseValid

    signal seedphraseSubmitted(string seedphrase)
    signal setPasswordRequested(string password)
    signal finished

    function init() {
        root.stackView.push(seedphrasePage)
    }

    Component {
        id: seedphrasePage

        SeedphrasePage {
            title: qsTr("Create profile using a recovery phrase")
            isSeedPhraseValid: root.isSeedPhraseValid

            onSeedphraseSubmitted: {
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
