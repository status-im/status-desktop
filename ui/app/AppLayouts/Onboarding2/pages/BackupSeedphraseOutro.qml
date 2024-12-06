import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.components 1.0

OnboardingPage {
    id: root

    signal backupSeedphraseRemovalConfirmed()

    pageClassName: "BackupSeedphraseOutro"

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(440, root.availableWidth)
            spacing: Theme.xlPadding

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Backup your recovery phrase")
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StepIndicator {
                Layout.fillWidth: true
                spacing: Theme.halfPadding
                currentStep: 3
                totalSteps: 3
                caption: qsTr("Store your phrase offline")
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
