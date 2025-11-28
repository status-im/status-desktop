import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.Onboarding.components

OnboardingPage {
    id: root

    signal backupSeedphraseRemovalConfirmed()

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(440, root.availableWidth)
            spacing: Theme.xlPadding

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Confirm backup")
                font.pixelSize: Theme.fontSize(22)
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Ensure you have written down your recovery phrase and have a safe place to keep it. Remember, anyone who has your recovery phrase has access to your funds.")
            }

            Item { Layout.preferredHeight: 120 }

            StatusCheckBox {
                objectName: "cbAck"
                Layout.fillWidth: true
                id: cbAck
                text: qsTr("I understand my recovery phrase will now be removed and I will no longer be able to access it via Status")
            }

            StatusButton {
                objectName: "btnContinue"
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Continue")
                enabled: cbAck.checked
                onClicked: root.backupSeedphraseRemovalConfirmed()
            }
        }
    }
}
