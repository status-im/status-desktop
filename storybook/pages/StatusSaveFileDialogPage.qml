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
            text: "Download"
            onClicked: dlgSave.open()
        }

        StatusSaveFileDialog {
            id: dlgSave

            title: titleText.text
            acceptLabel: qsTr("Save")
            selectedFile: documentsLocation + "/messages.json"
            defaultSuffix: "json"

            onAccepted: {
                logs.logEvent("StatusFileDialog::onAccepted - dlgSave --> Selected File " + dlgSave.selectedFile)
            }
            onRejected: logs.logEvent("StatusFileDialog::onRejected - dlgSave")
            onTitleChanged: logs.logEvent("StatusFileDialog::onTitleChanged - dlgSave --> " + dlgSave.title)
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

                    text: "Choose files to import"
                }
            }
        }
    }
}

// category: Dialogs
// status: good
