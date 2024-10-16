import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import shared.popups 1.0
import Models 1.0

import utils 1.0
import shared.status 1.0

SplitView {
    id: root

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            Item {
                Layout.preferredHeight: 50
            }

            Button {
                text: "Open Mark as ID Verified Dialog"
                Layout.alignment: Qt.AlignHCenter
                onClicked: markAsIDVerifiedDialog.open()
            }

            Item {
                Layout.preferredWidth: markAsIDVerifiedDialog.implicitWidth
                Layout.preferredHeight: markAsIDVerifiedDialog.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                MarkAsIDVerifiedDialog {
                    id: markAsIDVerifiedDialog
                    visible: false
                    onAccepted: {
                        markAsIDVerifiedDialog.close()
                        log("User marked as ID verified: " + nameInput.text)
                    }
                }
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 400
        SplitView.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            Label {
                text: "Mark as ID Verified Dialog Settings"
                font.bold: true
                font.pixelSize: 16
            }

            Label { text: "Name" }
            TextField {
                id: nameInput
                Layout.fillWidth: true
                placeholderText: "Enter name"
            }

            Item {
                Layout.fillHeight: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: "Logs"
                    font.bold: true
                    font.pixelSize: 16
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    clip: true

                    TextArea {
                        id: logsTextArea
                        readOnly: true
                        wrapMode: TextEdit.Wrap
                        selectByMouse: true
                    }
                }

                Button {
                    text: "Clear Logs"
                    onClicked: logsTextArea.clear()
                }
            }
        }
    }

    function log(message) {
        var timestamp = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")
        logsTextArea.append(timestamp + ": " + message)
    }
}
