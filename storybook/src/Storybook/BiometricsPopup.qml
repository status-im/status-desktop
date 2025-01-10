import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Dialog {
    id: root

    required property string password
    required property string pin

    // password signals
    signal accountLoginError(string error, bool wrongPassword)

    // biometrics signals
    signal obtainingPasswordSuccess(string password)
    signal obtainingPasswordError(string errorDescription, string errorType /* Constants.keychain.errorType.* */, bool wrongFingerprint)

    width: 300
    margins: 40

    closePolicy: Popup.NoAutoClose

    contentItem: ColumnLayout {
        spacing: 10
        StatusIcon {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            icon: "touch-id"
            color: Theme.palette.baseColor1
        }
        Label {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            text: "Status Desktop"
            font.pixelSize: 20
        }
        Label {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            text: "Status Desktop is trying to authenticate you.\n\nTouch ID or enter your password to allow this."
        }
        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            type: StatusBaseButton.Type.Primary
            focusPolicy: Qt.NoFocus
            text: "Use password..."
            onClicked: {
                root.close()
                root.obtainingPasswordError("Password required instead of touch ID.", Constants.keychain.errorType.keychain, false)
            }
        }
        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            focusPolicy: Qt.NoFocus
            text: "Cancel"
            onClicked: {
                root.close()
                root.obtainingPasswordError("Touch ID canceled, try entering password instead.", Constants.keychain.errorType.keychain, false)
            }
        }
        Item { Layout.preferredHeight: 20 }
        StatusButton {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            type: StatusBaseButton.Type.Success
            focusPolicy: Qt.NoFocus
            text: "Simulate correct fingerprint"
            onClicked: {
                root.close()
                root.obtainingPasswordSuccess(loginScreen.selectedProfileIsKeycard ? root.pin : root.password)
            }
        }
        StatusButton {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            type: StatusBaseButton.Type.Danger
            focusPolicy: Qt.NoFocus
            text: "Simulate wrong fingerprint"
            onClicked: {
                root.close()
                root.obtainingPasswordError("Wrong fingerprint provided.", Constants.keychain.errorType.keychain, true)
            }
        }
    }
}
