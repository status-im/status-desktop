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
    // // Array[chainId] of the networks that are down
    required property var blockchainNetworksDown

    property bool walletConnectFeatureEnabled: true
    property bool connectorFeatureEnabled: true

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

    readonly property bool isServiceOnline: requestHandler.isServiceOnline

    // methods
    /// Triggers the signing process for the given session request
    /// @param topic The topic of the session
    /// @param id The id of the session request
    function sign(topic, id) {
        // The authentication triggers the signing process
        // authenticate -> sign -> inform the dApp
        d.sign(topic, id)
    }

    function rejectSign(topic, id, hasError) {
        d.rejectSign(topic, id, hasError)
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
        requestHandler.pair(uri)
    }

    /// Approves or rejects the session proposal
    function approvePairSession(key, approvedChainIds, accountAddress) {
        requestHandler.approvePairSession(key, approvedChainIds, accountAddress)
    }


    /// Rejects the session proposal
    function rejectPairSession(id) {
        requestHandler.rejectPairSession(id)
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
                    requestHandler.disconnectSession(dApp.sessions.get(i).topic)
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

            requestHandler.validatePairingUri(uri)
        }
        
        function sign(topic, id) {
            const request = sessionRequestsModel.findRequest(topic, id)
            if (!request) {
                console.error("Session request not found")
                return
            }
            request.accept()
        }

        function rejectSign(topic, id, hasError) {
            const request = sessionRequestsModel.findRequest(topic, id)
            if (!request) {
                console.error("Session request not found")
                return
            }
            request.reject(hasError)
        }

        function reportPairErrorState(state) {
            timeoutTimer.stop()
            root.pairingValidated(state)
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

    DAppsRequestHandler {
        id: requestHandler

        sdk: root.wcSDK
        store: root.store
        accountsModel: root.validAccounts
        networksModel: SortFilterProxyModel {
            sourceModel: root.flatNetworks
            proxyRoles: [
                FastExpressionRole {
                    name: "isOnline"
                    expression: !root.blockchainNetworksDown.map(Number).includes(model.chainId)
                    expectedRoles: "chainId"
                }
            ]
        }
        currenciesStore: root.walletRootStore.currencyStore
        assetsStore: root.walletRootStore.walletAssetsStore

        onSessionRequest: (id) => {
            timeoutTimer.stop()
            root.sessionRequest(id)
        }
        onDisplayToastMessage: (message, type) => {
            root.displayToastMessage(message, type)
        }
        onPairingResponse: (state) => {
            if (state != Pairing.errors.uriOk) {
                d.reportPairErrorState(state)
            }
        }
        onConnectDApp: (dappChains, dappUrl, dappName, dappIcon, key) => {
            root.connectDApp(dappChains, dappUrl, dappName, dappIcon, key)
        }
        onApproveSessionResult: (key, error, topic) => {
            root.approveSessionResult(key, error, topic)
        }
        onPairingValidated: (validationState) => {
            timeoutTimer.stop()
            root.pairingValidated(validationState)
        }
        onDappDisconnected: (_, dappUrl, err) => {
            d.notifyDappDisconnect(dappUrl, err)
        }
    }

    DAppsListProvider {
        id: dappsProvider
        enabled: root.walletConnectFeatureEnabled
        sdk: root.wcSDK
        store: root.store
        supportedAccountsModel: root.walletRootStore.nonWatchAccounts
    }

    ConnectorDAppsListProvider {
        id: connectorDAppsProvider
        enabled: root.connectorFeatureEnabled
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
