import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "./"

Column {
    id: root

    property alias titleText: title.text
    property alias title: title
    property alias columns: grid.columns

    property int diameter: 48
    property int selectorDiameter: 20

    property int selectedColorIndex: 0
    property string selectedColor: ""
    property var model: Theme.palette.customisationColorsArray

    signal colorSelected(color color)

    spacing: 16

    StatusBaseText {
        id: title
        width: parent.width
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 13
        color: Theme.palette.baseColor1
    }

    Grid {
        id: grid
        columns: 6
        rowSpacing: 16
        columnSpacing: 32
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            objectName: "statusColorRepeater"
            model: root.model
            delegate: StatusColorRadioButton {
                implicitWidth: root.diameter
                implicitHeight: root.diameter
                diameter: root.diameter
                selectorDiameter: root.selectorDiameter
                checked: index === selectedColorIndex
                radioButtonColor: root.model[index] || "transparent"
                onCheckedChanged: {
                    if (checked) {
                        selectedColorIndex = index;
                        selectedColor = root.model[index];
                        root.colorSelected(selectedColor);
                    }
                }
            }
        }
    }
}
