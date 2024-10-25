import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.services.dapps 1.0

import shared.stores 1.0

import utils 1.0

QObject {
    id: root

    required property WalletConnectSDKBase sdk
    required property DAppsStore store
    required property var supportedAccountsModel
    readonly property int connectorId: Constants.WalletConnect
    readonly property var dappsModel: d.dappsModel

    Component.onCompleted: {
        // Just in case the SDK is already initialized
        d.updateDappsModel()
    }

    QObject {
        id: d

        property ListModel dappsModel: ListModel {
            id: dapps
            objectName: "DAppsModel"
        }

        property Connections sdkConnections: Connections {
            target: root.sdk
            function onSessionDelete(topic, err) {
                d.updateDappsModel()
            }
            function onSdkInit(success, result) {
                if (success) {
                    d.updateDappsModel()
                }
            }
            function onApproveSessionResult(topic, success, result) {
                if (success) {
                    d.updateDappsModel()
                }
            }

            function onAcceptSessionAuthenticateResult(id, result, error) {
                if (!error) {
                    d.updateDappsModel()
                }
            }
        }

        property var dappsListReceivedFn: null
        property var getActiveSessionsFn: null
        function updateDappsModel()
        {
            dappsListReceivedFn = (dappsJson) => {
                root.store.dappsListReceived.disconnect(dappsListReceivedFn);
                dapps.clear();

                let dappsList = JSON.parse(dappsJson);
                for (let i = 0; i < dappsList.length; i++) {
                    const cachedEntry = dappsList[i];
                    // TODO #15075: on SDK dApps refresh update the model that has data source from persistence instead of using reset
                    const dappEntryWithRequiredRoles = {
                        description: "",
                        url: cachedEntry.url,
                        name: cachedEntry.name,
                        iconUrl: cachedEntry.iconUrl,
                        accountAddresses: [],
                        topic: "",
                        connectorId: root.connectorId, 
                        sessions: []
                    }
                    dapps.append(dappEntryWithRequiredRoles);
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
                    root.store.dappsListReceived.disconnect(dappsListReceivedFn);

                    const dAppsMap = {}
                    const topics = []
                    const sessions = DAppsHelpers.filterActiveSessionsForKnownAccounts(allSessionsAllProfiles, supportedAccountsModel)

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
                            dapp.sessions = [...existingDApp.sessions, session]
                        } else {
                            dapp.accountAddresses = accounts
                            dapp.topic = sessionID
                            dapp.sessions = [session]
                            dAppsMap[dapp.url] = dapp
                        }
                        topics.push(sessionID)
                    }

                    // TODO #15075: on SDK dApps refresh update the model that has data source from persistence instead of using reset
                    dapps.clear();

                    // Iterate dAppsMap and fill dapps
                    for (const uri in dAppsMap) {
                        const dAppEntry = dAppsMap[uri];
                        // Due to ListModel converting flat array to empty nested ListModel
                        // having array of key value pair fixes the problem
                        dAppEntry.accountAddresses = dAppEntry.accountAddresses.filter(account => (!!account)).map(account => ({address: account}));
                        dAppEntry.connectorId = root.connectorId;
                        dapps.append(dAppEntry);
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
