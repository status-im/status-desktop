import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import Storybook 1.0

Keychain {
    id: root

    required property Item parent

    service: "StatusStorybookMocked"

    // shadowing Keychain's "loading" property
    readonly property alias loading: d.loading

    readonly property QObject _d: QObject {
        id: d

        property bool loading: false
        property string key
        property string value
        property string operation // save, delete, get
        property var store: ({})

        BiometricsPopup {
            id: biometricsPopup

            parent: root.parent
            x: parent.width - width
        }
    }

    // shadowing Keychain's functions
    function requestSaveCredential(reason, account, password) {
        d.loading = true
        d.key = account
        d.value = password
        d.operation = "save"
        biometricsPopup.open()
    }

    function requestDeleteCredential(reason, account) {
        d.loading = true
        d.key = account
        d.operation = "delete"
        biometricsPopup.open()
    }

    function requestGetCredential(reason, account) {
        d.loading = true
        d.key = account
        d.operation = "get"
        biometricsPopup.open()
    }

    function requestHasCredential(account) {
        const status = d.store[account] === undefined ? Keychain.StatusNotFound
                                                      : Keychain.StatusSuccess
        root.hasCredentialRequestCompleted(status)
    }

    function cancelActiveRequest() {
        if (!d.loading)
            return

        d.loading = false
        biometricsPopup.cancel()
    }

    readonly property Connections connections: Connections {
        target: biometricsPopup

        function onObtainingPasswordSuccess(password) {
            d.loading = false

            switch (d.operation) {
            case "get":
                const value = d.store[d.key]
                let rc = Keychain.StatusSuccess
                if (value === undefined)
                    rc = Keychain.StatusNotFound
                root.getCredentialRequestCompleted(rc, value)
                break
            case "save":
                d.store[d.key] = d.value
                root.saveCredentialRequestCompleted(Keychain.StatusSuccess)
                break;
            case "delete":
                delete d.store[d.key]
                root.deleteCredentialRequestCompleted(Keychain.StatusSuccess)
                break;
            }
        }

        function onCancelled() {
            d.loading = false

            switch (d.operation) {
            case "get":
                root.getCredentialRequestCompleted(Keychain.StatusCancelled, "")
                break;
            case "save":
                root.saveCredentialRequestCompleted(Keychain.StatusCancelled)
                break;
            case "delete":
                root.deleteCredentialRequestCompleted(Keychain.StatusCancelled)
                break;
            }
        }
    }
}
