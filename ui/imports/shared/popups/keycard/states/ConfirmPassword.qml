import QtQuick
import QtQuick.Layouts

import StatusQ.Core.Theme

import shared.views

import utils

Item {
    id: root

    property var sharedKeycardModule

    signal passwordMatch(bool result)

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Theme.xlPadding
        anchors.bottomMargin: Theme.halfPadding
        anchors.leftMargin: Theme.xlPadding
        anchors.rightMargin: Theme.xlPadding
        spacing: Theme.padding

        PasswordConfirmationView {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            spacing: Theme.bigPadding

            expectedPassword: root.sharedKeycardModule.getNewPassword()

            Component.onCompleted: {
                forceInputFocus()
            }

            onPasswordMatchChanged: {
                root.passwordMatch(passwordMatch)
            }

            onSubmit: {
                if(passwordMatch) {
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }
        }
    }
}
