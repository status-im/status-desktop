import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

Item {
    id: root

    implicitWidth: Math.min(mainLayout.implicitWidth, 400)
    implicitHeight: Math.min(mainLayout.implicitHeight, 700)

    required property color backgroundColor

    property bool sdkReady: state === d.sdkReadyState

    // wallet_connect.Controller \see wallet_section/wallet_connect/controller.nim
    required property var controller

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        StatusBaseText {
            text: qsTr("Debugging UX until design is ready")
        }

        StatusInput {
            id: pairLinkInput

            Layout.fillWidth: true

            placeholderText: "Insert pair link"
        }

        RowLayout {
            Layout.fillWidth: true

            StatusButton {
                text: "Pair"
                onClicked: {
                    statusText.text = "Pairing..."
                    sdkView.pair(pairLinkInput.text)
                }
                enabled: pairLinkInput.text.length > 0 && sdkView.sdkReady
            }

            StatusButton {
                text: "Auth"
                onClicked: {
                    statusText.text = "Authenticating..."
                    sdkView.auth()
                }
                enabled: false && pairLinkInput.text.length > 0 && sdkView.sdkReady
            }

            StatusButton {
                text: "Accept"
                onClicked: {
                    sdkView.approvePairSession(d.sessionProposal, d.supportedNamespaces)
                }
                visible: root.state === d.waitingPairState
            }
            StatusButton {
                text: "Reject"
                onClicked: {
                    sdkView.rejectPairSession(d.sessionProposal.id)
                }
                visible: root.state === d.waitingPairState
            }
        }

        ColumnLayout {
            StatusBaseText {
                id: statusText
                text: "-"
            }
            StatusBaseText {
                text: "Pairings"
                visible: sdkView.pairingsModel.count > 0
            }
            StatusListView {
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.maximumHeight: 200

                model: sdkView.pairingsModel

                delegate: StatusBaseText {
                    text: `${SQUtils.Utils.elideText(topic, 6, 6)} - ${new Date(expiry * 1000).toLocaleString()}`
                    color: active ? "green" : "orange"
                }
            }
            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                Layout.maximumHeight: 400

                contentWidth: detailsText.width
                contentHeight: detailsText.height

                StatusBaseText {
                    id: detailsText
                    text: ""
                    visible: text.length > 0

                    color: "#FF00FF"
                }

                ScrollBar.vertical: ScrollBar {}

                clip: true
            }

            RowLayout {
                StatusButton {
                    text: "Accept"
                    onClicked: {
                        root.controller.sessionRequest(JSON.stringify(d.sessionRequest), passwordInput.text)
                    }
                    visible: root.state === d.waitingUserResponseToSessionRequest
                }
                StatusButton {
                    text: "Reject"
                    onClicked: {
                        sdkView.rejectSessionRequest(d.sessionRequest.topic, d.sessionRequest.id, false)
                    }
                    visible: root.state === d.waitingUserResponseToSessionRequest
                }
                StatusInput {
                    id: passwordInput

                    text: "1234567890"
                    placeholderText: "Insert account password"
                    visible: root.state === d.waitingUserResponseToSessionRequest
                }
            }

            ColumnLayout { /* spacer */ }
        }

        // Separator
        ColumnLayout {}
    }

    WalletConnectSDK {
        id: sdkView

        // SDK runs fine if WebEngineView is not visible
        visible: false
        anchors.top: parent.bottom
        anchors.left: parent.left
        width: 100
        height: 100

        projectId: controller.projectId

        onSdkInit: function(success, info) {
            d.setDetailsText(info)
            if (success) {
                d.setStatusText("Ready to pair or auth")
                root.state = d.sdkReadyState
            } else {
                d.setStatusText("SDK Error", "red")
                root.state = ""
            }
        }

        onPairSessionProposal: function(success, sessionProposal) {
            d.setDetailsText(sessionProposal)
            if (success) {
                d.setStatusText("Pair ID: " + sessionProposal.id + "; Topic: " + sessionProposal.params.pairingTopic)
                root.controller.pairSessionProposal(JSON.stringify(sessionProposal))
                // Expecting signal onProposeUserPair from controller
            } else {
                d.setStatusText("Pairing error", "red")
            }
        }

        onPairAcceptedResult: function(success, result) {
            d.setDetailsText(result)
            if (success) {
                d.setStatusText("Pairing OK")
                root.state = d.pairedState
            } else {
                d.setStatusText("Pairing error", "red")
                root.state = d.sdkReadyState
            }
        }

        onPairRejectedResult: function(success, result) {
            d.setDetailsText(result)
            root.state = d.sdkReadyState
            if (success) {
                d.setStatusText("Pairing rejected")
            } else {
                d.setStatusText("Rejecting pairing error", "red")
            }
        }

        onSessionRequestUserAnswerResult: function(accept, error) {
            if (error) {
                d.setStatusText(`Session Request ${accept ? "Accept" : "Reject"} error`, "red")
                return
            }
            root.state = d.pairedState
            if (accept) {
                d.setStatusText(`Session Request accepted`)
            } else {
                d.setStatusText(`Session Request rejected`)
            }
        }

        onSessionRequestEvent: function(sessionRequest) {
            d.setStatusText("Approve session request")
            d.setDetailsText(JSON.stringify(sessionRequest, null, 2))
            d.sessionRequest = sessionRequest
            root.state = d.waitingUserResponseToSessionRequest
        }

        onPairSessionProposalExpired: {
            d.setStatusText(`Timeout waiting for response. Reusing URI?`, "red")
        }

        onStatusChanged: function(message) {
            statusText.text = message
        }
    }

    QtObject {
        id: d

        property var sessionProposal: null
        property var supportedNamespaces: null

        property var sessionRequest: null
        property var signedData: null

        readonly property string sdkReadyState: "sdk_ready"
        readonly property string waitingPairState: "waiting_pairing"
        readonly property string waitingUserResponseToSessionRequest: "waiting_user_response_to_session_request"
        readonly property string pairedState: "paired"

        function setStatusText(message, textColor) {
            statusText.text = message
            if (textColor === undefined) {
                textColor = "green"
            }
            statusText.color = textColor
        }
        function setDetailsText(message) {
            if (message === undefined) {
                message = "undefined"
            } else if (typeof message !== "string") {
                message = JSON.stringify(message, null, 2)
            }
            detailsText.text = message
        }
    }

    Connections {
        target: root.controller

        function onProposeUserPair(sessionProposalJson, supportedNamespacesJson) {
            d.setStatusText("Waiting user accept")

            d.sessionProposal = JSON.parse(sessionProposalJson)
            d.supportedNamespaces = JSON.parse(supportedNamespacesJson)

            d.setDetailsText(JSON.stringify(d.supportedNamespaces, null, 2))

            root.state = d.waitingPairState
        }

        function onRespondSessionRequest(sessionRequestJson, signedData, error) {
            console.log("@dd respondSessionRequest", sessionRequestJson, "  signedData", signedData, "  error: ", error)
            if (error) {
                d.setStatusText("Session Request error", "red")
                sdkView.rejectSessionRequest(d.sessionRequest.topic, d.sessionRequest.id, true)
                return
            }

            d.sessionRequest = JSON.parse(sessionRequestJson)
            d.signedData = signedData

            sdkView.acceptSessionRequest(d.sessionRequest.topic, d.sessionRequest.id, d.signedData)

            d.setStatusText("Session Request accepted")
            d.setDetailsText(d.signedData)
        }
    }
}
