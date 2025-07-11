import QtQuick
import QtQuick.Layouts

import StatusQ.Core.Theme

import shared.stores
import shared.views

import utils

Item {
    id: root

    property var sharedKeycardModule

    signal passwordValid(bool valid)

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Theme.xlPadding
        anchors.bottomMargin: Theme.halfPadding
        anchors.leftMargin: Theme.xlPadding
        anchors.rightMargin: Theme.xlPadding
        spacing: Theme.padding

        PasswordView {
            Layout.minimumWidth: 460
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            passwordStrengthScoreFunction: RootStore.getPasswordStrengthScore
            highSizeIntro: true

            newPswText: root.sharedKeycardModule.getNewPassword()
            confirmationPswText: root.sharedKeycardModule.getNewPassword()

            Component.onCompleted: {
                forceNewPswInputFocus()
                checkPasswordMatches()
                root.passwordValid(ready)
            }

            onReadyChanged: {
                root.passwordValid(ready)
                if (!ready) {
                    return
                }
                root.sharedKeycardModule.setNewPassword(newPswText)
            }
            onReturnPressed: {
                if(!ready) {
                    return
                }
                root.sharedKeycardModule.currentState.doPrimaryAction()
            }
        }
    }
}
