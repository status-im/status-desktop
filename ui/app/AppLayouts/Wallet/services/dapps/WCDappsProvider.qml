import QtQuick

import StatusQ
import StatusQ.Core.Utils as SQUtils

import AppLayouts.Wallet.services.dapps

import shared.stores

import utils

DAppsModel {
    id: root

    // Input
    required property WalletConnectSDKBase sdk
    required property DAppsStore store
    required property var supportedAccountsModel

    readonly property int connectorId: Constants.WalletConnect

    readonly property bool enabled: sdk.enabled

    signal disconnected(string topic, string dAppUrl)
    signal connected(string proposalId, string topic, string dAppUrl)

    Connections {
        target: root.sdk
        enabled: root.enabled

        function onSessionDelete(topic, err) {
            const dapp = root.getByTopic(topic)
            if (!dapp) {
                console.warn("DApp not found for topic - cannot delete session", topic)
                return
            }

            root.store.deactivateWalletConnectSession(topic)
            d.updateDappsModel()
            root.disconnected(topic, dapp.url)
        }
        function onSdkInit(success, result) {
            if (!success) {
                return
            }
            d.updateDappsModel()
        }
        function onApproveSessionResult(proposalId, session, error) {
            if (error) {
                return
            }

            root.store.addWalletConnectSession(JSON.stringify(session))
            d.updateDappsModel()
            root.connected(proposalId, session.topic, session.peer.metadata.url)
        }

        function onAcceptSessionAuthenticateResult(id, result, error) {
            if (error) {
                return
            }
            d.updateDappsModel()
            root.connected(id, result.topic, result.session.peer.metadata.url)
        }
    }

    Component.onCompleted: {
        if (!enabled) {
            return
        }
        // Just in case the SDK is already initialized
        d.updateDappsModel()
    }

    onEnabledChanged: {
        if (enabled) {
            d.updateDappsModel()
        } else {
            d.dappsModel.clear()
        }
    }

    SQUtils.QObject {
        id: d

        property var dappsListReceivedFn: null
        property var getActiveSessionsFn: null
        function updateDappsModel()
        {
            dappsListReceivedFn = (dappsJson) => {
                root.store.dappsListReceived.disconnect(dappsListReceivedFn);
                root.clear();

                let dappsList = JSON.parse(dappsJson);
                for (let i = 0; i < dappsList.length; i++) {
                    const cachedEntry = dappsList[i];
                    // TODO #15075: on SDK dApps refresh update the model that has data source from persistence instead of using reset
                    const dappEntryWithRequiredRoles = {
                        url: cachedEntry.url,
                        name: cachedEntry.name,
                        iconUrl: cachedEntry.iconUrl,
                        accountAddresses: [],
                        topic: cachedEntry.url,
                        connectorId: root.connectorId, 
                        rawSessions: []
                    }
                    root.append(dappEntryWithRequiredRoles);
                }
            }
            root.store.dappsListReceived.connect(dappsListReceivedFn);

            // triggers a potential fast response from store.dappsListReceived
            if (!store.getDapps()) {
                console.warn("Failed retrieving dapps from persistence")
                root.store.dappsListReceived.disconnect(dappsListReceivedFn);
            }

            getActiveSessionsFn = () => {
                sdk.getActiveSessions((allSessionsAllProfiles) => {
                    if (!allSessionsAllProfiles) {
                        console.warn("Failed to get active sessions")
                        return
                    }

                    root.store.dappsListReceived.disconnect(dappsListReceivedFn);

                    const dAppsMap = {}
                    const topics = []
                    const sessions = DAppsHelpers.filterActiveSessionsForKnownAccounts(allSessionsAllProfiles, root.supportedAccountsModel)
                    for (const sessionID in sessions) {
                        const session = sessions[sessionID]
                        const dapp = session.peer.metadata
                        if (!!dapp.icons && dapp.icons.length > 0) {
                            dapp.iconUrl = dapp.icons[0]
                        } else {
                            dapp.iconUrl = ""
                        }
                        const accounts = DAppsHelpers.getAccountsInSession(session)
                        const existingDApp = dAppsMap[dapp.url]
                        if (existingDApp) {
                            // In Qt5.15.2 this is the way to make a "union" of two arrays
                            // more modern syntax (ES-6) is not available yet
                            const combinedAddresses = new Set(existingDApp.accountAddresses.concat(accounts));
                            existingDApp.accountAddresses = Array.from(combinedAddresses);
                            existingDApp.rawSessions = [...existingDApp.rawSessions, session]
                        } else {
                            dapp.accountAddresses = accounts
                            dapp.topic = sessionID
                            dapp.rawSessions = [session]
                            dAppsMap[dapp.url] = dapp
                        }
                        topics.push(sessionID)
                    }

                    // TODO #15075: on SDK dApps refresh update the model that has data source from persistence instead of using reset
                    root.clear();

                    // Iterate dAppsMap and fill dapps
                    for (const uri in dAppsMap) {
                        const dAppEntry = dAppsMap[uri];
                        // Due to ListModel converting flat array to empty nested ListModel
                        // having array of key value pair fixes the problem
                        dAppEntry.accountAddresses = dAppEntry.accountAddresses.filter(account => (!!account)).map(account => ({address: account}));
                        dAppEntry.connectorId = root.connectorId;
                        root.append(dAppEntry);
                    }

                    root.store.updateWalletConnectSessions(JSON.stringify(topics))
                });
            }

            if (root.sdk.sdkReady) {
                getActiveSessionsFn()
            } else {
                let conn = root.sdk.sdkReadyChanged.connect(() => {
                    if (root.sdk.sdkReady) {
                        getActiveSessionsFn()
                    }
                });
            }
        }
    }
}
