import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog

import AppLayouts.Onboarding2.controls

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
            spacing: root.padding
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
                text: qsTr("Here you can select a local file from your computer and import your previously backed up contacts, etc...")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("You can skip this step and do it anytime later under Settings > Syncing")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StatusImage {
                Layout.preferredWidth: 325
                Layout.preferredHeight: 325
                Layout.topMargin: Theme.bigPadding
                Layout.bottomMargin: Theme.bigPadding
                Layout.alignment: Qt.AlignHCenter
                source: Theme.png("onboarding/status_chat")
            }

            StatusButton {
                objectName: "btnImportFile"
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.width
                Layout.preferredWidth: 320
                text: qsTr("Import from file...")
                onClicked: fileDlg.open()
            }
            StatusButton {
                objectName: "btnSkipImport"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 320
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
