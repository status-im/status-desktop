import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import StatusQ.Popups.Dialog

import Storybook

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: "lightgray"

        Button {
            anchors.centerIn: parent
            text: "Reopen"
            onClicked: dlg.open()
        }

        StatusFolderDialog {
            id: dlg

            title: titleText.text
            onAccepted: logs.logEvent("StatusFolderDialog::onAccepted --> Selected File: " + dlg.selectedFolder)
            onRejected: logs.logEvent("StatusFolderDialog::onRejected")
            onTitleChanged: logs.logEvent("StatusFolderDialog::onTitleChanged --> " + dlg.title)
            onCurrentFolderChanged: logs.logEvent("StatusFolderDialog::onCurrentFolderChanged --> " + dlg.currentFolder)
        }
    }

    Component.onCompleted: dlg.open()

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 300
        SplitView.preferredHeight: 300

        logsView.logText: logs.logText

        ColumnLayout {
             width: parent.width

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Title:\t"
                }

                TextField {
                    id: titleText

                    text: "Choose folder to import"
                }
            }
        }
    }
}

// category: Dialogs
// status: good
