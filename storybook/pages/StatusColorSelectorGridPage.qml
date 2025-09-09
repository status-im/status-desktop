import QtQuick

import StatusQ.Core
import StatusQ.Controls

Item {
    id: root

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

// category: Components
// status: good
