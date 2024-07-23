import QtQuick 2.15

import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.services.dapps 1.0

import shared.stores 1.0

import utils 1.0

QObject {
    id: root

    required property WalletConnectSDKBase sdk
    required property DAppsStore store
    required property var supportedAccountsModel

    readonly property alias dappsModel: d.dappsModel

    function updateDapps() {
        d.updateDappsModel()
    }

    QObject {
        id: d

        property ListModel dappsModel: ListModel {
            id: dapps
        }

        property var dappsListReceivedFn: null
        property var getActiveSessionsFn: null
        function updateDappsModel()
        {
            dappsListReceivedFn = (dappsJson) => {
                dapps.clear();

                let dappsList = JSON.parse(dappsJson);
                for (let i = 0; i < dappsList.length; i++) {
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
                sdk.getActiveSessions((allSessions) => {
                    root.store.dappsListReceived.disconnect(dappsListReceivedFn);

                    let tmpMap = {}
                    var topics = []
                    const sessions = Helpers.filterActiveSessionsForKnownAccounts(allSessions, root.supportedAccountsModel)
                    for (let key in sessions) {
                        let dapp = sessions[key].peer.metadata
                        if (!!dapp.icons && dapp.icons.length > 0) {
                            dapp.iconUrl = dapp.icons[0]
                        } else {
                            dapp.iconUrl = ""
                        }
                        tmpMap[dapp.url] = dapp;
                        topics.push(key)
                    }
                    // TODO #15075: on SDK dApps refresh update the model that has data source from persistence instead of using reset
                    dapps.clear();
                    // Iterate tmpMap and fill dapps
                    for (let key in tmpMap) {
                        dapps.append(tmpMap[key]);
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