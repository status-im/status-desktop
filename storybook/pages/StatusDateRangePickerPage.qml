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
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Launch popoup"
            onClicked: dialog.open()
        }

        StatusDateRangePicker {
            id: dialog
            anchors.centerIn: parent
            width: 440
            height: 300
            fromTimestamp: new Date().setDate(new Date().getDate() - 7)
            toTimestamp: Date.now()
            supportedStartYear: 1900
            onNewRangeSet: {
                console.warn(" from timeStamp = ", new Date(fromTimestamp).toISOString())
                console.warn(" to timeStamp = ", new Date(toTimestamp).toISOString())
            }
        }

        Component.onCompleted: dialog.open()

    }
}
