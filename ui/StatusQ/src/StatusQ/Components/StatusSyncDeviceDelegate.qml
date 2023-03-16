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
    property bool isCurrentDevice: false
    property real timestamp: 0

    signal itemClicked
    signal setupSyncingButtonClicked

    title: root.deviceName || qsTr("No device name")

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

        const date = new Date(root.timestamp)

        if (d.daysFromSync <= 6)
            return qsTr("Last online [%1]").arg(LocaleUtils.getDayName(date))

        return qsTr("Last online %1").arg(LocaleUtils.formatDate(date))
    }

    subTitleBadgeComponent: root.isCurrentDevice ? null : onlineBadgeComponent

    components: [
        StatusButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.enabled && !root.isCurrentDevice
            text: qsTr("Setup syncing")
            size: StatusBaseButton.Size.Small
            onClicked: {
                root.setupSyncingButtonClicked()
            }
        },
        StatusIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.enabled
            icon: "chevron-down"
            rotation: 270
            color: Theme.palette.baseColor1
        }
    ]

    QtObject {
        id: d

        property real now: 0
        readonly property int secondsFromSync: (now - Math.max(0, root.timestamp)) / 1000
        readonly property int minutesFromSync: secondsFromSync / 60
        readonly property int hoursFromSync: minutesFromSync / 60
        readonly property int daysFromSync: hoursFromSync / 24
        readonly property bool onlineNow: secondsFromSync <= 120
    }

    Timer {
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: !root.isCurrentDevice && root.visible
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

    tertiaryTitle: `${root.timestamp} ${d.now} --- ${d.secondsFromSync}`
}
