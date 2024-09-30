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
                text: "Open Outgoing Contact Verification Request Popup"
                Layout.alignment: Qt.AlignHCenter
                onClicked: verificationRequestPopup.open()
            }

            Item {
                Layout.preferredWidth: verificationRequestPopup.implicitWidth
                Layout.preferredHeight: verificationRequestPopup.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                OutgoingContactVerificationRequestPopup {
                    id: verificationRequestPopup
                    visible: false
                    verificationStatus: verificationStatusSelector.currentValue
                    verificationChallenge: challengeInput.text
                    verificationResponse: responseInput.text
                    verificationResponseDisplayName: verificationResponseNameInput.text
                    verificationResponseIcon: verificationResponseIconInput.text
                    verificationRequestedAt: requestedAtInput.text
                    verificationRepliedAt: repliedAtInput.text
                    ensVerified: ensVerifiedCheckBox.checked
                    pubKey: pubKeyInput.text
                    preferredName: preferredNameInput.text
                    name: nameInput.text
                    icon: iconInput.text
                    onVerificationRequestCanceled: {
                        log("Verification request canceled")
                    }
                    onUntrustworthyVerified: {
                        log("Marked as untrusted")
                    }
                    onTrustedVerified: {
                        log("Marked as verified")
                    }
                    onOnLinkActivated: {
                        log("Link activated")
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
                text: "Verification Request Popup Settings"
                font.bold: true
                font.pixelSize: 16
            }

            Label { text: "Name" }
            TextField {
                id: nameInput
                Layout.fillWidth: true
                placeholderText: "Enter name"
            }

            Label { text: "Icon" }
            TextField {
                id: iconInput
                Layout.fillWidth: true
                placeholderText: "Enter icon"
            }

            Label { text: "Verification Status" }
            ComboBox {
                id: verificationStatusSelector
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Untrustworthy", value: Constants.verificationStatus.untrustworthy },
                    { text: "Trusted", value: Constants.verificationStatus.trusted }
                ]
            }

            Label { text: "Challenge" }
            TextField {
                id: challengeInput
                Layout.fillWidth: true
                placeholderText: "Enter challenge"
            }

            Label { text: "Response" }
            TextField {
                id: responseInput
                Layout.fillWidth: true
                placeholderText: "Enter response"
            }

            Label { text: "Verification Response Display Name" }
            TextField {
                id: verificationResponseNameInput
                Layout.fillWidth: true
                placeholderText: "Enter verification response display name"
            }

            Label { text: "Verification Response Icon" }
            TextField {
                id: verificationResponseIconInput
                Layout.fillWidth: true
                placeholderText: "Enter verification response icon"
            }

            Label { text: "Requested At" }
            TextField {
                id: requestedAtInput
                Layout.fillWidth: true
                placeholderText: "Enter requested time"
            }

            Label { text: "Replied At" }
            TextField {
                id: repliedAtInput
                Layout.fillWidth: true
                placeholderText: "Enter replied time"
            }

            Label { text: "Public Key" }
            TextField {
                id: pubKeyInput
                Layout.fillWidth: true
                placeholderText: "Enter public key"
            }

            Label { text: "Preferred Name" }
            TextField {
                id: preferredNameInput
                Layout.fillWidth: true
                placeholderText: "Enter preferred name"
            }

            CheckBox {
                id: ensVerifiedCheckBox
                text: "ENS Verified"
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
