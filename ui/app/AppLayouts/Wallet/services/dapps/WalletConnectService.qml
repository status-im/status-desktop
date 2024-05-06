import QtQuick 2.15

import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Profile.stores 1.0
import shared.stores 1.0
import shared.popups.walletconnect 1.0

import SortFilterProxyModel 0.2
import utils 1.0

QtObject {
    id: root

    required property WalletConnectSDK wcSDK
    required property DAppsStore dappsStore
    required property WalletStore walletStore

    readonly property var validAccounts: SortFilterProxyModel {
        sourceModel: walletStore.accounts
        filters: ValueFilter {
            roleName: "walletType"
            value: Constants.watchWalletType
            inverted: true
        }
    }
    readonly property var flatNetworks: walletStore.flatNetworks

    function pair(uri) {
        _d.acceptedSessionProposal = null
        wcSDK.pair(uri)
    }

    function approvePairSession(sessionProposal, approvedChainIds, approvedAccount) {
        _d.acceptedSessionProposal = sessionProposal
        let approvedNamespaces = JSON.parse(Helpers.buildSupportedNamespaces(approvedChainIds, [approvedAccount.address]))
        wcSDK.buildApprovedNamespaces(sessionProposal.params, approvedNamespaces)
    }

    function rejectPairSession(id) {
        wcSDK.rejectSession(id)
    }

    function disconnectDapp(sessionTopic) {
        wcSDK.disconnectSession(sessionTopic)
    }

    signal connectDApp(var dappChains, var sessionProposal, var approvedNamespaces)
    signal approveSessionResult(var session, var error)

    readonly property Connections sdkConnections: Connections {
        target: wcSDK

        function onSessionProposal(sessionProposal) {
            _d.currentSessionProposal = sessionProposal

            let supportedNamespacesStr = Helpers.buildSupportedNamespacesFromModels(root.flatNetworks, root.validAccounts)
            wcSDK.buildApprovedNamespaces(sessionProposal.params, JSON.parse(supportedNamespacesStr))
        }

        function onBuildApprovedNamespacesResult(approvedNamespaces, error) {
            if(error) {
                // TODO: error reporting
                return
            }

            if (_d.acceptedSessionProposal) {
                wcSDK.approveSession(_d.acceptedSessionProposal, approvedNamespaces)
            } else {
                let res = Helpers.extractChainsAndAccountsFromApprovedNamespaces(approvedNamespaces)

                root.connectDApp(res.chains, _d.currentSessionProposal, approvedNamespaces)
            }
        }

        function onApproveSessionResult(session, err) {
            root.approveSessionResult(session, err)
        }

        function onRejectSessionResult(err) {
            let app_url = _d.currentSessionProposal ? _d.currentSessionProposal.params.proposer.url : "-"
            if(err) {
                console.debug(`TODO #14556: show a notification "Failed to reject connection request for ${app_url}"`)
            } else {
                console.debug(`TODO #14556: show a notification "Connection request for ${app_url} was rejected"`)
            }
        }

        function onSessionDelete(topic, error) {
            let app_url = _d.currentSessionProposal ? _d.currentSessionProposal.params.proposer.url : "-"
            if(error) {
                console.debug(`TODO #14556: show a notification "Failed to disconnect from ${app_url}"`)
            } else {
                console.debug(`TODO #14556: show a notification "Disconnected from ${app_url}"`)
            }
        }
    }

    readonly property QtObject _d: QtObject {
        property var currentSessionProposal: null
        property var acceptedSessionProposal: null
    }
}