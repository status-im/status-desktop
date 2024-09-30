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
                text: "Open Contact Verification Request Popup"
                Layout.alignment: Qt.AlignHCenter
                onClicked: contactVerificationRequestPopup.open()
            }

            Item {
                Layout.preferredWidth: contactVerificationRequestPopup.implicitWidth
                Layout.preferredHeight: contactVerificationRequestPopup.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                ContactVerificationRequestPopup {
                    id: contactVerificationRequestPopup
                    visible: false
                    senderPublicKey: senderPublicKeyInput.text
                    challengeText: challengeTextInput.text
                    messageTimestamp: messageTimestampInput.value
                    onVerificationRefused: {
                        log("Verification request declined")
                    }
                    onResponseSent: {
                        log("Response sent: " + response)
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
                text: "Contact Verification Request Popup Settings"
                font.bold: true
                font.pixelSize: 16
            }

            Label { text: "Sender Public Key" }
            TextField {
                id: senderPublicKeyInput
                Layout.fillWidth: true
                placeholderText: "Enter sender's public key"
            }

            Label { text: "Challenge Text" }
            TextArea {
                id: challengeTextInput
                Layout.fillWidth: true
                placeholderText: "Enter challenge text"
            }

            Label { text: "Message Timestamp" }
            SpinBox {
                id: messageTimestampInput
                Layout.fillWidth: true
                from: 0
                to: 2147483647  // Max 32-bit integer
                value: Date.now()
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
