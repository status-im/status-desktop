import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1

import shared.views 1.0

import utils 1.0

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
