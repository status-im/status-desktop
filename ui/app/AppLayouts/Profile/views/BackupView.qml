import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Backpressure
import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog

import AppLayouts.Profile.stores as ProfileStores

import utils
import shared.panels
import shared.status

SettingsContentBase {
    id: root

    required property ProfileStores.DevicesStore devicesStore
    required property bool messagesBackupEnabled
    required property url backupPath

    signal backupPathSet(url path)
    signal backupMessagesEnabledToggled(bool enabled)

    ColumnLayout {
        id: layout
        width: root.contentWidth
        spacing: Theme.padding

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            wrapMode: Text.Wrap
            text: qsTr("Backups are automatic (every 30 mins), secure (encrypted with your profile private key), and private (your data is stored <b>only</b> on your device).")
        }

        Separator { Layout.fillWidth: true }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            wrapMode: Text.Wrap
            text: qsTr("Instant backup")
            font.bold: true
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            wrapMode: Text.Wrap
            text: qsTr("By default, backups run automatically every 30 minutes, but you can trigger one instantly with Backup now.")
            color: Theme.palette.baseColor1
        }

        StatusButton {
            Layout.leftMargin: Theme.padding
            text: qsTr("Backup now")
            icon.name: {
                if (root.devicesStore.backupDataState !== Constants.BackupImportState.Completed) {
                    return ""
                }
                if (root.devicesStore.backupDataError) {
                    return "tiny/exclamation"
                }
                return "tiny/checkmark"
            }
            icon.color: {
                if (root.devicesStore.backupDataState !== Constants.BackupImportState.Completed) {
                    return Theme.palette.primaryColor1
                }
                if (root.devicesStore.backupDataError) {
                    return Theme.palette.dangerColor1
                }
                return Theme.palette.successColor1
            }

            loading: root.devicesStore.backupDataState === Constants.BackupImportState.InProgress
            onClicked : {
                root.devicesStore.performLocalBackup()
                Backpressure.debounce(this, 5000, () => {
                    root.devicesStore.resetBackupDataState()
                })()
            }
        }

        Separator {
            Layout.fillWidth: true
            Layout.topMargin: Theme.padding
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            wrapMode: Text.Wrap
            text: qsTr("Backup data")
            font.bold: true
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            wrapMode: Text.Wrap
            text: qsTr("By default, Status backs up your chat list and contacts, joined community IDs and descriptions, app settings, profile data, and wallet watch accounts. " +
                       "To also back up your 1-on-1, group chat, and community messages, enable Back up your messages")
            color: Theme.palette.baseColor1
        }

        StatusSettingsLineButton {
            Layout.fillWidth: true
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            text: qsTr("Backup your messages")
            isSwitch: true
            switchChecked: root.messagesBackupEnabled
            onClicked: (checked) => root.backupMessagesEnabledToggled(checked)
        }

        Separator {
            Layout.fillWidth: true
            Layout.topMargin: Theme.halfPadding
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            wrapMode: Text.Wrap
            text: qsTr("Backup location")
            font.bold: true
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            wrapMode: Text.Wrap
            text: qsTr("Choose a folder to store your backup files or use the default one.")
            color: Theme.palette.baseColor1
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            StatusInput {
                Layout.fillWidth: true
                input.edit.enabled: false
                text: UrlUtils.convertUrlToLocalPath(root.backupPath)
            }
            StatusButton {
                text: qsTr("Browse")
                onClicked: backupPathDialog.open()
            }
        }

        Separator {
            Layout.fillWidth: true
            Layout.topMargin: Theme.halfPadding
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            wrapMode: Text.Wrap
            text: qsTr("Restore your Status profile")
            font.bold: true
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            wrapMode: Text.Wrap
            text: qsTr("Click Import backup file, then locate and select the backup file for your Status profile.")
            color: Theme.palette.baseColor1
        }

        StatusButton {
            Layout.leftMargin: Theme.padding
            text: qsTr("Import backup file")
            loading: root.devicesStore.backupImportState === Constants.BackupImportState.InProgress
            onClicked: importBackupFileDialog.open()
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            color: Theme.palette.successColor1
            visible: root.devicesStore.backupImportState === Constants.BackupImportState.Completed && !root.devicesStore.backupImportError
            text: qsTr("Success importing local data")
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            color: Theme.palette.dangerColor1
            visible: !!root.devicesStore.backupImportError
            wrapMode: Text.WordWrap
            text: qsTr("Error importing backup file: %1").arg(root.devicesStore.backupImportError)
        }
    }

    StatusFolderDialog {
        id: backupPathDialog

        title: qsTr("Select your backup directory")
        currentFolder: root.devicesStore.toFileUri(root.backupPath)
        onAccepted: root.backupPathSet(backupPathDialog.selectedFolder)
    }

    StatusFileDialog {
        id: importBackupFileDialog

        title: qsTr("Select your backup file")
        nameFilters: [qsTr("Supported backup formats (%1)").arg("*.bkp")]
        currentFolder: root.devicesStore.toFileUri(root.backupPath)
        onAccepted: root.devicesStore.importLocalBackupFile(importBackupFileDialog.selectedFile)
    }
}
