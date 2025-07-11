import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

ColumnLayout {
    id: root

    property alias maxFeesText: maxFeesDisplay.text
    property alias feesTextColor: maxFeesDisplay.color

    StatusBaseText {
        text: qsTr("Max fees:")

        font.pixelSize: Theme.tertiaryTextFontSize
        color: Theme.palette.directColor1
    }
    StatusBaseText {
        id: maxFeesDisplay
        text: root.maxFeesText

        visible: !!text

        font.pixelSize: Theme.fontSize16

    }
    StatusBaseText {
        text: qsTr("No fees")

        visible: !maxFeesDisplay.visible

        font.pixelSize: maxFeesDisplay.font.pixelSize
        font.weight: maxFeesDisplay.font.weight
    }
}
