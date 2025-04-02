import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusIcon {
    id: root

    required property string textToCopy

    readonly property bool hovered: mouseArea.containsMouse

    icon: "copy"
    color: mouseArea.containsMouse? Theme.palette.primaryColor1 : Theme.palette.baseColor1

    function reset() {
        root.icon = "copy"
        root.color = Qt.binding(function(){ return mouseArea.containsMouse? Theme.palette.primaryColor1 : Theme.palette.baseColor1 })
    }

    StatusMouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            ClipboardUtils.setText(root.textToCopy)
            root.icon = "tiny/checkmark"
            root.color = Theme.palette.successColor1

            Backpressure.debounce(root, 1500, function () {
                root.reset()
            })()
        }
    }
}
