import QtQuick
import QtQuick.Controls

import AppLayouts.Wallet.controls
import StatusQ.Controls
import Storybook

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusButton {
            anchors.centerIn: parent
            text: "Launch popup"
            onClicked: dialog.open()
        }

        StatusDateRangePicker {
            id: dialog
            anchors.centerIn: parent
            destroyOnClose: false
            fromTimestamp: new Date().setDate(new Date().getDate() - 7) // 7 days ago
            onNewRangeSet: (fromTimestamp, toTimestamp) => {
                console.warn(" from timeStamp = ", new Date(fromTimestamp).toISOString())
                console.warn(" to timeStamp = ", new Date(toTimestamp).toISOString())
            }
        }

        Component.onCompleted: dialog.open()
    }
}

// status: good
// category: Components
