import QtQuick 2.14

import StatusQ.Core 0.1

import utils 1.0

ModuleWarning {
    id: root

    property string websiteDown
    property int connectionState: -1
    property int autoTryTimerInSecs: 0
    property var chainIdsDown: []
    property bool completelyDown: false
    property string lastCheckedAt
    property bool withCache: false
    property Timer updateTimer: Timer {
        interval: 1000
        repeat: true
        onTriggered: {
            if (root.autoTryTimerInSecs === 0) {
                stop()
                return
            }
            root.autoTryTimerInSecs =  root.autoTryTimerInSecs - 1
        }
    }

    function updateBanner() {
        hide()
        if (connectionState === Constants.ConnectionStatus.Failure)
            show()
        else
            showFor(3000)
    }

    type: connectionState === Constants.ConnectionStatus.Success ? ModuleWarning.Success : ModuleWarning.Danger
    buttonText: connectionState === Constants.ConnectionStatus.Failure ? qsTr("Retry now") : ""

    onClicked: appMain.rootStore.retryConnection(websiteDown)
    onCloseClicked: hide()

    Connections {
        target: appMain.rootStore.networkConnectionModuleInst
        function onNetworkConnectionStatusUpdate(website: string, completelyDown: bool, connectionState: int, chainIds: string, lastCheckedAt: int, timeToAutoRetryInSecs: int, withCache: bool)  {
            if (website === websiteDown) {
                root.connectionState = connectionState
                root.autoTryTimerInSecs = timeToAutoRetryInSecs
                root.chainIdsDown = chainIds.split(";")
                root.completelyDown = completelyDown
                root.withCache = withCache
                root.lastCheckedAt = LocaleUtils.formatDateTime(new Date(lastCheckedAt*1000))
                root.updateBanner()
            }
        }
    }
}
