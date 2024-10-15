import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Extras 1.4

import shared.views 1.0

import Storybook 1.0

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    Item {
        id: wrapper
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PasswordView {
            id: passwordView
            width: 460
            height: 416
            anchors.centerIn: parent
            onReturnPressed: logs.logEvent("Return pressed", ["Current Password", "New Password", "Confirmation Password"], [passwordView.currentPswText, passwordView.newPswText, passwordView.confirmationPswText])

            createNewPsw: createNewPassword.checked
            titleVisible: titleVisibleSwitch.checked
            highSizeIntro: highSizeIntroSwitch.checked
            passwordStrengthScoreFunction: (newPass) => Math.min(newPass.length, 4)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        RowLayout {
            StatusIndicator {
                color: "green"
                active: passwordView.ready
            }

            Text {
                leftPadding: 10
                text: "Ready"
            }

            Switch {
                id: createNewPassword
                text: "Create new password"
                checked: true
            }

            Switch {
                id: highSizeIntroSwitch
                text: "High size Intro"
            }

            Switch {
                id: titleVisibleSwitch
                text: "Title visible"
                checked: true
            }
        }
    }
}

// category: Views

// https://www.figma.com/design/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=41014-22302&node-type=frame&t=0JUvGJPEhU9e9QB9-0
