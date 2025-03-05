import QtQuick 2.15

import AppLayouts.Onboarding2.pages 1.0

OnboardingStackView {
    id: root

    required property var passwordStrengthScoreFunction

    signal finished(string password)

    initialItem: CreatePasswordPage {
        passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

        onSetPasswordRequested: root.finished(password)
    }
}
