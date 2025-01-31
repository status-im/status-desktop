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

        onSaveCredentialFinished: (ok) => {
                                      logs.logEvent("SaveCredentialsFinsihed", ["ok"], [ok])
                                  }

        onDeleteCredentialFinished: (ok) => {
                                        logs.logEvent("DeleteCredentialFinsihed", ["ok"], [ok])
                                    }

        onGetCredentialFinished: (ok, password) => {
                                     logs.logEvent("GetCredentialFinished", ["ok", "password"], [ok, password])
                                 }
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
                    onClicked: keychain.requestSaveCredential(accountInput.text, passwordInput.text)
                }
                Button {
                    text: "Delete"
                    onClicked: keychain.requestDeleteCredential(accountInput.text)
                }
                Button {
                    text: "Get"
                    onClicked: keychain.requestGetCredential(accountInput.text)
                }
                BusyIndicator {
                    Layout.preferredHeight: 40
                    running: keychain.loading
                }
            }
        }
    }
}
