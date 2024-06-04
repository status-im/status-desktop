import QtQuick 2.15

/// SDK requires a visible parent to embed WebEngineView
Item {
    required property string projectId

    signal statusChanged(string message)
    signal sdkInit(bool success, var result)
    signal pairResponse(bool success)
    signal sessionProposal(var sessionProposal)
    signal sessionProposalExpired()
    signal buildApprovedNamespacesResult(var session, string error)
    signal approveSessionResult(var approvedNamespaces, string error)
    signal rejectSessionResult(string error)
    signal sessionRequestEvent(var sessionRequest)
    signal sessionRequestUserAnswerResult(string topic, string id, bool accept /* not reject */, string error)

    signal authRequest(var request)
    signal authMessageFormated(string formatedMessage, string address)
    signal authRequestUserAnswerResult(bool accept, string error)

    signal sessionDelete(var topic, string error)

    property var pair: function(pairLink) {
        console.error("pair not implemented")
    }
    property var getPairings: function(callback) {
        console.error("getPairings not implemented")
    }
    property var getActiveSessions: function(callback) {
        console.error("getActiveSessions not implemented")
    }
    property var disconnectSession: function(topic) {
        console.error("disconnectSession not implemented")
    }
    property var disconnectPairing: function(topic) {
        console.error("disconnectPairing not implemented")
    }

    property var ping: function(topic) {
        console.error("ping not implemented")
    }

    property var buildApprovedNamespaces: function(params, supportedNamespaces) {
        console.error("buildApprovedNamespaces not implemented")
    }
    property var approveSession: function(sessionProposal, supportedNamespaces) {
        console.error("approveSession not implemented")
    }

    property var rejectSession: function(id) {
        console.error("rejectSession not implemented")
    }

    property var acceptSessionRequest: function(topic, id, signature) {
        console.error("acceptSessionRequest not implemented")
    }

    property var rejectSessionRequest: function(topic, id, error) {
        console.error("rejectSessionRequest not implemented")
    }
}
