import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Stub for Controller QObject defined in src/app/modules/main/wallet_section/wallet_connect/controller.nim
Item {
    id: root

    signal proposeUserPair(string sessionProposalJson, string supportedNamespacesJson)

    // function pairSessionProposal(/*string*/ sessionProposalJson)
    required property var pairSessionProposal
    // function pairSessionRequest(/*string*/ sessionRequestJson)
    required property var recordSuccessfulPairing
    // function deletePairing(/*string*/ topic)
    required property var deletePairing

    signal respondSessionRequest(string sessionRequestJson, string signedJson, bool error)

    // function sessionRequest(/*string*/ sessionRequestJson, /*string*/ password)
    required property var sessionRequest


    required property bool hasActivePairings
    required property string projectId
}