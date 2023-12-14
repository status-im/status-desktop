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

    // wallet_connect.Controller \see wallet_section/wallet_connect/controller.nim
    required property var controller

    function openWithSessionRequestEvent(sessionRequest) {
        d.setStatusText("Approve session request")
        d.setDetailsText(JSON.stringify(sessionRequest, null, 2))
        d.sessionRequest = sessionRequest
        d.state = d.waitingUserResponseToSessionRequest
        root.open()
    }

    function openWithUri(uri) {
        pairLinkInput.text = uri

        root.open()

        if (root.sdk.sdkReady) {
            d.setStatusText("Pairing from deeplink ...")
            sdk.pair(uri)
        } else {
            d.pairModalUriWhenReady = uri
        }
    }

    Flickable {
        id: flickable

        anchors.fill: parent

        contentWidth: mainLayout.implicitWidth
        contentHeight: mainLayout.implicitHeight

        interactive: contentHeight > height || contentWidth > width

        ColumnLayout {
            id: mainLayout

            spacing: 8

            StatusBaseText {
                text: qsTr("Debugging UX until design is ready")
                font.bold: true
            }

            StatusTabBar {
                id: tabBar
                Layout.fillWidth: true

                StatusTabButton {
                    width: implicitWidth
                    text: qsTr("WalletConnect")
                }

                StatusTabButton {
                    width: implicitWidth
                    text: qsTr("Sessions")
                }

                StatusTabButton {
                    width: implicitWidth
                    text: qsTr("Pairings")
                }
            }

            StackLayout {
                Layout.fillWidth: true
                currentIndex: tabBar.currentIndex

                ColumnLayout {

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
                                d.setStatusText("")
                                d.setDetailsText("")
                                d.state = ""
                                accountsModel.clear()

                                if (testAuthentication.checked) {
                                    d.setStatusText("Authenticating...")
                                    root.sdk.auth(pairLinkInput.text)
                                    return
                                }

                                d.setStatusText("Pairing...")
                                root.sdk.pair(pairLinkInput.text)
                            }
                            enabled: pairLinkInput.text.length > 0 && root.sdk.sdkReady
                        }

                        StatusButton {
                            text: "Accept"
                            onClicked: {
                                root.sdk.approveSession(d.observedData, d.supportedNamespaces)
                            }
                            visible: d.state === d.waitingPairState
                        }
                        StatusButton {
                            text: "Reject"
                            onClicked: {
                                root.sdk.rejectSession(d.observedData.id)
                            }
                            visible: d.state === d.waitingPairState
                        }
                    }

                    ButtonGroup {
                        id: selAccBtnGroup
                    }

                    SelectAccount {
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        model: accountsModel

                        buttonGroup: selAccBtnGroup

                        onAccountSelected: {
                            root.sdk.formatAuthMessage(d.observedData.params.cacaoPayload, address)
                        }
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
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Sessions {
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        model: root.sdk.sessionsModel

                        onDisconnect: function (topic) {
                            root.sdk.disconnectSession(topic)
                        }

                        onPing: function (topic) {
                            root.sdk.ping(topic)
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Pairings {
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        model: root.sdk.pairingsModel

                        onDisconnect: function (topic) {
                            root.sdk.disconnectPairing(topic)
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
            }

            ColumnLayout {
                StatusBaseText {
                    text: qsTr("Tracking details...")
                    font.bold: true
                }

                StatusBaseText {
                    id: statusText
                    text: "-"
                    font.bold: true
                }

                StatusBaseText {
                    id: detailsText
                    text: ""
                    visible: text.length > 0

                    color: "#FF00FF"
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}

        clip: true
    }

    Connections {
        target: root.sdk

        function onSdkReadyChanged() {
            if (root.sdk.sdkReady && d.pairModalUriWhenReady) {
                d.setStatusText("Lazy pairing from deeplink ...")
                sdk.pair(d.pairModalUriWhenReady)
                d.pairModalUriWhenReady = ""
            }

            d.checkForPairings()
        }

        function onSdkInit(success, info) {
            d.setDetailsText(info)
            if (success) {
                d.setStatusText("Ready to pair or auth")
            } else {
                d.setStatusText("SDK Error", "red")
            }
            d.state = ""
        }

        function onSessionProposal(sessionProposal) {
            d.setDetailsText(sessionProposal)
            d.setStatusText("Pair ID: " + sessionProposal.id + "; Topic: " + sessionProposal.params.pairingTopic)
            root.controller.sessionProposal(JSON.stringify(sessionProposal))
        }

        function onSessionDelete(topic, error) {
            if (!!error) {
                d.setStatusText(`Error deleting session: ${error}`, "red")
                d.setDetailsText("")
                return
            }

            root.controller.deleteSession(topic)
        }

        function onSessionRequestEvent(sessionRequest) {
            d.setStatusText("Approve session request")
            d.setDetailsText(JSON.stringify(sessionRequest, null, 2))
            d.sessionRequest = sessionRequest
            root.state = d.waitingUserResponseToSessionRequest
        }

        function onApproveSessionResult(session, error) {
            d.setDetailsText("")
            if (!error) {
                d.setStatusText("Pairing OK")
                d.state = d.pairedState

                root.sdk.getActiveSessions((activeSession) => {
                                               root.controller.saveOrUpdateSession(JSON.stringify(session))
                                           })
            } else {
                d.setStatusText("Pairing error", "red")
                d.state = ""
            }
        }

        function onRejectSessionResult(error) {
            d.setDetailsText("")
            d.state = ""
            if (!error) {
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

        function onSessionProposalExpired() {
            d.setStatusText(`Timeout waiting for response. Reusing URI?`, "red")
        }

        function onStatusChanged(message) {
            d.setStatusText(message)
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

        function onAuthMessageFormated(formatedMessage, address) {
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
            d.authMessage = formatedMessage
            d.setDetailsText(`${details}\n\n${formatedMessage}`)
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

        property bool checkPairings: false
        property string selectedAddress: ""
        property var observedData: null
        property var authMessage: null
        property var supportedNamespaces: null

        property var sessionRequest: null
        property var signedData: null

        property string pairModalUriWhenReady: ""

        property string state: ""
        readonly property string waitingPairState: "waiting_pairing"
        readonly property string waitingUserResponseToSessionRequest: "waiting_user_response_to_session_request"
        readonly property string waitingUserResponseToAuthRequest: "waiting_user_response_to_auth_request"
        readonly property string pairedState: "paired"

        function checkForPairings() {
            if (!d.checkPairings || !root.sdk.sdkReady) {
                return
            }

            d.checkPairings = false;
            root.sdk.getPairings((pairings) => {
                                    for (let i = 0; i < pairings.length; i++) {
                                        if (pairings[i].active) {
                                            // if there is at least a single active pairing we leave wallet connect sdk loaded
                                            return;
                                        }
                                    }
                                    // if there are no active pairings, we unload loaded sdk
                                    root.controller.hasActivePairings = false;
                                 })
        }

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

        function onRespondSessionProposal(sessionProposalJson, supportedNamespacesJson, error) {
            if (error) {
                d.setStatusText(`Error: ${error}`, "red")
                d.setDetailsText("")
                return
            }
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

        function onCheckPairings() {
            d.checkPairings = true
            d.checkForPairings()
        }
    }
}
