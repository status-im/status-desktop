import QtQuick
import QtQuick.Layouts
import AppLayouts.ActivityCenter.helpers

import StatusQ.Core.Theme

ColumnLayout {
    id: root

    // Properties related to the different notification types / groups:
    required property bool hasAdmin
    required property bool hasMentions
    required property bool hasReplies
    required property bool hasContactRequests
    required property bool hasMembership
    required property int activeGroup

    // Style:
    property color backgroundColor: Theme.palette.baseColor4

    signal setActiveGroupRequested(int group)

    ActivityCenterPopupTopBarPanel {
        id: topBarPanel
        Layout.fillWidth: true

        hasAdmin: root.hasAdmin
        hasReplies: root.hasReplies
        hasMentions: root.hasMentions
        hasContactRequests: root.hasContactRequests
        hasMembership: root.hasMembership
        activeGroup: root.activeGroup

        gradientColor: root.backgroundColor

        onSetActiveGroupRequested: root.setActiveGroupRequested(group)
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 50

        color: "green"
    }
}
