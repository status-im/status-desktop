import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Popups.Dialog 0.1

import Models 1.0
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

        StatusFileDialog {
            id: dlg

            title: titleText.text
            selectMultiple: selectMultiple.checked
            nameFilters: filtersText.text
            currentFolder: folderText.text
            onAccepted: {
                logs.logEvent("StatusFileDialog::onAccepted --> Selected Files: " + dlg.selectedFiles.length)
                if (dlg.selectedFiles.length > 0) {
                    for (let i = 0; i < dlg.selectedFiles.length; i++)
                        logs.logEvent("StatusFileDialog::onAccepted --> " + decodeURI(dlg.selectedFiles[i].toString()))
                }
            }
            onRejected: logs.logEvent("StatusFileDialog::onRejected")
            onTitleChanged: logs.logEvent("StatusFileDialog::onTitleChanged --> " + dlg.title)
            onCurrentFolderChanged: logs.logEvent("StatusFileDialog::onCurrentFolderChanged --> " + dlg.currentFolder)
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

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Name Filters:\t"
                }

                TextField {
                    id: filtersText

                    text: "JSON files (%1)".arg("*.json *.JSON")
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Multiple Selection:\t"
                }

                CheckBox {
                    id: selectMultiple
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Folder:\t"
                }

                TextField {
                    id: folderText

                    text: dlg.picturesShortcut
                }
            }
        }
    }
}

// category: Dialogs
// status: good
