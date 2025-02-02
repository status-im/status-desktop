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

    Binding {
        target: root.Window.window.contentItem
        property: "enabled"
        value: !loader.item.loading
    }

    BiometricsPopup {
        id: biometricsPopup

        x: root.Window.width - width

        password: ""
        pin: ""
        selectedProfileIsKeycard: ""
    }


    Component {
        id: nativeKeychainComponent

        Keychain {
            id: keychain
            service: "StatusStorybook"
            reason: "<reason here>"
        }
    }

    Component {
        id: mockedKeychainComponent

        Keychain {
            id: keychain
            service: "StatusStorybook"
            reason: "<reason here>"

            property bool loading: false
            property var store: ({})

            property string key
            property string value
            property string operation // save, delete, get

            function requestSaveCredential(account, password) {
                loading = true
                key = account
                value = password
                operation = "save"
                biometricsPopup.open()
            }

            function requestDeleteCredential(account) {
                loading = true
                key = account
                operation = "delete"
                biometricsPopup.open()
            }

            function requestGetCredential(account) {
                loading = true
                key = account
                operation = "get"
                biometricsPopup.open()
            }

            readonly property Connections connections: Connections {
                target: biometricsPopup

                function onObtainingPasswordSuccess(password) {
                    loading = false

                    if (keychain.operation === "get") {
                        const value = store[key]
                        let rc = Keychain.StatusSuccess
                        if (value === undefined)
                            rc = Keychain.StatusNotFound
                        keychain.getCredentialRequestCompleted(rc, value)
                    } else if (keychain.operation === "save") {
                        store[key] = value
                        keychain.saveCredentialRequestCompleted(true)
                    } else if (keychain.operation === "delete") {
                        delete store[key]
                        keychain.deleteCredentialRequestCompleted(true)
                    }
                }

                function onObtainingPasswordError() {
                    loading = false

                    if (keychain.operation === "get") {
                        keychain.getCredentialRequestCompleted(Keychain.StatusGenericError, "")
                    } else if (keychain.operation === "save") {
                        keychain.saveCredentialRequestCompleted(false)
                    } else if (keychain.operation === "delete") {
                        keychain.deleteCredentialRequestCompleted(false)
                    }
                }
            }
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
                    loader.item.requestSaveCredential(accountInput.text, passwordInput.text)
                }
            }
            Button {
                text: "Delete"
                onClicked: {
                    loader.item.requestDeleteCredential(accountInput.text)
                }
            }
            Button {
                text: "Get"
                onClicked: {
                    loader.item.requestGetCredential(accountInput.text)
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

        function onSaveCredentialRequestCompleted(success) {
            logs.logEvent("SaveCredentials", ["success"], [success])
        }

        function onDeleteCredentialRequestCompleted(success) {
            logs.logEvent("DeleteCredential", ["success"], [success])
        }

        function onGetCredentialRequestCompleted(status, password) {
            logs.logEvent("GetCredential", ["status", "password"], [status, password])
            passwordInput.text = password
        }
    }
}
