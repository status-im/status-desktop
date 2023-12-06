import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Popups 0.1

Popup {
    id: root

    implicitWidth: 500
    implicitHeight: Math.min(mainLayout.implicitHeight * 2, 700)

    required property WalletConnectSDK sdk

    parent: Overlay.overlay
    anchors.centerIn: parent

    clip: true

    property bool sdkReady: d.state === d.sdkReadyState

    // wallet_connect.Controller \see wallet_section/wallet_connect/controller.nim
    required property var controller

    function openWithSessionRequestEvent(sessionRequest) {
        d.setStatusText("Approve session request")
        d.setDetailsText(JSON.stringify(sessionRequest, null, 2))
        d.sessionRequest = sessionRequest
        d.state = d.waitingUserResponseToSessionRequest
        root.open()
    }

    Flickable {
        id: flickable

        anchors.fill: parent

        contentWidth: mainLayout.implicitWidth
        contentHeight: mainLayout.implicitHeight

        interactive: contentHeight > height || contentWidth > width

        ColumnLayout {
            id: mainLayout

            StatusBaseText {
                text: qsTr("Debugging UX until design is ready")
            }

            StatusSwitch {
                id: testAuthentication
                checkable: true
                text: qsTr("Test Authentication")
            }

            StatusInput {
                id: pairLinkInput

                Layout.fillWidth: true

                placeholderText: "Insert pair link"
            }

            RowLayout {
                Layout.fillWidth: true

                StatusButton {
                    text: testAuthentication.checked? "Authentication" : "Pair"

                    onClicked: {
                        if (testAuthentication.checked) {
                            d.setStatusText("")
                            d.setDetailsText("")
                            d.state = ""
                            accountsModel.clear()

                            statusText.text = "Authenticating..."
                            root.sdk.auth(pairLinkInput.text)
                            return
                        }

                        statusText.text = "Pairing..."
                        root.sdk.pair(pairLinkInput.text)
                    }
                    enabled: pairLinkInput.text.length > 0 && root.sdk.sdkReady
                }

                StatusButton {
                    text: "Accept"
                    onClicked: {
                        root.sdk.approvePairSession(d.observedData, d.supportedNamespaces)
                    }
                    visible: d.state === d.waitingPairState
                }
                StatusButton {
                    text: "Reject"
                    onClicked: {
                        root.sdk.rejectPairSession(d.observedData.id)
                    }
                    visible: d.state === d.waitingPairState
                }
            }

            ColumnLayout {
                StatusBaseText {
                    id: statusText
                    text: "-"
                }
                StatusBaseText {
                    text: "Pairings"
                    visible: root.sdk.pairingsModel.count > 0
                }

                Pairings {
                    Layout.fillWidth: true
                    Layout.minimumWidth: count > 0 ? 400 : 0
                    Layout.preferredHeight: contentHeight
                    Layout.maximumHeight: 300

                    model: root.sdk.pairingsModel

                    onDisconnect: function (topic) {
                        root.sdk.disconnectPairing(topic)
                    }
                }

                ButtonGroup {
                    id: selAccBtnGroup
                }

                SelectAccount {
                    Layout.fillWidth: true
                    Layout.minimumWidth: count > 0 ? 400 : 0
                    Layout.preferredHeight: contentHeight
                    Layout.maximumHeight: 300

                    model: accountsModel

                    buttonGroup: selAccBtnGroup

                    onAccountSelected: {
                        root.sdk.formatAuthMessage(d.observedData.params.cacaoPayload, address)
                    }
                }

                StatusBaseText {
                    id: detailsText
                    text: ""
                    visible: text.length > 0

                    color: "#FF00FF"
                }

                RowLayout {
                    StatusButton {
                        text: "Accept"
                        onClicked: {
                            if (testAuthentication.checked) {
                                root.controller.authRequest(d.selectedAddress, d.authMessage, passwordInput.text)
                                return
                            }

                            root.controller.sessionRequest(JSON.stringify(d.sessionRequest), passwordInput.text)
                        }
                        visible: d.state === d.waitingUserResponseToSessionRequest ||
                                 d.state === d.waitingUserResponseToAuthRequest
                    }
                    StatusButton {
                        text: "Reject"
                        onClicked: {
                            if (testAuthentication.checked) {
                                root.sdk.authReject(d.observedData.id, d.selectedAddress)
                                return
                            }

                            root.sdk.rejectSessionRequest(d.sessionRequest.topic, d.sessionRequest.id, false)
                        }
                        visible: d.state === d.waitingUserResponseToSessionRequest ||
                                 d.state === d.waitingUserResponseToAuthRequest
                    }
                    StatusInput {
                        id: passwordInput

                        text: "1234567890"
                        placeholderText: "Insert account password"
                        visible: d.state === d.waitingUserResponseToSessionRequest ||
                                 d.state === d.waitingUserResponseToAuthRequest
                    }
                }

                ColumnLayout { /* spacer */ }
            }

            // Separator
            ColumnLayout {}
        }

        ScrollBar.vertical: ScrollBar {}

        clip: true
    }

    Connections {
        target: root.sdk

        function onSdkInit(success, info) {
            d.setDetailsText(info)
            if (success) {
                d.setStatusText("Ready to pair or auth")
                d.state = d.sdkReadyState
            } else {
                d.setStatusText("SDK Error", "red")
                d.state = ""
            }
        }

        function onPairSessionProposal(sessionProposal) {
            d.setDetailsText(sessionProposal)
            d.setStatusText("Pair ID: " + sessionProposal.id + "; Topic: " + sessionProposal.params.pairingTopic)
            root.controller.pairSessionProposal(JSON.stringify(sessionProposal))
        }

        function onPairAcceptedResult(sessionProposal, success, result) {
            d.setDetailsText(result)
            if (success) {
                d.setStatusText("Pairing OK")
                d.state = d.pairedState
                root.controller.recordSuccessfulPairing(JSON.stringify(sessionProposal))
            } else {
                d.setStatusText("Pairing error", "red")
                d.state = d.sdkReadyState
            }
        }

        function onPairRejectedResult(success, result) {
            d.setDetailsText(result)
            d.state = d.sdkReadyState
            if (success) {
                d.setStatusText("Pairing rejected")
            } else {
                d.setStatusText("Rejecting pairing error", "red")
            }
        }

        function onSessionRequestUserAnswerResult(accept, error) {
            if (error) {
                d.setStatusText(`Session Request ${accept ? "Accept" : "Reject"} error`, "red")
                return
            }
            d.state = d.pairedState
            if (accept) {
                d.setStatusText(`Session Request accepted`)
            } else {
                d.setStatusText(`Session Request rejected`)
            }
        }

        function onPairSessionProposalExpired() {
            d.setStatusText(`Timeout waiting for response. Reusing URI?`, "red")
        }

        function onStatusChanged(message) {
            statusText.text = message
        }

        function onAuthRequest(request) {
            d.observedData = request
            d.setStatusText("Select the address you want to sign in with:")

            accountsModel.clear()

            let walletAccounts = root.controller.getWalletAccounts()
            try {
                let walletAccountsJsonArr = JSON.parse(walletAccounts)

                for (let i = 0; i < walletAccountsJsonArr.length; i++) {
                    let obj = {
                        preferredSharingChainIds: ""
                    }

                    for (var key in walletAccountsJsonArr[i]) {
                        obj[key] = walletAccountsJsonArr[i][key]
                    }

                    accountsModel.append(obj)
                }

            } catch (e) {
                console.error("error parsing wallet accounts, error: ", e)
                d.setStatusText("error parsing walelt accounts", "red")
                return
            }
        }

        function onAuthSignMessage(message, address) {
            let details = ""
            if (!!d.observedData.verifyContext.verified.isScam) {
                details = "This website you`re trying to connect is flagged as malicious by multiple security providers.\nApproving may lead to loss of funds."
            } else {
                if (d.observedData.verifyContext.verified.validation === "UNKNOWN")
                    details = "Website is Unverified"
                else if (d.observedData.verifyContext.verified.validation === "INVALID")
                    details = "Website is Mismatched"
                else
                    details = "Website is Valid"
            }

            d.selectedAddress = address
            d.authMessage = message
            d.setDetailsText(`${details}\n\n${message}`)
            d.state = d.waitingUserResponseToAuthRequest
        }

        function onAuthRequestUserAnswerResult(accept, error) {
            if (error) {
                d.setStatusText(`Auth Request ${accept ? "Accept" : "Reject"} error`, "red")
                return
            }

            if (accept) {
                d.setStatusText(`Auth Request completed`)
            } else {
                d.setStatusText(`Auth Request aborted`)
            }
        }
    }

    QtObject {
        id: d

        property string selectedAddress: ""
        property var observedData: null
        property var authMessage: null
        property var supportedNamespaces: null

        property var sessionRequest: null
        property var signedData: null

        property string state: ""
        readonly property string sdkReadyState: "sdk_ready"
        readonly property string waitingPairState: "waiting_pairing"
        readonly property string waitingUserResponseToSessionRequest: "waiting_user_response_to_session_request"
        readonly property string waitingUserResponseToAuthRequest: "waiting_user_response_to_auth_request"
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

    ListModel {
        id: accountsModel
    }

    Connections {
        target: root.controller

        function onProposeUserPair(sessionProposalJson, supportedNamespacesJson) {
            d.setStatusText("Waiting user accept")

            d.observedData = JSON.parse(sessionProposalJson)
            d.supportedNamespaces = JSON.parse(supportedNamespacesJson)

            d.setDetailsText(JSON.stringify(d.supportedNamespaces, null, 2))

            d.state = d.waitingPairState
        }

        function onRespondSessionRequest(sessionRequestJson, signedData, error) {
            console.log("WC respondSessionRequest", sessionRequestJson, "  signedData", signedData, "  error: ", error)
            if (error) {
                d.setStatusText("Session Request error", "red")
                root.sdk.rejectSessionRequest(d.sessionRequest.topic, d.sessionRequest.id, true)
                return
            }

            d.sessionRequest = JSON.parse(sessionRequestJson)
            d.signedData = signedData

            root.sdk.acceptSessionRequest(d.sessionRequest.topic, d.sessionRequest.id, d.signedData)

            d.state = d.pairedState

            d.setStatusText("Session Request accepted")
            d.setDetailsText(d.signedData)
        }

        function onRespondAuthRequest(signature, error) {
            console.log("WC signature", signature, "  error: ", error)
            if (error) {
                d.setStatusText("Session Request error", "red")
                root.sdk.authReject(d.observedData.id, d.selectedAddress)
                return
            }

            root.sdk.authApprove(d.observedData, d.selectedAddress, signature)
        }
    }
}
