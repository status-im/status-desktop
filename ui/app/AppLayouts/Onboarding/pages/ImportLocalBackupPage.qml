import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog

import AppLayouts.Onboarding.controls

import utils

OnboardingPage {
    id: root

    title: qsTr("Import local backup")

    signal importLocalBackupRequested(url importFilePath)
    signal skipRequested()

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(400, root.availableWidth)
            spacing: 20

            StatusImage {
                Layout.preferredWidth: 325
                Layout.preferredHeight: 325
                Layout.alignment: Qt.AlignHCenter
                source: Theme.png("onboarding/status_chat")
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.fontSize22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Import the backup file for your Status profile, or skip this step and import it later from Settings > On-device backups")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StatusButton {
                objectName: "btnImportFile"
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.width
                Layout.minimumWidth: 180
                text: qsTr("Import backup file")
                onClicked: fileDlg.open()
            }
            StatusButton {
                objectName: "btnSkipImport"
                Layout.alignment: Qt.AlignHCenter
                Layout.minimumWidth: 180
                text: qsTr("Skip")
                isOutline: true
                onClicked: root.skipRequested()
            }
        }
    }

    StatusFileDialog {
        id: fileDlg
        nameFilters: [qsTr("Backup files (%1)").arg("*.bkp *.BKP")]
        onAccepted: root.importLocalBackupRequested(selectedFile)
    }
}
