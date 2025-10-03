import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ

import Storybook

import AppLayouts.Profile.views
import AppLayouts.Profile.stores as ProfileStores

import utils

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    BackupView {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        contentWidth: 664

        devicesStore: ProfileStores.DevicesStore {
            property int backupImportState: Constants.BackupImportState.None
            readonly property string backupImportError: ctrlErrorState.checked ? "ERR" : ""
            function importLocalBackupFile(filePath) {
                logs.logEvent("DevicesStore::importLocalBackupFile", ["filePath"], arguments)
                backupImportState = Constants.BackupImportState.Completed
            }

            property int backupDataState: Constants.BackupImportState.None
            readonly property string backupDataError: ctrlErrorState.checked ? "ERR" : ""
            function performLocalBackup() {
                logs.logEvent("DevicesStore::performLocalBackup()")
                backupDataState = Constants.BackupImportState.Completed
            }
            function resetBackupDataState() {
                logs.logEvent("DevicesStore::resetBackupDataState()")
                backupDataState = Constants.BackupImportState.None
            }

            function toFileUri(path) {
                return UrlUtils.urlFromUserInput(path)
            }
        }

        backupPath: StandardPaths.writableLocation(StandardPaths.TempLocation)
        messagesBackupEnabled: false
        onBackupPathSet: function(path) {
            logs.logEvent("BackupView::onBackupPathSet", ["path"], arguments)
            backupPath = path
        }
        onBackupMessagesEnabledToggled: function(enabled) {
            logs.logEvent("BackupView::backupMessagesEnabledToggled", ["enabled"], arguments)
            messagesBackupEnabled = enabled
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        Switch {
            id: ctrlErrorState
            text: "Throw errors on import"
        }
    }
}

// category: Settings
// status: good
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=26826-65424&m=dev
