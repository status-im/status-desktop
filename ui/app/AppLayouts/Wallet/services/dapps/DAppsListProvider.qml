import QtQuick 2.15

import utils 1.0

QtObject {
    id: root

    required property WalletConnectSDK sdk

    readonly property alias pairingsModel: d.pairingsModel
    readonly property alias sessionsModel: d.sessionsModel

    function updatePairings() {
        d.resetPairingsModel()
    }
    function updateSessions() {
        d.resetSessionsModel()
    }

    readonly property QtObject _d: QtObject {
        id: d

        property ListModel pairingsModel: ListModel {
            id: pairings
        }
        property ListModel sessionsModel: ListModel {
            id: sessions
        }

        function resetPairingsModel(entryCallback)
        {
            pairings.clear();

            // We have to postpone `getPairings` call, cause otherwise:
            // - the last made pairing will always have `active` prop set to false
            // - expiration date won't be the correct one, but one used in session proposal
            // - the list of pairings will display succesfully made pairing as inactive
            Backpressure.debounce(this, 250, () => {
                sdk.getPairings((pairList) => {
                    for (let i = 0; i < pairList.length; i++) {
                        pairings.append(pairList[i]);

                        if (entryCallback) {
                            entryCallback(pairList[i])
                        }
                    }
                });
            })();
        }

        function resetSessionsModel() {
            sessions.clear();

            Backpressure.debounce(this, 250, () => {
                sdk.getActiveSessions((sessionList) => {
                    for (var topic of Object.keys(sessionList)) {
                        sessions.append(sessionList[topic]);
                    }
                });
            })();
        }

        function getPairingTopicFromPairingUrl(url)
        {
            if (!url.startsWith("wc:"))
            {
                return null;
            }

            const atIndex = url.indexOf("@");
            if (atIndex < 0)
            {
                return null;
            }

            return url.slice(3, atIndex);
        }
    }
}