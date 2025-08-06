import QtQuick

import shared.stores

SessionRequestResolved {
    id: root

    required property DAppsStore store

    // Signal to execute the request. Emitted after successful authentication
    // password and pin are the user's input for the authentication
    signal execute(string password, string pin)
    // Signal to reject the request. Emitted when the request is expired or rejected by the user
    // hasError is true if the request was rejected due to an error
    signal rejected(bool hasError)
    // Signal when the authentication flow fails
    signal authFailed()
    signal accepted()
    
    function accept() {
        if (root.isExpired()) {
            console.warn("Error: request expired")
            root.reject(true)
            return
        }
        storeConnections.enabled = true
        store.authenticateUser(root.topic, root.requestId, root.accountAddress, "")
        root.accepted()
    }

    function reject(hasError) {
        storeConnections.enabled = false
        root.rejected(hasError)
    }

    Connections {
        id: storeConnections
        enabled: false
        target: root.store
        
        function onUserAuthenticated(topic, id, password, pin, _) {
            if (id == root.requestId && topic == root.topic) {
                if (root.isExpired()) {
                    console.warn("Error: request expired")
                    root.reject(true)
                    return
                }
                root.execute(password, pin)
            }
        }

        function onUserAuthenticationFailed(topic, id) {
            if (id === root.requestId && topic === root.topic) {
                storeConnections.enabled = false
                root.authFailed()
            }
        }
    }
}