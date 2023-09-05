import QtQuick 2.14
import QtQuick.Layouts 1.14

import shared.views 1.0

import utils 1.0

Item {
    id: root

    property var sharedKeycardModule

    signal passwordMatch(bool result)

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.padding

        PasswordConfirmationView {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            spacing: Style.current.bigPadding

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
