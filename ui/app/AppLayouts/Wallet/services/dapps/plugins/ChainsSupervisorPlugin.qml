import QtQuick

import AppLayouts.Wallet.helpers
import AppLayouts.Wallet.services.dapps
import AppLayouts.Wallet.services.dapps.types as DAppsTypes

import StatusQ
import StatusQ.Core.Utils

// This plugin handles the chain ability for the dapps
// It monitors the chain availability and updates the dapps accordingly
// When all chains are offline, it will inform each session that the chains are offline
// When a chain comes back online, it will check if there are any active sessions and inform them
// See [EIP-1193](https://eips.ethereum.org/EIPS/eip-1193)
QObject {
    id: root

    required property WalletConnectSDKBase sdk
    // Required roles: chainId, isOnline
    required property var networksModel
    // Happens when any chain is available
    readonly property bool isOnline: !chainsAvailabilityWatchdog.allOffline && chainsAvailabilityWatchdog.networkOnline
    readonly property bool allChainsOffline: chainsAvailabilityWatchdog.allOffline
    readonly property bool networkOffline: !chainsAvailabilityWatchdog.networkOnline

    ChainsAvailabilityWatchdog {
        id: chainsAvailabilityWatchdog

        // property used for spam protection
        property var lastNotifiedCStatuses: new Map()
        networksModel: root.networksModel

        onChainOnlineChanged: (chainId, isOnline) => {
            if (!isOnline || !sdk.sdkReady) {
                return
            }

            // Spam protection. Spamming the SDK could result to blocks
            if (lastNotifiedCStatuses.has(chainId) && lastNotifiedCStatuses.get(chainId) === isOnline) {
                return
            }

            lastNotifiedCStatuses.set(chainId, isOnline)
            d.notifyChainConnected(chainId)
        }

        onAllOfflineChanged: {
            if(!sdk.sdkReady) {
                return
            }

            if (allOffline) {
                lastNotifiedCStatuses.clear()
                d.notifyAllChainsDisconnected()
            }
        }
    }

    QtObject {
        id: d

        function sessionHasEventSupport(session, event) {
            try {
                if (!event) {
                    return false
                }

                if (session.namespaces.eip155.events.includes(event)) {
                    return true
                }

                return false
            } catch (e) {
                console.error("Error checking sessionHasEventSupport: ", e)
                return false
            }
        }

        function sessionHasChainSupport(session, chainId) {
            try {
                if (!chainId) {
                    return false
                }

                let chainIds = session.namespaces.eip155.chains.map(DAppsHelpers.chainIdFromEip155);
                if (!chainIds.includes(chainId)) {
                    return false
                }

                let accounts = session.namespaces.eip155.accounts
                let chainAccounts = accounts.map((account) => account.startsWith(`eip155:${chainId}`))
                if (!chainAccounts.includes(true)) {
                    return false
                }

                return true
            } catch (e) {
                console.error("Error checking sessionHasChainSupport: ", e)
                return false
            }
        }

        function notifyAllChainsDisconnected() {
            sdk.getActiveSessions((allSessions) => {
                Object.values(allSessions).forEach((session) => {
                    if (!d.sessionHasEventSupport(session, "disconnect")) {
                        return
                    }

                    try {
                        session.namespaces.eip155.chains.forEach((chainId) => {
                            const chainInt = DAppsHelpers.chainIdFromEip155(chainId)
                            if (!d.sessionHasChainSupport(session, chainInt)) {
                                return
                            }

                            sdk.emitSessionEvent(session.topic, {
                                name: "disconnect",
                                data: {
                                    code: DAppsTypes.ErrorCodes.rpcErrors.disconnected,
                                }
                            }, chainId)
                        })
                    } catch (e) {
                        console.error("Error emitting session event: ", e)
                    }
                })
            })
        }

        function notifyChainConnected(chainId) {
            sdk.getActiveSessions((sessions) => {
                Object.values(sessions).forEach((session) => {
                    if (!d.sessionHasEventSupport(session, "connect")) {
                        return
                    }
                    if (!d.sessionHasChainSupport(session, chainId)) {
                        return
                    }

                    const hexChain = `0x${chainId.toString(16)}`
                    sdk.emitSessionEvent(session.topic, {
                        name: "connect",
                        data: {
                            chainId: hexChain,
                        }
                    }, `eip155:${chainId}`)
                })
            })
        }
    }
}
