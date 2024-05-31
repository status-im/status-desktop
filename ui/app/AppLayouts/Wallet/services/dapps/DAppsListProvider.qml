import QtQuick 2.15

import StatusQ.Core.Utils 0.1

import shared.stores 1.0

import utils 1.0

QObject {
    id: root

    required property WalletConnectSDKBase sdk
    required property DAppsStore store

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

            // TODO DEV: check if still holds true
            // Reasons to postpone `getDapps` call:
            // - the first recent made session will always have `active` prop set to false
            // - expiration date won't be the correct one, but one used in session proposal
            // - the list of dapps will display successfully made pairing as inactive
            getActiveSessionsFn = () => {
                sdk.getActiveSessions((sessions) => {
                    root.store.dappsListReceived.disconnect(dappsListReceivedFn);

                    // TODO #14755: on SDK dApps refresh update the model that has data source from persistence instead of using reset
                    dapps.clear();

                    let tmpMap = {}
                    for (let key in sessions) {
                        let dapp = sessions[key].peer.metadata
                        if (dapp.icons.length > 0) {
                            dapp.iconUrl = dapp.icons[0]
                        }
                        tmpMap[dapp.url] = dapp;
                    }
                    // Iterate tmpMap and fill dapps
                    for (let key in tmpMap) {
                        dapps.append(tmpMap[key]);
                    }
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