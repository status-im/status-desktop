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
                text: "Open Remove Contact Popup"
                Layout.alignment: Qt.AlignHCenter
                onClicked: removeContactPopup.open()
            }

            Item {
                Layout.preferredWidth: removeContactPopup.implicitWidth
                Layout.preferredHeight: removeContactPopup.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                RemoveContactPopup {
                    id: removeContactPopup
                    visible: false
                    outgoingVerificationStatus: outgoingVerificationStatusSelector.currentValue
                    incomingVerificationStatus: incomingVerificationStatusSelector.currentValue
                    trustStatus: trustStatusSelector.currentValue
                    onAccepted: {
                        removeContactPopup.close()
                        log("Contact removed: " + nameInput.text)
                        log("Remove ID Verification: " + removeContactPopup.removeIDVerification)
                        log("Mark as Untrusted: " + removeContactPopup.markAsUntrusted)
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
                text: "Remove Contact Popup Settings"
                font.bold: true
                font.pixelSize: 16
            }

            Label { text: "Name" }
            TextField {
                id: nameInput
                Layout.fillWidth: true
                placeholderText: "Enter name"
            }

            Label { text: "Outgoing Verification Status" }
            ComboBox {
                id: outgoingVerificationStatusSelector
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

            Label { text: "Trust Status" }
            ComboBox {
                id: trustStatusSelector
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "None", value: Constants.trustStatus.none },
                    { text: "Untrusted", value: Constants.trustStatus.untrustworthy },
                    { text: "Trusted", value: Constants.trustStatus.trusted }
                ]
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
