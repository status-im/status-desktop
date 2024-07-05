import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0
import AppLayouts.Profile.stores 1.0
import shared.stores 1.0
import shared.popups.walletconnect 1.0

import SortFilterProxyModel 0.2
import utils 1.0

import "types"

QObject {
    id: root

    required property WalletConnectSDKBase wcSDK
    required property DAppsStore store
    required property WalletStores.RootStore walletRootStore

    readonly property string selectedAccountAddress: walletRootStore.selectedAddress

    readonly property alias dappsModel: dappsProvider.dappsModel
    readonly property alias requestHandler: requestHandler

    readonly property var validAccounts: SortFilterProxyModel {
        sourceModel: root.walletRootStore.nonWatchAccounts
        proxyRoles: [
            FastExpressionRole {
                name: "colorizedChainPrefixes"
                function getChainShortNames(chainIds) {
                    const chainShortNames = root.walletRootStore.getNetworkShortNames(chainIds)
                    return WalletUtils.colorizedChainPrefix(chainShortNames)
                }
                expression: getChainShortNames(model.preferredSharingChainIds)
                expectedRoles: ["preferredSharingChainIds"]
            }
        ]
    }
    readonly property var flatNetworks: root.walletRootStore.filteredFlatModel

    function validatePairingUri(uri) {
        if(Helpers.containsOnlyEmoji(uri)) {
            root.pairingUriValidated(Pairing.uriErrors.tooCool)
            return
        } else if(!Helpers.validURI(uri)) {
            root.pairingUriValidated(Pairing.uriErrors.invalidUri)
            return
        }

        let info = Helpers.extractInfoFromPairUri(uri)
        wcSDK.getActiveSessions((sessions) => {
            // Check if the URI is already paired
            var validationState = Pairing.uriErrors.ok
            for (let key in sessions) {
                if (sessions[key].pairingTopic == info.topic) {
                    validationState = Pairing.uriErrors.alreadyUsed
                    break
                }
            }

            // Check if expired
            if (validationState == Pairing.uriErrors.ok) {
                const now = (new Date().getTime())/1000
                if (info.expiry < now) {
                    validationState = Pairing.uriErrors.expired
                }
            }

            root.pairingUriValidated(validationState)
        });
    }

    function pair(uri) {
        d.acceptedSessionProposal = null
        wcSDK.pair(uri)
    }

    function approvePairSession(sessionProposal, approvedChainIds, approvedAccount) {
        d.acceptedSessionProposal = sessionProposal
        let approvedNamespaces = JSON.parse(
            Helpers.buildSupportedNamespaces(approvedChainIds,
                                             [approvedAccount.address],
                                             SessionRequest.getSupportedMethods())
        )
        wcSDK.buildApprovedNamespaces(sessionProposal.params, approvedNamespaces)
    }

    function rejectPairSession(id) {
        wcSDK.rejectSession(id)
    }

    function disconnectSession(sessionTopic) {
        wcSDK.disconnectSession(sessionTopic)
    }

    function disconnectDapp(url) {
        wcSDK.getActiveSessions((sessions) => {
            for (let key in sessions) {
                let dapp = sessions[key].peer.metadata
                let topic = sessions[key].topic
                if (dapp.url == url) {
                    wcSDK.disconnectSession(topic)
                }
            }
        });
    }

    signal connectDApp(var dappChains, var sessionProposal, var approvedNamespaces)
    signal approveSessionResult(var session, var error)
    signal sessionRequest(SessionRequestResolved request)
    signal displayToastMessage(string message, bool error)
    signal pairingUriValidated(int validationState)

    readonly property Connections sdkConnections: Connections {
        target: wcSDK

        function onSessionProposal(sessionProposal) {
            d.currentSessionProposal = sessionProposal

            let supportedNamespacesStr = Helpers.buildSupportedNamespacesFromModels(
                root.flatNetworks, root.validAccounts, SessionRequest.getSupportedMethods())
            wcSDK.buildApprovedNamespaces(sessionProposal.params, JSON.parse(supportedNamespacesStr))
        }

        function onBuildApprovedNamespacesResult(approvedNamespaces, error) {
            if(error) {
                // TODO: error reporting
                return
            }

            if (d.acceptedSessionProposal) {
                wcSDK.approveSession(d.acceptedSessionProposal, approvedNamespaces)
            } else {
                let res = Helpers.extractChainsAndAccountsFromApprovedNamespaces(approvedNamespaces)

                root.connectDApp(res.chains, d.currentSessionProposal, approvedNamespaces)
            }
        }

        function onApproveSessionResult(session, err) {
            if (err) {
                // TODO #14676: handle the error
                console.error("Failed to approve session", err)
                return
            }

            // TODO #14754: implement custom dApp notification
            const app_url = d.currentSessionProposal ? d.currentSessionProposal.params.proposer.metadata.url : "-"
            const app_domain = StringUtils.extractDomainFromLink(app_url)
            root.displayToastMessage(qsTr("Connected to %1 via WalletConnect").arg(app_domain), false)

            // Persist session
            if(!store.addWalletConnectSession(JSON.stringify(session))) {
                console.error("Failed to persist session")
            }

            // Notify client
            root.approveSessionResult(session, err)

            dappsProvider.updateDapps()
        }

        function onRejectSessionResult(err) {
            const app_url = d.currentSessionProposal ? d.currentSessionProposal.params.proposer.metadata.url : "-"
            const app_domain = StringUtils.extractDomainFromLink(app_url)
            if(err) {
                root.displayToastMessage(qsTr("Failed to reject connection request for %1").arg(app_domain), true)
            } else {
                root.displayToastMessage(qsTr("Connection request for %1 was rejected").arg(app_domain), false)
            }
        }

        function onSessionDelete(topic, err) {
            store.deactivateWalletConnectSession(topic)
            dappsProvider.updateDapps()

            const app_url = d.currentSessionProposal ? d.currentSessionProposal.params.proposer.metadata.url : "-"
            const app_domain = StringUtils.extractDomainFromLink(app_url)
            if(err) {
                root.displayToastMessage(qsTr("Failed to disconnect from %1").arg(app_domain), true)
            } else {
                root.displayToastMessage(qsTr("Disconnected from %1").arg(app_domain), false)
            }
        }
    }

    QObject {
        id: d

        property var currentSessionProposal: null
        property var acceptedSessionProposal: null

        // TODO #14676: use it to check if already paired
        function getPairingTopicFromPairingUrl(url)
        {
            if (!url.startsWith("wc:"))
            {
                return null;
            }

            const atIndex = url.indexOf("@");
            if (atIndex < 0)
            {
                return null;
            }

            return url.slice(3, atIndex);
        }
    }

    Component.onCompleted: {
        dappsProvider.updateDapps()
    }

    DAppsRequestHandler {
        id: requestHandler

        sdk: root.wcSDK
        store: root.store
        accountsModel: root.validAccounts
        networksModel: root.flatNetworks

        onSessionRequest: (request) => {
            root.sessionRequest(request)
        }
        onDisplayToastMessage: (message, error) => {
            root.displayToastMessage(message, error)
        }
    }

    DAppsListProvider {
        id: dappsProvider

        sdk: root.wcSDK
        store: root.store
    }
}