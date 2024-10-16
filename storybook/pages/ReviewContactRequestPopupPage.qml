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
                text: "Open Review Contact Request Popup"
                Layout.alignment: Qt.AlignHCenter
                onClicked: reviewContactRequestPopup.open()
            }

            Item {
                Layout.preferredWidth: reviewContactRequestPopup.implicitWidth
                Layout.preferredHeight: reviewContactRequestPopup.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                ReviewContactRequestPopup {
                    id: reviewContactRequestPopup
                    visible: false
                    contactRequestId: contactRequestIdInput.text
                    fromAddress: fromAddressInput.text
                    clock: clockInput.value
                    text: messageInput.text
                    contactRequestState: contactRequestStateSelector.currentValue
                    onAccepted: {
                        reviewContactRequestPopup.close()
                        log("Contact request accepted")
                    }
                    onDiscarded: {
                        reviewContactRequestPopup.close()
                        log("Contact request ignored")
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
                text: "Review Contact Request Popup Settings"
                font.bold: true
                font.pixelSize: 16
            }

            Label { text: "Contact Request ID" }
            TextField {
                id: contactRequestIdInput
                Layout.fillWidth: true
                placeholderText: "Enter contact request ID"
            }

            Label { text: "From Address" }
            TextField {
                id: fromAddressInput
                Layout.fillWidth: true
                placeholderText: "Enter from address"
            }

            Label { text: "Clock" }
            SpinBox {
                id: clockInput
                Layout.fillWidth: true
                from: 0
                to: 2147483647  // Max 32-bit integer
            }

            Label { text: "Message" }
            TextArea {
                id: messageInput
                Layout.fillWidth: true
                placeholderText: "Enter contact request message"
            }

            Label { text: "Contact Request State" }
            ComboBox {
                id: contactRequestStateSelector
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: "Pending", value: 0 },
                    { text: "Accepted", value: 1 },
                    { text: "Declined", value: 2 }
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
