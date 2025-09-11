import QtQuick

import AppLayouts.Onboarding.pages

OnboardingStackView {
    id: root

    required property var passwordStrengthScoreFunction

    signal finished(string password)

    initialItem: CreatePasswordPage {
        passwordStrengthScoreFunction: root.passwordStrengthScoreFunction

        onSetPasswordRequested: (password) => root.finished(password)
    }
}
