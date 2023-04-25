import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0

Loader {
    id: root
    active: false

    height: active && item ? item.height : 0

    property var networkConnectionStore
    readonly property string jointChainIdString: networkConnectionStore.getChainIdsJointString(chainIdsDown)
    property string websiteDown
    property int connectionState: -1
    property var chainIdsDown: []
    property bool completelyDown: false
    property string lastCheckedAt
    property bool withCache: false
    property string tooltipMessage
    property string toastText

    function updateBanner() {
        root.active = true
        if (root.connectionState === Constants.ConnectionStatus.Failure)
            item.show()
        else
            item.showFor(3000)
    }

    sourceComponent: ModuleWarning {
        id: banner
        QtObject {
            id: d
            readonly property bool isOnline: root.networkConnectionStore.isOnline
            onIsOnlineChanged: if(!isOnline) banner.hide()
        }

        onHideFinished: root.active = false

        text: root.toastText
        type: root.connectionState === Constants.ConnectionStatus.Success ? ModuleWarning.Success : ModuleWarning.Danger
        buttonText: root.connectionState === Constants.ConnectionStatus.Failure ? qsTr("Retry now") : ""

        onClicked: root.networkConnectionStore.retryConnection(root.websiteDown)
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
        enabled: d.isOnline
        target: networkConnectionStore.networkConnectionModuleInst
        function onNetworkConnectionStatusUpdate(website: string, completelyDown: bool, connectionState: int, chainIds: string, lastCheckedAt: int)  {
            if (website === root.websiteDown) {
                let anyChanged = false
                if (connectionState !== root.connectionState) {
                    anyChanged = true
                    root.connectionState = connectionState
                }
                const splitChainIds = chainIds.split(";")
                if (splitChainIds !== root.chainIdsDown) {
                    anyChanged = true
                    root.chainIdsDown = splitChainIds
                }
                if (completelyDown !== root.completelyDown) {
                    anyChanged = true
                    root.completelyDown = completelyDown
                }
                root.lastCheckedAt = LocaleUtils.formatDateTime(new Date(lastCheckedAt*1000))
                if (anyChanged)
                    root.updateBanner()
            }
        }
    }
}
