import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

// This component receives the networksModel
// and breaks down the online status of each chain
QObject {
    id: root
    // Required roleNames: chainId, isOnline
    required property var networksModel

    readonly property bool allOffline: d.allOffline
    readonly property bool allOnline: d.allOnline

    property bool active: true

    signal chainOnlineChanged(int chainId, bool isOnline)

    // Network online observer
    // `chainOnlineChanged` signal when the online status of a chain changes
    Instantiator {
        id: networkOnlineObserver
        model: root.networksModel
        active: root.active
        delegate: QtObject {
            required property var model
            property var /*var intended*/ isOnline: model.isOnline

            onIsOnlineChanged: {
                root.chainOnlineChanged(model.chainId, isOnline)
            }
        }
    }

    // Aggregator to count the number of online chains
    SumAggregator{
        id: aggregator
        model: root.active ? root.networksModel : null
        roleName: "isOnline"
    }

    // Network checker to check if the device is online
    NetworkChecker {
        id: networkChecker
        active: root.active
    }

    QtObject {
        id: d
        readonly property bool allOffline: !networkChecker.isOnline || aggregator.value === 0
        readonly property bool allOnline: networkChecker.isOnline &&
                                        aggregator.value > 0 &&
                                        aggregator.value === networksModel.ModelCount.count
    }
}