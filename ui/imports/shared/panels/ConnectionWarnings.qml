import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0

Loader {
    id: root
    active: false

    property var networkConnectionStore
    readonly property string jointChainIdString: networkConnectionStore.getChainIdsJointString(chainIdsDown)
    property string websiteDown
    property int connectionState: -1
    property var chainIdsDown: []
    property bool completelyDown: false
    property double lastCheckedAtUnix: -1
    property string lastCheckedAt
    property bool withCache: false
    property string tooltipMessage
    property string toastText

    function updateBanner() {
        root.active = true
        if (connectionState === Constants.ConnectionStatus.Failure)
            item.show()
        else
            item.showFor(3000)
    }

    sourceComponent: ModuleWarning {
        QtObject {
            id: d
            readonly property bool isOnline: networkConnectionStore.isOnline
            onIsOnlineChanged: if(!isOnline) hide()
        }

        onHideFinished: root.active = false

        text: root.toastText
        type: connectionState === Constants.ConnectionStatus.Success ? ModuleWarning.Success : ModuleWarning.Danger
        buttonText: connectionState === Constants.ConnectionStatus.Failure ? qsTr("Retry now") : ""

        onClicked: networkConnectionStore.retryConnection(websiteDown)
        onCloseClicked: hide()

        onLinkActivated: {
            toolTip.show(root.tooltipMessage, 3000)
        }

        StatusToolTip {
            id: toolTip
            orientation: StatusToolTip.Orientation.Bottom
            maxWidth: 300
        }
    }

    Connections {
        target: networkConnectionStore.networkConnectionModuleInst
        function onNetworkConnectionStatusUpdate(website: string, completelyDown: bool, connectionState: int, chainIds: string, lastCheckedAtUnix: double)  {
            if (website === websiteDown) {
                root.connectionState = connectionState
                root.chainIdsDown = chainIds.split(";")
                root.completelyDown = completelyDown
                root.lastCheckedAtUnix = lastCheckedAtUnix
                root.lastCheckedAt = LocaleUtils.formatDateTime(new Date(lastCheckedAtUnix*1000))
                root.updateBanner()
            }
        }
    }
}
