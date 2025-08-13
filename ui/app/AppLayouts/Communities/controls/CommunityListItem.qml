import QtQuick

import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme

StatusListItem {
    property alias checked: checkBox.checked
    property alias checkState: checkBox.checkState
    readonly property alias checkBox: checkBox

    implicitHeight: 44
    leftPadding: 8
    rightPadding: 3
    statusListItemTitle.font.pixelSize: Theme.additionalTextSize

    statusListItemTitleArea.anchors.leftMargin: 8

    asset.bgWidth: 32
    asset.bgHeight: 32

    asset.isLetterIdenticon: true
    asset.letterSize: 12
    asset.width: 32
    asset.height: 32

    components: [
        StatusCheckBox {
            id: checkBox

            size: StatusCheckBox.Size.Small
            rightPadding: 0
        }
    ]

    // using StatusMouseArea instead of build-in 'clicked' signal to avoid
    // intercepting event by the StatusCheckBox
    StatusMouseArea {
        anchors.fill: parent
        onClicked: {
            checkBox.toggle()
            checkBox.toggled()
        }
        cursorShape: Qt.PointingHandCursor
    }
}
