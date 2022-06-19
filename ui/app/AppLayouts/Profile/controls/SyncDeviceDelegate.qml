import QtQuick 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

StatusListItem {
    id: root

    property string emojiId: ""
    property color deviceColor: Theme.palette.primaryColor1

    signal itemClicked
    signal setupSyncingButtonClicked

    QtObject {
        id: d

        readonly property var lastSyncDate: new Date(model.timestamp)
        readonly property int millisecondsFromSync: lastSyncDate - Date.now()
        readonly property int secondsFromSync: millisecondsFromSync / 1000
        readonly property int minutesFromSync: secondsFromSync / 60
        readonly property int daysFromSync: new Date().getDay() - lastSyncDate.getDay()
    }

    title: model.name || qsTr("No device name")

    subTitle: {
        if (model.isCurrentDevice)
            return qsTr("This device");

        if (d.secondsFromSync <= 120)
            return qsTr("Online now");

        if (d.minutesFromSync <= 60)
            return qsTr("Online %1 minutes ago").arg(d.minutesFromSync);

        if (d.daysFromSync == 0)
            return qsTr("Last seen earlier today");

        if (d.daysFromSync == 1)
            return qsTr("Last online yesterday");

        if (d.daysFromSync <= 6)
            return qsTr("Last online [%1]").arg(d.daysOfWeek[d.lastSyncDate.getDay()]);

        return qsTr("Last online %1").arg(d.lastSyncDate.toLocaleDateString(Qt.locale()))
    }

    icon.name: !!root.emojiId ? "" : "desktop"
    icon.emoji: root.emojiId
    icon.background.color: root.deviceColor
    icon.isLetterIdenticon: false
    // label: qsTr("Next back up in %1 hours")

    components: [
        StatusButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.enabled && !model.isCurrentDevice
            text: qsTr("Setup syncing")
            size: StatusBaseButton.Size.Small
            onClicked: root.setupSyncingButtonClicked()
        },
        StatusIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.enabled
            icon: "chevron-down"
            rotation: 270
            color: Theme.palette.baseColor1
        }
    ]
}
