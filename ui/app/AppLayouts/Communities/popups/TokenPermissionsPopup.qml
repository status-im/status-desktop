import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Popups.Dialog

import AppLayouts.Communities.panels

StatusDialog {
    id: root

    property string channelName
    property alias viewOnlyHoldingsModel: overlayPanel.viewOnlyHoldingsModel
    property alias viewAndPostHoldingsModel: overlayPanel.viewAndPostHoldingsModel
    property alias moderateHoldingsModel: overlayPanel.moderateHoldingsModel

    property alias assetsModel: overlayPanel.assetsModel
    property alias collectiblesModel: overlayPanel.collectiblesModel

    title: qsTr("Token permissions for %1 channel").arg(root.channelName)
    footer.visible: false

    padding: 0

    StatusScrollView {
        anchors.fill: parent

        JoinPermissionsOverlayPanel {
            id: overlayPanel

            joinCommunity: false
            channelName: root.channelName
            showOnlyPanels: true
        }
    }
}
