import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: "ENTER NUMERIC PIN, EXPECTED LENGTH: %1".arg(pinInput.pinLen)
        }
        StatusPinInput {
            Layout.alignment: Qt.AlignHCenter
            id: pinInput
            validator: StatusIntValidator { bottom: 0; top: 999999 }
            Component.onCompleted: {
                statesInitialization()
                forceFocus()
            }
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: "ENTERED PIN: %1".arg(pinInput.pinInput || "[empty]")
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: "VALID: %1".arg(pinInput.valid ? "true" : "false")
        }
    }
}

// category: Controls
// status: good
