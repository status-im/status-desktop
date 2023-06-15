import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1

StatusListItem {
    id: root

    property string deviceName: ""
    property string deviceType: ""
    property bool deviceEnabled
    property real timestamp: 0
    property bool isCurrentDevice: false
    property bool showOnlineBadge: !isCurrentDevice

    signal itemClicked
    signal setupSyncingButtonClicked

    title: root.deviceName || qsTr("Unknown device")

    asset.name: Utils.deviceIcon(root.deviceType)
    asset.bgColor: Theme.palette.primaryColor3
    asset.color: Theme.palette.primaryColor1
    asset.isLetterIdenticon: false

    subTitle: {
        if (root.isCurrentDevice)
            return qsTr("This device")

        if (d.onlineNow)
            return qsTr("Online now")

        if (d.minutesFromSync <= 60)
            return qsTr("Online %n minute(s) ago", "", d.minutesFromSync)

        if (d.daysFromSync == 0)
            return qsTr("Last seen earlier today")

        if (d.daysFromSync == 1)
            return qsTr("Last online yesterday")

        if (d.daysFromSync <= 6)
            return qsTr("Last online: %1").arg(LocaleUtils.formatRelativeTimestamp(d.deviceLastTimestamp))

        return qsTr("Last online: %1").arg(LocaleUtils.formatDate(d.deviceLastTimestamp))
    }

    subTitleBadgeComponent: root.showOnlineBadge ? onlineBadgeComponent : null

    components: [
        StatusButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.enabled && !root.deviceEnabled && !root.isCurrentDevice
            text: qsTr("Setup syncing")
            size: StatusBaseButton.Size.Small
            onClicked: {
                root.setupSyncingButtonClicked()
            }
        },
        StatusIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.deviceEnabled
            icon: "next"
            color: Theme.palette.baseColor1
        }
    ]

    QtObject {
        id: d

        property real now: 0
        readonly property real deviceLastTimestamp: root.timestamp / 1000000
        readonly property int secondsFromSync: (now - Math.max(0, d.deviceLastTimestamp)) / 1000
        readonly property int minutesFromSync: secondsFromSync / 60
        readonly property int daysFromSync: LocaleUtils.daysBetween(new Date(now), new Date(d.deviceLastTimestamp))
        readonly property bool onlineNow: secondsFromSync <= 120

        // We know if the device is paired (aka syncing is set up), if we have it's metadata
        readonly property bool paired: root.deviceName
    }

    Timer {
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: root.showOnlineBadge && root.visible
        onTriggered: {
            d.now = Date.now()
        }
    }

    Component {
        id: onlineBadgeComponent

        StatusOnlineBadge {
            online: d.onlineNow
        }
    }
}
