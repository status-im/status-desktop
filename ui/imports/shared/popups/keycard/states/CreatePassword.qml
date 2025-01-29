import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1

import shared.stores 1.0
import shared.views 1.0

import utils 1.0

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
