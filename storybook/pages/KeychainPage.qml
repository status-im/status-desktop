import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtQuick.Window 2.15

import StatusQ 0.1

import Storybook 1.0

Page {
    id: root

    readonly property bool isMac: Qt.platform.os === "osx"

    Logs { id: logs }

    Loader {
        id: loader

        sourceComponent: root.isMac && !forceMockedKeychainCheckBox.checked
                         ? nativeKeychainComponent : mockedKeychainComponent
    }

    Component {
        id: nativeKeychainComponent

        Keychain {
            service: "StatusStorybook"
        }
    }

    Component {
        id: mockedKeychainComponent

        KeychainMock {
            parent: root
        }
    }

    Frame {
        anchors.fill: logsView
        anchors.margins: -1
    }

    LogsView {
        id: logsView

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 2

        height: 200

        clip: true
        logText: logs.logText
    }

    ColumnLayout {
        anchors.centerIn: parent

        Text {
            text: `Is MacOS: ${root.isMac}`
        }

        CheckBox {
            id: forceMockedKeychainCheckBox

            visible: root.isMac
            text: `Force using mocked Keychain`
        }

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
                    const status = loader.item.saveCredential(accountInput.text, passwordInput.text)
                    logs.logEvent("SaveCredentials", ["status"], [status])
                }
            }
            Button {
                text: "Delete"
                onClicked: {
                    const status = loader.item.deleteCredential(accountInput.text)
                    logs.logEvent("DeleteCredential", ["status"], [status])
                }
            }
            Button {
                text: "Get"
                onClicked: {
                    loader.item.requestGetCredential("Get reason",
                                                     accountInput.text)
                }
            }
            Button {
                text: "Has"
                onClicked: {
                    const status = loader.item.hasCredential(accountInput.text)
                    logs.logEvent("HasCredential", ["status"], [status])

                }
            }
            Button {
                text: "Cancel"
                onClicked: {
                    loader.item.cancelActiveRequest()
                }
            }
            BusyIndicator {
                Layout.preferredHeight: 40
                running: loader.item.loading
            }
        }
    }

    Connections {
        target: loader.item

        function onGetCredentialRequestCompleted(status, password) {
            logs.logEvent("GetCredential", ["status", "password"], arguments)
            passwordInput.text = password
        }
    }
}
