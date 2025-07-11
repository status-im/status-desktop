import QtQuick

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

Item {
    id: root
    width: 800
    height: 100

    Row {
        id: selectedColor
        anchors.top: parent.top
        anchors.left: colorSelectionGrid.left
        spacing: 10
        StatusBaseText {
            text: "SelectedColor is"
        }
        Rectangle {
            width: 100
            height: 20
            radius: width/2
            color: colorSelectionGrid.selectedColor
        }
    }

    StatusColorSelectorGrid {
        id: colorSelectionGrid
        anchors.top: selectedColor.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        titleText: "COLOR"
        selectedColorIndex: 2
    }
}
