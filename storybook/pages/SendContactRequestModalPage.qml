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
                text: "Open Send Contact Request Modal"
                Layout.alignment: Qt.AlignHCenter
                onClicked: sendContactRequestModal.open()
            }

            Item {
                Layout.preferredWidth: sendContactRequestModal.implicitWidth
                Layout.preferredHeight: sendContactRequestModal.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                SendContactRequestModal {
                    id: sendContactRequestModal
                    visible: false
                    labelText: labelTextInput.text
                    challengeText: challengeTextInput.text
                    buttonText: buttonTextInput.text
                    onAccepted: function(message) {
                        log("Contact request sent with message: " + message)
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
                text: "Send Contact Request Modal Settings"
                font.bold: true
                font.pixelSize: 16
            }

            Label { text: "Label Text" }
            TextField {
                id: labelTextInput
                Layout.fillWidth: true
                text: qsTr("Why should they accept your contact request?")
                placeholderText: "Enter label text"
            }

            Label { text: "Challenge Text" }
            TextField {
                id: challengeTextInput
                Layout.fillWidth: true
                text: qsTr("Write a short message telling them who you are...")
                placeholderText: "Enter challenge text"
            }

            Label { text: "Button Text" }
            TextField {
                id: buttonTextInput
                Layout.fillWidth: true
                text: qsTr("Send contact request")
                placeholderText: "Enter button text"
            }

            Item {
                Layout.fillHeight: true
            }

            // Add logs section
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

    // Add log function
    function log(message) {
        var timestamp = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")
        logsTextArea.append(timestamp + ": " + message)
    }
}
