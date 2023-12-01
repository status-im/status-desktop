import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Stub for Controller QObject defined in src/app/modules/main/wallet_section/wallet_connect/controller.nim
Item {
    id: root


    // function sessionProposal(/*string*/ sessionProposalJson)
    required property var sessionProposal
    // function pairSessionRequest(/*string*/ sessionRequestJson)
    required property var recordSuccessfulPairing
    // function deletePairing(/*string*/ topic)
    required property var deletePairing

    signal respondSessionProposal(string sessionProposalJson, string supportedNamespacesJson, string error)
    signal respondSessionRequest(string sessionRequestJson, string signedJson, bool error)
    signal requestOpenWalletConnectPopup(string uri)
    signal respondAuthRequest(string signature, string error)

    // function sessionRequest(/*string*/ sessionRequestJson, /*string*/ password)
    required property var sessionRequest

    required property bool hasActivePairings
    required property string projectId
}