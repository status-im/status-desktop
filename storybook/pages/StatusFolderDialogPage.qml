import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Popups.Dialog 0.1

import Storybook 1.0

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

            visible: true
            title: titleText.text
            onAccepted: logs.logEvent("StatusFolderDialog::onAccepted --> Selected File: " + dlg.selectedFolder)
            onRejected: logs.logEvent("StatusFolderDialog::onRejected")
            onTitleChanged: logs.logEvent("StatusFolderDialog::onTitleChanged --> " + dlg.title)
            onCurrentFolderChanged: logs.logEvent("StatusFolderDialog::onCurrentFolderChanged --> " + dlg.currentFolder)
        }
    }

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
