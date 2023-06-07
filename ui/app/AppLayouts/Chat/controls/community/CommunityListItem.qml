import QtQuick 2.14

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

StatusListItem {
    property alias checked: checkBox.checked
    property alias checkState: checkBox.checkState
    readonly property alias checkBox: checkBox

    implicitHeight: 44
    leftPadding: 8
    rightPadding: 3
    statusListItemTitle.font.pixelSize: 13

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

    // using MouseArea instead of build-in 'clicked' signal to avoid
    // intercepting event by the StatusCheckBox
    MouseArea {
        anchors.fill: parent
        onClicked: {
            checkBox.toggle()
            checkBox.toggled()
        }
        cursorShape: Qt.PointingHandCursor
    }
}
