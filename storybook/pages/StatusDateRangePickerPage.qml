import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Wallet.controls 1.0
import StatusQ.Controls 0.1
import Storybook 1.0

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
            onNewRangeSet: {
                console.warn(" from timeStamp = ", new Date(fromTimestamp).toISOString())
                console.warn(" to timeStamp = ", new Date(toTimestamp).toISOString())
            }
        }

        Component.onCompleted: dialog.open()
    }
}
