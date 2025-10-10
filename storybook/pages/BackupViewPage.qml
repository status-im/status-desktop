import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core.Backpressure

import Storybook

import AppLayouts.Profile.views

import utils

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    BackupView {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        contentWidth: 664

        backupDataState: Constants.BackupImportState.None
        backupDataError: ctrlErrorState.checked ? "ERR" : ""

        backupImportState: Constants.BackupImportState.None
        backupImportError: ctrlErrorState.checked ? "ERR" : ""

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

        onPerformLocalBackupRequested: {
            logs.logEvent("BackupView::onPerformLocalBackupRequested")
            backupDataState = Constants.BackupImportState.Completed
            Backpressure.debounce(this, 5000, () => {
                backupDataState = Constants.BackupImportState.None
            })()
        }
        onImportLocalBackupFileRequested: function(selectedFile) {
            logs.logEvent("BackupView::onImportLocalBackupFileRequested", ["selectedFile"], arguments)
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
