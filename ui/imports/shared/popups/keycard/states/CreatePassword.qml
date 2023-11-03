import QtQuick 2.14
import QtQuick.Layouts 1.14

import shared.stores 1.0
import shared.views 1.0

import utils 1.0

Item {
    id: root

    property var sharedKeycardModule

    signal passwordValid(bool valid)

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: 2*(Style.current.xlPadding + Style.current.bigPadding)
        anchors.rightMargin: 2*(Style.current.xlPadding + Style.current.bigPadding)
        spacing: Style.current.padding

        PasswordView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            passwordStrengthScoreFunction: RootStore.getPasswordStrengthScore
            highSizeIntro: true
            fixIntroTextWidth: true

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
