import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import SortFilterProxyModel 0.2

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0

import shared.popups.walletconnect 1.0

import utils 1.0

DappsComboBox {
    id: root

    required property WalletConnectService wcService
    // Values mapped to Constants.LoginType
    required property int loginType
    property string selectedAccountAddress

    signal pairWCReady()

    model: root.wcService.dappsModel

    onPairDapp: {
        pairWCLoader.active = true
    }

    onDisconnectDapp: (dappUrl) => {
        disconnectdAppDialogLoader.dAppUrl = dappUrl
        disconnectdAppDialogLoader.active = true
    }

    Loader {
        id: disconnectdAppDialogLoader

        property string dAppUrl

        active: false

        onLoaded: {
            const dApp = wcService.getDApp(dAppUrl);
            if (dApp) {
                item.dappName = dApp.name;
                item.dappIcon = dApp.iconUrl;
                item.dappUrl = disconnectdAppDialogLoader.dAppUrl;
            }

            item.open();
        }

        sourceComponent: DAppConfirmDisconnectPopup {

            visible: true

            onClosed: {
                disconnectdAppDialogLoader.active = false
            }

            onAccepted: {
                root.wcService.disconnectDapp(dappUrl)
            }
        }
    }

    Loader {
        id: pairWCLoader

        active: false

        onLoaded: {
            item.open()
            root.pairWCReady()
        }

        sourceComponent: PairWCModal {
            visible: true

            onClosed: pairWCLoader.active = false

            onPair: (uri) => {
                this.isPairing = true
                root.wcService.pair(uri)
            }

            onPairUriChanged: (uri) => {
                root.wcService.validatePairingUri(uri)
            }
        }
    }

    Loader {
        id: connectDappLoader

        active: false

        property var dappChains: []
        property var sessionProposal: null
        property var availableNamespaces: null
        property var sessionTopic: null
        readonly property var proposalMedatada: !!sessionProposal
                                                ? sessionProposal.params.proposer.metadata 
                                                : { name: "", url: "", icons: [] }

        sourceComponent: ConnectDAppModal {
            visible: true

            onClosed: connectDappLoader.active = false
            accounts: root.wcService.validAccounts
            flatNetworks: SortFilterProxyModel {
                sourceModel: root.wcService.flatNetworks
                filters: [
                    FastExpressionFilter {
                        inverted: true
                        expression: connectDappLoader.dappChains.indexOf(chainId) === -1
                        expectedRoles: ["chainId"]
                    }
                ]
            }
            selectedAccountAddress: root.selectedAccountAddress

            dAppUrl: proposalMedatada.url
            dAppName: proposalMedatada.name
            dAppIconUrl: !!proposalMedatada.icons && proposalMedatada.icons.length > 0 ? proposalMedatada.icons[0] : ""

            onConnect: {
                root.wcService.approvePairSession(sessionProposal, selectedChains, selectedAccount)
            }

            onDecline: {
                connectDappLoader.active = false
                root.wcService.rejectPairSession(sessionProposal.id)
            }

            onDisconnect: {
                connectDappLoader.active = false
                root.wcService.disconnectSession(sessionTopic)
            }
        }
    }

    Loader {
        id: sessionRequestLoader

        active: false

        onLoaded: item.open()

        property SessionRequestResolved request: null
        property bool requestHandled: false

        sourceComponent: DAppSignRequestModal {
            id: dappRequestModal
            objectName: "dappsRequestModal"
            loginType: request.account.migragedToKeycard ? Constants.LoginType.Keycard : root.loginType
            visible: true

            property var feesInfo: null

            dappUrl: request.dappUrl
            dappIcon: request.dappIcon
            dappName: request.dappName

            accountColor: request.account.color
            accountName: request.account.name
            accountAddress: request.account.address
            accountEmoji: request.account.emoji

            networkName: request.network.chainName
            networkIconPath: Style.svg(request.network.iconUrl)

            currentCurrency: ""
            fiatFees: request.maxFeesText
            cryptoFees: request.maxFeesEthText
            estimatedTime: ""
            feesLoading: !request.maxFeesText || !request.maxFeesEthText
            hasFees: signingTransaction
            enoughFundsForTransaction: request.enoughFunds
            enoughFundsForFees: request.enoughFunds

            signingTransaction: !!request.method && (request.method === SessionRequest.methods.signTransaction.name
                                                  || request.method === SessionRequest.methods.sendTransaction.name)
            requestPayload: request.preparedData
            onClosed: {
                Qt.callLater( () => {
                    rejectRequest()
                    sessionRequestLoader.active = false
                })
            }

            onAccepted: {
                if (!request) {
                    console.error("Error signing: request is null")
                    return
                }

                requestHandled = true
                root.wcService.requestHandler.authenticate(request, JSON.stringify(feesInfo))
            }

            onRejected: {
                rejectRequest()
            }

            function rejectRequest() {
                // Allow rejecting only once
                if (requestHandled) {
                    return
                }
                requestHandled = true
                let userRejected = true
                root.wcService.requestHandler.rejectSessionRequest(request, userRejected)
            }

            Connections {
                target: root.wcService.requestHandler

                function onMaxFeesUpdated(fiatMaxFees, ethMaxFees, haveEnoughFunds, haveEnoughFees, symbol, feesInfo) {
                    dappRequestModal.hasFees = !!ethMaxFees
                    dappRequestModal.feesLoading = !dappRequestModal.hasFees
                    if (!hasFees) {
                        return
                    }
                    dappRequestModal.fiatFees = fiatMaxFees.toString()
                    dappRequestModal.cryptoFees = ethMaxFees.toString()
                    dappRequestModal.currentCurrency = symbol
                    dappRequestModal.enoughFundsForTransaction = haveEnoughFunds
                    dappRequestModal.enoughFundsForFees = haveEnoughFees
                    dappRequestModal.feesInfo = feesInfo
                }

                function onEstimatedTimeUpdated(estimatedTimeEnum) {
                    dappRequestModal.estimatedTime = WalletUtils.getLabelForEstimatedTxTime(estimatedTimeEnum)
                }
            }
        }
    }

    Connections {
        target: root.wcService ? root.wcService.requestHandler : null

        function onSessionRequestResult(request, isSuccess) {
            if (isSuccess) {
                sessionRequestLoader.active = false
            } else {
                // TODO #14762 handle the error case
                let userRejected = false
                root.wcService.requestHandler.rejectSessionRequest(request, userRejected)
            }
        }
    }

    Connections {
        target: root.wcService

        function onPairingValidated(validationState) {
            if (pairWCLoader.item) {
                pairWCLoader.item.pairingValidated(validationState)
            }
        }

        function onConnectDApp(dappChains, sessionProposal, availableNamespaces) {
            connectDappLoader.dappChains = dappChains
            connectDappLoader.sessionProposal = sessionProposal
            connectDappLoader.availableNamespaces = availableNamespaces
            connectDappLoader.sessionTopic = null

            if (pairWCLoader.item) {
                // Allow user to get the uri valid confirmation
                pairWCLoader.item.pairingValidated(Pairing.errors.dappReadyForApproval)
                connectDappTimer.start()
            } else {
                connectDappLoader.active = true
            }
        }

        function onApproveSessionResult(session, err) {
            connectDappLoader.sessionTopic = session.topic

            let modal = connectDappLoader.item
            if (!!modal) {
                if (err) {
                    modal.pairFailed(session, err)
                } else {
                    modal.pairSuccessful(session)
                }
            }
        }

        function onSessionRequest(request) {
            sessionRequestLoader.request = request
            sessionRequestLoader.requestHandled = false
            sessionRequestLoader.active = true
        }
    }

    // Used between transitioning from PairWCModal to ConnectDAppModal
    Timer {
        id: connectDappTimer

        interval: 500
        running: false
        repeat: false

        onTriggered: {
            pairWCLoader.item.close()
            connectDappLoader.active = true
        }
    }
}
