import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

StatusTextField {
    topPadding: 12
    bottomPadding: 12
    background: null
    font.pixelSize: 27
    font.weight: Font.DemiBold
    color: Theme.palette.white
    placeholderTextColor: Qt.rgba(1, 1, 1, 0.3)

    StatusClearButton {
        anchors.right: parent.right
        anchors.rightMargin: parent.rightPadding
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        visible: parent.text && parent.cursorVisible
        icon.width: 24
        icon.height: 24
        icon.color: Theme.palette.white
        tooltip.color: "#222833"
        onClicked: parent.clear()
    }
}
