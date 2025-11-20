import QtQuick

import StatusQ
import StatusQ.Core
import StatusQ.Controls

import utils

import shared.stores

Loader {
    id: root
    active: false

    property NetworkConnectionStore networkConnectionStore
    readonly property string jointChainIdString: networkConnectionStore.getChainIdsJointString(chainIdsDown)
    property string websiteDown
    property int connectionState: Constants.ConnectionStatus.Retrying
    property var chainIdsDown: []
    property bool completelyDown: false
    property double lastCheckedAtUnix: -1
    property string lastCheckedAt
    property bool withCache: false
    property string tooltipMessage
    property string toastText

    property bool relevantForCurrentSection: true
    onRelevantForCurrentSectionChanged: updateBanner(false)

    function updateBanner(showOnlineBanners = true) {
        // if offline or irrelevant, hide the item
        if (!networkChecker.isOnline || !relevantForCurrentSection) {
            if (!!item)
                item.hide()
            return
        }

        root.active = true
        if (connectionState === Constants.ConnectionStatus.Failure)
            item.show()
        else if (showOnlineBanners)
            item.showFor(3000)
    }

    // strict online/offline checker, doesn't care about the wallet services
    readonly property var networkChecker: NetworkChecker {
        id: networkChecker

        onIsOnlineChanged: updateBanner()
    }

    sourceComponent: ModuleWarning {
        delay: false
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
                root.lastCheckedAt = LocaleUtils.formatDateTime(new Date(lastCheckedAtUnix*1000), Locale.ShortFormat)
                root.updateBanner()
            }
        }
    }
}
