import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import shared.views

import Storybook

import utils

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    Item {
        id: wrapper
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PasswordView {
            id: passwordView

            readonly property string existingPassword: "Somepassword1."

            anchors.centerIn: wrapper

            width: slider.value
            createNewPsw: createNewPassword.checked
            titleVisible: titleVisibleSwitch.checked
            highSizeIntro: highSizeIntroSwitch.checked
            passwordStrengthScoreFunction: (newPass) => Math.min(newPass.length-1, 4)

            onReturnPressed: logs.logEvent("Return pressed", ["Current Password", "New Password", "Confirmation Password"], [passwordView.currentPswText, passwordView.newPswText, passwordView.confirmationPswText])
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        RowLayout {
            Rectangle {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                radius: height
                color: passwordView.ready ? "green" : "red"
            }

            Label {
                text: "Ready"
            }

            Switch {
                id: createNewPassword
                focusPolicy: Qt.NoFocus
                text: "Create new password"
                checked: true
            }

            Switch {
                id: highSizeIntroSwitch
                focusPolicy: Qt.NoFocus
                text: "High size Intro"
            }

            Switch {
                id: titleVisibleSwitch
                focusPolicy: Qt.NoFocus
                text: "Title visible"
                checked: true
            }

            Button {
                text: "Paste password"
                focusPolicy: Qt.NoFocus

                onClicked: {
                    const input1 = StorybookUtils.findChild(
                                     passwordView,
                                     "passwordViewNewPassword")
                    const input2 = StorybookUtils.findChild(
                                     passwordView,
                                     "passwordViewNewPasswordConfirm")

                    if (!input1 || !input2)
                        return

                    input1.text = input2.text = passwordView.existingPassword
                }
            }

            Slider {
                id: slider
                from: 50
                to: 600
                value: 350
            }
        }
    }
}

// category: Views
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=236-23883&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=884-44477&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=62-8230&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=62-10411&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=62-8752&m=dev
