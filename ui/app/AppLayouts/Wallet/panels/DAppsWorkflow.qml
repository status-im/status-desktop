import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
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
        root.wcService.disconnectDapp(dappUrl)
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

        sourceComponent: DAppSignRequestModal {
            id: dappRequestModal
            objectName: "dappsRequestModal"
            loginType: request.account.migragedToKeycard ? Constants.LoginType.Keycard : root.loginType
            visible: true

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

            signingTransaction: request.method === SessionRequest.methods.signTransaction.name || request.method === SessionRequest.methods.sendTransaction.name
            requestPayload: {
                switch(request.method) {
                    case SessionRequest.methods.personalSign.name:
                        return SessionRequest.methods.personalSign.getMessageFromData(request.data)
                    case SessionRequest.methods.sign.name: {
                        return SessionRequest.methods.sign.getMessageFromData(request.data)
                    }
                    case SessionRequest.methods.signTypedData_v4.name: {
                        const stringPayload = SessionRequest.methods.signTypedData_v4.getMessageFromData(request.data)
                        return JSON.stringify(JSON.parse(stringPayload), null, 2)
                    }
                    case SessionRequest.methods.signTypedData.name: {
                        const stringPayload = SessionRequest.methods.signTypedData.getMessageFromData(root.payloadData)
                        return JSON.stringify(JSON.parse(stringPayload), null, 2)
                    }
                    case SessionRequest.methods.signTransaction.name: {
                        const jsonPayload = SessionRequest.methods.signTransaction.getTxObjFromData(request.data)
                        return JSON.stringify(jsonPayload, null, 2)
                    }
                    case SessionRequest.methods.sendTransaction.name: {
                        const jsonPayload = SessionRequest.methods.sendTransaction.getTxObjFromData(request.data)
                        return JSON.stringify(jsonPayload, null, 2)
                    }
                }
            }

            onClosed: Qt.callLater( () => sessionRequestLoader.active = false)

            onAccepted: {
                if (!request) {
                    console.error("Error signing: request is null")
                    return
                }
                root.wcService.requestHandler.authenticate(request)
            }

            onRejected: {
                let userRejected = true
                root.wcService.requestHandler.rejectSessionRequest(request, userRejected)
            }

            Connections {
                target: root.wcService.requestHandler

                function onMaxFeesUpdated(maxFees, maxFeesWei, haveEnoughFunds, symbol) {
                    fiatFees = maxFees
                    currentCurrency = symbol

                    var ethStr = "?"
                    try {
                        ethStr = globalUtils.wei2Eth(maxFeesWei, 9)
                    } catch (e) {
                        // ignore error in case of tests and storybook where we don't have access to globalUtils
                    }

                    cryptoFees = ethStr
                    enoughFundsForTransaction = haveEnoughFunds
                    enoughFundsForFees = haveEnoughFunds
                    feesLoading = false
                    hasFees = !!maxFees
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
                pairWCLoader.item.close()
            }

            connectDappLoader.active = true
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
            sessionRequestLoader.active = true
        }
    }
}
