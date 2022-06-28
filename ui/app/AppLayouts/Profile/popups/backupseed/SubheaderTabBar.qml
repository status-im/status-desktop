import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import shared.panels 1.0
import utils 1.0

ColumnLayout {
    id: root

    property int steps: 4
    property int currentIndex: 0

    spacing: Style.current.halfPadding

    StyledText {
        id: txtDesc
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: Style.current.additionalTextSize
        color: Style.current.secondaryText
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
