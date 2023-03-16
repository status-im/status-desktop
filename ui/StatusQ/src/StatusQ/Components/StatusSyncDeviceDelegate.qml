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
    property int timestamp: 0

    signal itemClicked
    signal setupSyncingButtonClicked

    title: root.deviceName || qsTr("No device name")

    asset.name: Utils.deviceIcon(root.deviceType)
    asset.bgColor: Theme.palette.primaryColor3
    asset.color: Theme.palette.primaryColor1
    asset.isLetterIdenticon: false

    subTitle: {
        if (root.isCurrentDevice)
            return qsTr("This device");

        if (d.secondsFromSync <= 120)
            return qsTr("Online now");

        if (d.minutesFromSync <= 60)
            return qsTr("Online %n minutes(s) ago", "", d.minutesFromSync);

        if (d.daysFromSync == 0)
            return qsTr("Last seen earlier today");

        if (d.daysFromSync == 1)
            return qsTr("Last online yesterday");

        if (d.daysFromSync <= 6)
            return qsTr("Last online [%1]").arg(Qt.locale().dayName[d.lastSyncDate.getDay()]);

        return qsTr("Last online %1").arg(LocaleUtils.formatDate(lastSyncDate))
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

        readonly property var lastSyncDate: new Date(root.timestamp)
        readonly property int millisecondsFromSync: lastSyncDate - Date.now()
        readonly property int secondsFromSync: millisecondsFromSync / 1000
        readonly property int minutesFromSync: secondsFromSync / 60
        readonly property int daysFromSync: new Date().getDay() - lastSyncDate.getDay()
        readonly property bool onlineNow: d.secondsFromSync <= 120
    }

    Component {
        id: onlineBadgeComponent

        StatusOnlineBadge {
            online: d.onlineNow
        }
    }
}
