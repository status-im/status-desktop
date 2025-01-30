import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

import Storybook 1.0

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    Keychain {
        id: keychain
        service: "StatusStorybook"
        reason: qsTr("<reason here>")
    }

    LogsView {
        id: logsView

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        clip: true
        logText: logs.logText
    }

    Pane {
        id: controlsPane

        ColumnLayout {
            RowLayout {
                Text {
                    text: "Account"
                }
                TextField {
                    id: accountInput
                    text: "1"
                    placeholderText: "Account"
                }
            }
            RowLayout {
                Text {
                    text: "Password"
                }
                TextField {
                    id: passwordInput
                    text: "11"
                    placeholderText: "Password"
                }
            }
            RowLayout {
                Button {
                    text: "Save"
                    onClicked: {
                        const ok = keychain.saveCredential(accountInput.text, passwordInput.text)
                        logs.logEvent(`SaveCredentials: ${ok}`)
                    }
                }
                Button {
                    text: "Delete"
                    onClicked: {
                        const ok = keychain.deleteCredential(accountInput.text)
                        logs.logEvent(`DeleteCredential: ${ok}`)
                    }
                }
                Button {
                    text: "Get"
                    onClicked: {
                        const password = keychain.getCredential(accountInput.text)
                        logs.logEvent(`GetCredential: "${password}"`)
                    }
                }
                BusyIndicator {
                    Layout.preferredHeight: 40
                    running: keychain.loading
                }
            }
        }
    }
}
