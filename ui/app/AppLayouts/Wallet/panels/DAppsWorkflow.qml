import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.controls 1.0

import shared.popups.walletconnect 1.0
import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0

import shared.stores 1.0
import utils 1.0

ConnectedDappsButton {
    id: root

    required property WalletConnectService wcService

    signal dappsListReady()
    signal pairWCReady()
    signal displayToastMessage(string message, bool error)

    onClicked: {
        dappsListLoader.active = true
    }

    highlighted: dappsListLoader.active

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
                root.wcService.pair(uri)
                this.isPairing = true
            }
        }
    }

    Loader {
        id: dappsListLoader

        active: false

        onLoaded: {
            item.open()
            root.dappsListReady()
        }

        sourceComponent: DAppsListPopup {
            visible: true

            model: root.wcService.dappsModel

            onPairWCDapp: {
                pairWCLoader.active = true
                this.close()
            }

            onOpened: {
                this.x = root.width - this.contentWidth - 2 * this.padding
                this.y = root.height + 4
            }
            onClosed: dappsListLoader.active = false
        }
    }

    Loader {
        id: connectDappLoader

        active: false

        onLoaded: item.openWithFilter(dappChains, sessionProposal.params.proposer)

        property var dappChains: []
        property var sessionProposal: null
        property var availableNamespaces: null
        property var sessionTopic: null

        sourceComponent: ConnectDAppModal {
            visible: true

            onClosed: connectDappLoader.active = false
            accounts: root.wcService.validAccounts
            flatNetworks: root.wcService.flatNetworks

            onConnect: {
                root.wcService.approvePairSession(sessionProposal, selectedChains, selectedAccount)
            }

            onDecline: {
                connectDappLoader.active = false
                root.wcService.rejectPairSession(sessionProposal.id)
            }

            onDisconnect: {
                connectDappLoader.active = false
                root.wcService.disconnectDapp(sessionTopic)
            }
        }
    }

    Loader {
        id: sessionRequestLoader

        active: false

        onLoaded: item.open()

        property SessionRequestResolved request: null

        sourceComponent: DAppRequestModal {
            account: request.account
            network: request.network

            dappName: request.dappName
            dappUrl: request.dappUrl
            dappIcon: request.dappIcon

            signContent: request.data.message
            method: request.method
            maxFeesText: request.maxFeesText
            estimatedTimeText: request.estimatedTimeText

            visible: true

            onClosed: sessionRequestLoader.active = false

            onSign: {
                if (!request) {
                    console.error("Error signing: request is null")
                    return
                }
                root.wcService.requestHandler.authenticate(request)
            }

            onReject: {
                let userRejected = true
                root.wcService.requestHandler.rejectSessionRequest(request, userRejected)
                close()
            }
        }
    }

    Connections {
        target: root.wcService ? root.wcService.requestHandler : null

        function onSessionRequestResult(request, payload, isSuccess) {
            if (isSuccess) {
                sessionRequestLoader.active = false
            } else {
                // TODO #14762 handle the error case
            }
        }
    }

    Connections {
        target: root.wcService

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
            connectDappLoader.dappChains = []
            connectDappLoader.sessionProposal = null
            connectDappLoader.availableNamespaces = null
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

        function onDisplayToastMessage(message, err) {
            root.displayToastMessage(message, err)
        }
    }
}
