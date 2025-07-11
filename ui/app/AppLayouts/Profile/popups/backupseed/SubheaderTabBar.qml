import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core.Theme
import StatusQ.Core

import shared.panels
import utils

ColumnLayout {
    id: root

    property int steps: 4
    property int currentIndex: 0

    spacing: Theme.halfPadding

    StyledText {
        id: txtDesc
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.additionalTextSize
        color: Theme.palette.secondaryText
        text: qsTr("Step %1 of %2").arg(root.currentIndex + 1).arg(steps)
        Layout.fillWidth: true
    }

    TabBar {
        id: bar
        height: 4
        spacing: 2
        background: null
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 59 * steps

        Repeater {
            model: steps

            SubheaderTabButton { index: modelData; currentIndex: root.currentIndex}
        }
    }
}
