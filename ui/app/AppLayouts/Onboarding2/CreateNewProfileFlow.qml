import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Onboarding2.pages 1.0


SQUtils.QObject {
    id: root

    required property StackView stackView
    required property var passwordStrengthScoreFunction

    signal finished(string password)

    function init() {
        root.stackView.push(createPasswordPage)
    }

    Component {
        id: createPasswordPage

        CreatePasswordPage {
            passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

            onSetPasswordRequested: root.finished(password)
        }
    }
}
