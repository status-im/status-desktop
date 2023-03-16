import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Chat.panels.communities 1.0

StatusDialog {
    id: root

    property string channelName
    property alias viewOnlyHoldingsModel: overlayPanel.viewOnlyHoldingsModel
    property alias viewAndPostHoldingsModel: overlayPanel.viewAndPostHoldingsModel
    property alias moderateHoldingsModel: overlayPanel.moderateHoldingsModel

    property alias assetsModel: overlayPanel.assetsModel
    property alias collectiblesModel: overlayPanel.collectiblesModel

    QtObject {
        id: d

        readonly property int maxWidth: 640
        readonly property int minWidth: 300
        readonly property int maxHeight: 480

        function getVerticalPadding() {
            return root.topPadding + root.bottomPadding
        }

        function getHorizontalPadding() {
            return root.leftPadding + root.rightPadding
        }

        function getMaxMinWidth() {
            return Math.max(overlayPanel.implicitWidth, d.minWidth)
        }
    }

    title: qsTr("Token permissions for %1 channel").arg(root.channelName)
    footer.visible: false
    implicitWidth: Math.min(d.getMaxMinWidth(), d.maxWidth) + d.getHorizontalPadding()
    implicitHeight: Math.min(overlayPanel.implicitHeight + d.getVerticalPadding() + root.header.height, d.maxHeight)
    contentItem: StatusScrollView {
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        contentHeight: overlayPanel.implicitHeight
        contentWidth: overlayPanel.implicitWidth
        padding: 0

        JoinPermissionsOverlayPanel {
            id: overlayPanel

            anchors.centerIn: parent
            joinCommunity: false
            channelName: root.channelName
            showOnlyPanels: true
        }
    }
}
