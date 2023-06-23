import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Communities.panels 1.0

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
