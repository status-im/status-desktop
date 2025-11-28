import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme

import utils

Dialog {
    id: root

    // biometrics signals
    signal obtainingPasswordSuccess
    signal cancelled

    function cancel() {
        close()
        cancelled()
    }

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
            font.pixelSize: Theme.fontSize(20)
        }
        Label {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            text: "Status Desktop is trying to authenticate you.\n\nTouch ID or enter your password to allow this."
        }
        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            focusPolicy: Qt.NoFocus
            text: "Cancel"
            onClicked: {
                root.cancel()
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
                root.obtainingPasswordSuccess()
            }
        }
    }
}
