import QtQuick 2.15

import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Profile.stores 1.0
import shared.stores 1.0
import shared.popups.walletconnect 1.0

QtObject {
    id: root

    required property WalletConnectSDK wcSDK
    required property DAppsStore dappsStore
    //required property WalletStore walletStore

    function pair(uri) {
        wcSDK.pair(uri)
    }

    /// proposer taken from the SessionProposal.params.proposer
    signal connectDApp(var chains, var accounts, var proposer)

    readonly property Connections sdkConnections: Connections {
        target: wcSDK
        function onPairResponse(success) {
            // TODO #14607: propagate pairings if the session is expired and report as error to the PairWCModal
        }

        function onSessionProposal(sessionProposal) {
            // TODO DEV: get the available chains and accounts from the source
            _d.currentSessionProposal = sessionProposal
            wcSDK.buildApprovedNamespaces(sessionProposal.params, JSON.parse(`{
                "eip155": {
                    "chains": ["eip155:11155111", "eip155:421614", "eip155:11155420"],
                    "methods": ["eth_sendTransaction", "personal_sign"],
                    "events": ["accountsChanged", "chainChanged"],
                    "accounts": [
                        "eip155:11155111:0xE2D622C817878DA5143BBE06866CA8E35273BA8A",
                        "eip155:421614:0xE2D622C817878DA5143BBE06866CA8E35273BA8A",
                        "eip155:11155420:0xE2D622C817878DA5143BBE06866CA8E35273BA8A",
                        "eip155:11155111:0xBD54A96C0AE19A220C8E1234F54C940DFAB34639",
                        "eip155:421614:0xBD54A96C0AE19A220C8E1234F54C940DFAB34639",
                        "eip155:11155420:0xBD54A96C0AE19A220C8E1234F54C940DFAB34639",
                        "eip155:11155111:0x5D7905390B77A937AE8C444AA8BF7FA9A6A7DBA0",
                        "eip155:421614:0x5D7905390B77A937AE8C444AA8BF7FA9A6A7DBA0",
                        "eip155:11155420:0x5D7905390B77A937AE8C444AA8BF7FA9A6A7DBA0"
                    ]
                }
            }`))
        }

        function onBuildApprovedNamespacesResult(approvedNamespaces, error) {
            if(error) {
                // TODO: error reporting
                return
            }

            let res = _d.extractChainsAndAccountsFromApprovedNamespaces(approvedNamespaces)

            root.connectDApp(res.chains, res.accounts, _d.currentSessionProposal.params.proposer)
        }
    }

    readonly property QtObject _d: QtObject {
        property var currentSessionProposal: null
        function extractChainsAndAccountsFromApprovedNamespaces(approvedNamespaces) {
            const eip155Data = approvedNamespaces.eip155;
            const chains = eip155Data.chains.map(chain => parseInt(chain.split(':').pop().trim(), 10));
            const accountSet = new Set(
                eip155Data.accounts.map(account => account.split(':').pop().trim())
            );
            const uniqueAccounts = Array.from(accountSet);
            return { chains, accounts: uniqueAccounts };
        }
    }
}