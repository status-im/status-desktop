import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import QtQuick.Window

import Qt.labs.settings

import StatusQ

import Storybook

Page {
    id: root

    readonly property bool isMac: Qt.platform.os === "osx"

    Logs { id: logs }

    Settings {
        property alias mockedKeychainAvailable: keychainAvailableCheckBox.checked
    }

    QtObject {
        id: d

        readonly property bool keychainAvailable: loader.item.available
        readonly property bool useMockedKeychain: root.isMac && !forceMockedKeychainCheckBox.checked
    }

    Loader {
        id: loader

        sourceComponent: d.useMockedKeychain ? nativeKeychainComponent
                                             : mockedKeychainComponent
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
            available: keychainAvailableCheckBox.checked
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
            text: `Is MacOS: ${root.isMac ? "🍏" : "🙅‍"}, Keychain available: ${d.keychainAvailable ? "✅" : "❌"}`
        }

        CheckBox {
            id: forceMockedKeychainCheckBox

            visible: root.isMac
            text: `Force using mocked Keychain`
        }

        CheckBox {
            id: keychainAvailableCheckBox
            text: `Mocked keychain available`
            enabled: !d.useMockedKeychain
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
                enabled: d.keychainAvailable
                onClicked: {
                    const status = loader.item.saveCredential(accountInput.text, passwordInput.text)
                    logs.logEvent("SaveCredentials", ["status"], [status])
                }
            }
            Button {
                text: "Delete"
                enabled: d.keychainAvailable
                onClicked: {
                    const status = loader.item.deleteCredential(accountInput.text)
                    logs.logEvent("DeleteCredential", ["status"], [status])
                }
            }
            Button {
                text: "Get"
                enabled: d.keychainAvailable
                onClicked: {
                    loader.item.requestGetCredential("Get reason",
                                                     accountInput.text)
                }
            }
            Button {
                text: "Has"
                enabled: d.keychainAvailable
                onClicked: {
                    const status = loader.item.hasCredential(accountInput.text)
                    logs.logEvent("HasCredential", ["status"], [status])

                }
            }
            Button {
                text: "Cancel"
                enabled: d.keychainAvailable
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
