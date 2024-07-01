import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    StatusBaseText {
        text: qsTr("Max fees:")

        font.pixelSize: 12
        color: Theme.palette.directColor1
    }
    StatusBaseText {
        id: maxFeesDisplay
        text: root.maxFeesText

        visible: !!root.maxFeesText

        font.pixelSize: 16
        font.weight: Font.DemiBold
    }
    StatusBaseText {
        text: qsTr("No fees")

        visible: !maxFeesDisplay.visible

        font.pixelSize: maxFeesDisplay.font.pixelSize
        font.weight: maxFeesDisplay.font.weight
    }
}
