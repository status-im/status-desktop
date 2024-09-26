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
                text: "Open Mark as Untrusted Popup"
                Layout.alignment: Qt.AlignHCenter
                onClicked: markAsUntrustedPopup.open()
            }

            Item {
                Layout.preferredWidth: markAsUntrustedPopup.implicitWidth
                Layout.preferredHeight: markAsUntrustedPopup.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                MarkAsUntrustedPopup {
                    id: markAsUntrustedPopup
                    visible: false
                    // mainDisplayName: nameInput.text
                    verificationStatus: verificationStatusSelector.currentValue
                    incomingVerificationStatus: incomingVerificationStatusSelector.currentValue
                    isContact: isContactCheckBox.checked
                    trustStatus: trustStatusSelector.currentValue
                    onAccepted: {
                        markAsUntrustedPopup.close()
                        log("Marked as untrusted: " + nameInput.text)
                        log("Remove ID Verification: " + markAsUntrustedPopup.removeIDVerification)
                        log("Remove Contact: " + markAsUntrustedPopup.removeContact)
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
                text: "Mark as Untrusted Popup Settings"
                font.bold: true
                font.pixelSize: 16
            }

            Label { text: "Name" }
            TextField {
                id: nameInput
                Layout.fillWidth: true
                placeholderText: "Enter name"
            }

            Label { text: "Verification Status" }
            ComboBox {
                id: verificationStatusSelector
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Unverified", value: Constants.verificationStatus.unverified },
                    { text: "Untrustworthy", value: Constants.verificationStatus.untrustworthy },
                    { text: "Trusted", value: Constants.verificationStatus.trusted }
                ]
            }

            Label { text: "Incoming Verification Status" }
            ComboBox {
                id: incomingVerificationStatusSelector
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Unverified", value: Constants.verificationStatus.unverified },
                    { text: "Untrustworthy", value: Constants.verificationStatus.untrustworthy },
                    { text: "Trusted", value: Constants.verificationStatus.trusted }
                ]
            }

            CheckBox {
                id: isContactCheckBox
                text: "Is Contact"
            }

            Label { text: "Trust Status" }
            ComboBox {
                id: trustStatusSelector
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Untrusted", value: Constants.trustStatus.untrusted },
                    { text: "Trusted", value: Constants.trustStatus.trusted }
                ]
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
