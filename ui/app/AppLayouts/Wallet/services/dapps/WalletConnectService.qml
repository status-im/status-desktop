import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0
import AppLayouts.Profile.stores 1.0
import shared.stores 1.0
import shared.popups.walletconnect 1.0

import SortFilterProxyModel 0.2
import utils 1.0

import "types"

// The WC SDK has an async (function call then signal response)
// A complete pairing flow to connect a dApp:
//  - user provides pairing url -> root.validatePairingUri -> signal pairingValidated
//  - user requests pair -> root.pair(uri) -> pairResponse(ok)
//    -> if pairResponse ok -> onSessionProposal -> sdk.buildApprovedNamespaces
//    -> onBuildApprovedNamespace -> signal connectDApp
//  - user requests root.approvePairSession/root.rejectPairSession
//    -> if approvePairSession -> sdk.buildApprovedNamespaces
//    -> onBuildApprovedNamespace -> sdk.approveSession -> onApproveSessionResult
QObject {
    id: root

    //input properties
    required property WalletConnectSDKBase wcSDK
    required property DAppsStore store
    required property var walletRootStore

    //output properties
    /// Model contaning all dApps available for the currently selected account
    readonly property var dappsModel: d.filteredDappsModel
    /// Model containig the dApps session requests to be resolved by the user
    readonly property SessionRequestsModel sessionRequestsModel: requestHandler.requestsModel
    /// Model containing the valid accounts a dApp can interact with
    readonly property var validAccounts: root.walletRootStore.nonWatchAccounts
    /// Model containing the networks a dApp can interact with
    readonly property var flatNetworks: root.walletRootStore.filteredFlatModel
    /// Service can interact with the current address selection
    /// Default value: true
    readonly property bool serviceAvailableToCurrentAddress: !root.walletRootStore.selectedAddress ||
                ModelUtils.contains(root.validAccounts, "address", root.walletRootStore.selectedAddress, Qt.CaseInsensitive)
    /// TODO: refactor
    readonly property alias connectorDAppsProvider: connectorDAppsProvider

    // methods
    /// Triggers the signing process for the given session request
    /// @param topic The topic of the session
    /// @param id The id of the session request
    function sign(topic, id) {
        // The authentication triggers the signing process
        // authenticate -> sign -> inform the dApp
        d.authenticate(topic, id)
    }

    function rejectSign(topic, id, hasError) {
        requestHandler.rejectSessionRequest(topic, id, hasError)
    }

    function subscribeForFeeUpdates(topic, id) {
        requestHandler.subscribeForFeeUpdates(topic, id)
    }

    /// Validates the pairing URI
    function validatePairingUri(uri) {
        d.validatePairingUri(uri)
    }

    /// Initiates the pairing process with the given URI
    function pair(uri) {
        timeoutTimer.start()
        wcSDK.pair(uri)
    }
    
    /// Approves or rejects the session proposal
    function approvePairSession(key, approvedChainIds, accountAddress) {
        if (!d.activeProposals.has(key)) {
            console.error("No active proposal found for key: " + key)
            return
        }

        const proposal = d.activeProposals.get(key)
        d.acceptedSessionProposal = proposal
        const approvedNamespaces = JSON.parse(
            DAppsHelpers.buildSupportedNamespaces(approvedChainIds,
                                             [accountAddress],
                                             SessionRequest.getSupportedMethods())
        )
        wcSDK.buildApprovedNamespaces(key, proposal.params, approvedNamespaces)
    }

    /// Rejects the session proposal
    function rejectPairSession(id) {
        wcSDK.rejectSession(id)
    }

    /// Disconnects the dApp with the given topic
    /// @param topic The topic of the dApp
    /// @param source The source of the dApp; either "walletConnect" or "connector"
    function disconnectDapp(topic) {
        d.disconnectDapp(topic)
    }

    // signals
    signal connectDApp(var dappChains, url dappUrl, string dappName, url dappIcon, var key)
    // Emitted as a response to WalletConnectService.approveSession
    // @param key The key of the session proposal
    // @param error The error message
    // @param topic The new topic of the session
    signal approveSessionResult(var key, var error, var topic)
    // Emitted when a new session is requested by a dApp
    signal sessionRequest(string id)
    // Emitted when the services requests to display a toast message
    // @param message The message to display
    // @param type The type of the message. Maps to Constants.ephemeralNotificationType
    signal displayToastMessage(string message, int type)
    // Emitted as a response to WalletConnectService.validatePairingUri or other WalletConnectService.pair
    // and WalletConnectService.approvePair errors
    signal pairingValidated(int validationState)
    signal revokeSession(string topic)

    QObject {
        id: d

        readonly property var dappsModel: ConcatModel {
            id: dappsModel
            markerRoleName: "source"

            sources: [
                SourceModel {
                    model: dappsProvider.dappsModel
                    markerRoleValue: "walletConnect"
                },
                SourceModel {
                    model: connectorDAppsProvider.dappsModel
                    markerRoleValue: "statusConnect"
                }
            ]
        }

        readonly property var filteredDappsModel: SortFilterProxyModel {
            id: dappsFilteredModel
            objectName: "DAppsModelFiltered"
            sourceModel: d.dappsModel
            readonly property string selectedAddress: root.walletRootStore.selectedAddress

            filters: FastExpressionFilter {
                enabled: !!dappsFilteredModel.selectedAddress

                function isAddressIncluded(accountAddressesSubModel, selectedAddress) {
                    if (!accountAddressesSubModel) {
                        return false
                    }
                    const addresses = ModelUtils.modelToFlatArray(accountAddressesSubModel, "address")
                    return addresses.includes(selectedAddress)
                }
                expression: isAddressIncluded(model.accountAddresses, dappsFilteredModel.selectedAddress)

                expectedRoles: "accountAddresses"
            }
        }

        property var activeProposals: new Map() // key: proposalId, value: sessionProposal
        property var acceptedSessionProposal: null

        /// Disconnects the WC session with the given topic
        function disconnectSession(sessionTopic) {
            wcSDK.disconnectSession(sessionTopic)
        }   

        function disconnectDapp(topic) {
            const dApp = d.getDAppByTopic(topic)
            if (!dApp) {
                console.error("Disconnecting dApp: dApp not found")
                return
            }

            if (!dApp.connectorId == undefined) {
                console.error("Disconnecting dApp: connectorId not found")
                return
            }
            
            // TODO: refactor
            if (dApp.connectorId === connectorDAppsProvider.connectorId) {
                root.revokeSession(topic)
                d.notifyDappDisconnect(dApp.url, false)
                return
            }
            // TODO: refactor
            if (dApp.connectorId === dappsProvider.connectorId) {
                // Currently disconnect acts on all sessions!
                for (let i = 0; i < dApp.sessions.ModelCount.count; i++) {
                    d.disconnectSession(dApp.sessions.get(i).topic)
                }
            }
        }

        function validatePairingUri(uri) {
            // Check if emoji inside the URI
            if(Constants.regularExpressions.emoji.test(uri)) {
                root.pairingValidated(Pairing.errors.tooCool)
                return
            } else if(!DAppsHelpers.validURI(uri)) {
                root.pairingValidated(Pairing.errors.invalidUri)
                return
            }

            const info = DAppsHelpers.extractInfoFromPairUri(uri)
            wcSDK.getActiveSessions((sessions) => {
                // Check if the URI is already paired
                let validationState = Pairing.errors.uriOk
                for (const key in sessions) {
                    if (sessions[key].pairingTopic === info.topic) {
                        validationState = Pairing.errors.alreadyUsed
                        break
                    }
                }

                // Check if expired
                if (validationState === Pairing.errors.uriOk) {
                    const now = (new Date().getTime())/1000
                    if (info.expiry < now) {
                        validationState = Pairing.errors.expired
                    }
                }

                root.pairingValidated(validationState)
            });
        }
        
        function authenticate(topic, id) {
            const request = sessionRequestsModel.findRequest(topic, id)
            if (!request) {
                console.error("Session request not found")
                return
            }
            requestHandler.authenticate(topic, id, request.accountAddress, request.feesInfo)
        }

        function reportPairErrorState(state) {
            timeoutTimer.stop()
            root.pairingValidated(state)
        }

        function disconnectSessionRequested(topic, err) {
            // Get all sessions and filter the active ones for known accounts
            // Act on the first matching session with the same topic
            const activeSessionsCallback = (allSessions, success) => {
                store.activeSessionsReceived.disconnect(activeSessionsCallback)
                
                if (!success) {
                    // TODO #14754: implement custom dApp notification
                    d.notifyDappDisconnect("-", true)
                    return
                }
                
                // Convert to original format
                const webSdkSessions = allSessions.map((session) => {
                    return JSON.parse(session.sessionJson)
                })

                const sessions = DAppsHelpers.filterActiveSessionsForKnownAccounts(webSdkSessions, root.validAccounts)
                
                for (const sessionID in sessions) {
                    const session = sessions[sessionID]
                    if (session.topic === topic) {
                        store.deactivateWalletConnectSession(topic)
                        dappsProvider.updateDapps()
                        
                        const dappUrl = session.peer.metadata.url ?? "-"
                        d.notifyDappDisconnect(dappUrl, err)
                        break
                    }
                }
            }

            store.activeSessionsReceived.connect(activeSessionsCallback)
            if (!store.getActiveSessions()) {
                store.activeSessionsReceived.disconnect(activeSessionsCallback)
                // TODO #14754: implement custom dApp notification
            }
        }
        
        function notifyDappDisconnect(dappUrl, err) {
            const appDomain = StringUtils.extractDomainFromLink(dappUrl)
            if(err) {
                root.displayToastMessage(qsTr("Failed to disconnect from %1").arg(appDomain), Constants.ephemeralNotificationType.danger)
            } else {
                root.displayToastMessage(qsTr("Disconnected from %1").arg(appDomain), Constants.ephemeralNotificationType.success)
            }
        }

        function getDAppByTopic(topic) {
            return ModelUtils.getFirstModelEntryIf(d.dappsModel, (modelItem) => {
                if (modelItem.topic == topic) {
                    return true
                }
                if (!modelItem.sessions) {
                    return false
                }
                for (let i = 0; i < modelItem.sessions.ModelCount.count; i++) {
                    if (modelItem.sessions.get(i).topic == topic) {
                        return true
                    }
                }
            })
        }
    }

    Connections {
        target: wcSDK

        function onPairResponse(ok) {
            if (!ok) {
                d.reportPairErrorState(Pairing.errors.unknownError)
            } // else waiting for onSessionProposal
        }

        function onSessionProposal(sessionProposal) {
            const key = sessionProposal.id
            d.activeProposals.set(key, sessionProposal)

            const supportedNamespacesStr = DAppsHelpers.buildSupportedNamespacesFromModels(
                  root.flatNetworks, root.validAccounts, SessionRequest.getSupportedMethods())
            wcSDK.buildApprovedNamespaces(key, sessionProposal.params, JSON.parse(supportedNamespacesStr))
        }

        function onBuildApprovedNamespacesResult(key, approvedNamespaces, error) {
            if (!d.activeProposals.has(key)) {
                console.error("No active proposal found for key: " + key)
                return
            }

            if(error || !approvedNamespaces) {
                // Check that it contains Non conforming namespaces"
                if (error.includes("Non conforming namespaces")) {
                    d.reportPairErrorState(Pairing.errors.unsupportedNetwork)
                } else {
                    d.reportPairErrorState(Pairing.errors.unknownError)
                }
                return
            }
            const an = approvedNamespaces.eip155
            if (!(an.accounts) || an.accounts.length === 0 || (!(an.chains) || an.chains.length === 0)) {
                d.reportPairErrorState(Pairing.errors.unsupportedNetwork)
                return
            }

            if (d.acceptedSessionProposal) {
                wcSDK.approveSession(d.acceptedSessionProposal, approvedNamespaces)
            } else {
                const proposal = d.activeProposals.get(key)
                const res = DAppsHelpers.extractChainsAndAccountsFromApprovedNamespaces(approvedNamespaces)
                const chains = res.chains
                const dAppUrl = proposal.params.proposer.metadata.url
                const dAppName = proposal.params.proposer.metadata.name
                const dAppIcons = proposal.params.proposer.metadata.icons
                const dAppIcon = dAppIcons && dAppIcons.length > 0 ? dAppIcons[0] : ""

                root.connectDApp(chains, dAppUrl, dAppName, dAppIcon, key)
            }
        }

        function onApproveSessionResult(proposalId, session, err) {
            if (!d.activeProposals.has(proposalId)) {
                console.error("No active proposal found for key: " + proposalId)
                return
            }

            if (!d.acceptedSessionProposal || d.acceptedSessionProposal.id !== proposalId) {
                console.error("No accepted proposal found for key: " + proposalId)
                d.activeProposals.delete(proposalId)
                return
            }

            const proposal = d.activeProposals.get(proposalId)
            d.activeProposals.delete(proposalId)
            d.acceptedSessionProposal = null
            
            if (err) {
                d.reportPairErrorState(Pairing.errors.unknownError)
                return
            }

            // TODO #14754: implement custom dApp notification
            const app_url = proposal.params.proposer.metadata.url ?? "-"
            const app_domain = StringUtils.extractDomainFromLink(app_url)
            root.displayToastMessage(qsTr("Connected to %1 via WalletConnect").arg(app_domain), Constants.ephemeralNotificationType.success)

            // Persist session
            if(!store.addWalletConnectSession(JSON.stringify(session))) {
                console.error("Failed to persist session")
            }

            // Notify client
            root.approveSessionResult(proposalId, err, session.topic)

            dappsProvider.updateDapps()
        }

        function onRejectSessionResult(proposalId, err) {
            if (!d.activeProposals.has(proposalId)) {
                console.error("No active proposal found for key: " + proposalId)
                return
            }
            
            const proposal = d.activeProposals.get(proposalId)
            d.activeProposals.delete(proposalId)

            const app_url = proposal.params.proposer.metadata.url ?? "-"
            const app_domain = StringUtils.extractDomainFromLink(app_url)
            if(err) {
                d.reportPairErrorState(Pairing.errors.unknownError)
                root.displayToastMessage(qsTr("Failed to reject connection request for %1").arg(app_domain), Constants.ephemeralNotificationType.danger)
            } else {
                root.displayToastMessage(qsTr("Connection request for %1 was rejected").arg(app_domain), Constants.ephemeralNotificationType.success)
            }
        }

        function onSessionDelete(topic, err) {
            d.disconnectSessionRequested(topic, err)
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
        currenciesStore: root.walletRootStore.currencyStore
        assetsStore: root.walletRootStore.walletAssetsStore

        onSessionRequest: (id) => {
            timeoutTimer.stop()
            root.sessionRequest(id)
        }
        onDisplayToastMessage: (message, type) => {
            root.displayToastMessage(message, type)
        }
    }

    DAppsListProvider {
        id: dappsProvider
        sdk: root.wcSDK
        store: root.store
        supportedAccountsModel: root.walletRootStore.nonWatchAccounts
    }

    ConnectorDAppsListProvider {
        id: connectorDAppsProvider
    }

    // Timeout for the corner case where the URL was already dismissed and the SDK doesn't respond with an error nor advances with the proposal
    Timer {
        id: timeoutTimer

        interval: 10000 // (10 seconds)
        running: false
        repeat: false

        onTriggered: {
            d.reportPairErrorState(Pairing.errors.unknownError)
        }
    }
}
