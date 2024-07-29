import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.services.dapps 1.0

import shared.stores 1.0

import utils 1.0

QObject {
    id: root

    required property WalletConnectSDKBase sdk
    required property DAppsStore store
    required property var supportedAccountsModel

    property string selectedAddress: ""

    readonly property SortFilterProxyModel dappsModel: SortFilterProxyModel {
        objectName: "DAppsModelFiltered"
        sourceModel: d.dappsModel

        filters: FastExpressionFilter {
            enabled: !!root.selectedAddress

            function isAddressIncluded(accountAddressesSubModel, selectedAddress) {
                const addresses = ModelUtils.modelToFlatArray(accountAddressesSubModel, "address")
                return addresses.includes(root.selectedAddress)
            }
            expression: isAddressIncluded(model.accountAddresses, root.selectedAddress)

            expectedRoles: "accountAddresses"
        }
    }

    function updateDapps() {
        d.updateDappsModel()
    }

    QObject {
        id: d

        property ListModel dappsModel: ListModel {
            id: dapps
            objectName: "DAppsModel"
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
                    let accountAddresses = cachedEntry.accountAddresses
                    if (!accountAddresses) {
                        accountAddresses = [{address: ''}];
                    }

                    const dappEntryWithRequiredRoles = {
                        description: cachedEntry.description,
                        url: cachedEntry.url,
                        name: cachedEntry.name,
                        iconUrl: cachedEntry.url,
                        accountAddresses: cachedEntry.accountAddresses
                    }
                    dapps.append(dappsList[i]);
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
                            const combinedAddresses = new Set(existingDApp.accountAddresses.concat(dapp.accountAddresses));
                            existingDApp.accountAddresses = Array.from(combinedAddresses);
                        } else {
                            dapp.accountAddresses = accounts
                            dAppsMap[dapp.url] = dapp
                        }

                        topics.push(sessionID)
                    }

                    // TODO #15075: on SDK dApps refresh update the model that has data source from persistence instead of using reset
                    dapps.clear();

                    // Iterate dAppsMap and fill dapps
                    for (const topic in dAppsMap) {
                        const dAppEntry = dAppsMap[topic];
                        // Due to ListModel converting flat array to empty nested ListModel
                        // having array of key value pair fixes the problem
                        dAppEntry.accountAddresses = dAppEntry.accountAddresses.filter(account => (!!account)).map(account => ({address: account}));
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
