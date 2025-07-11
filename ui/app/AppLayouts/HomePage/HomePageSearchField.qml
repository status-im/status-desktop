import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

StatusTextField {
    leftPadding: 0
    rightPadding: 0
    topPadding: 12
    bottomPadding: 12
    background: null
    font.pixelSize: Theme.fontSize27
    font.weight: Font.DemiBold

    StatusClearButton {
        anchors.right: parent.right
        anchors.rightMargin: parent.rightPadding
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        visible: parent.text
        icon.width: 24
        icon.height: 24
        onClicked: {
            parent.forceActiveFocus()
            parent.clear()
        }
    }
}
