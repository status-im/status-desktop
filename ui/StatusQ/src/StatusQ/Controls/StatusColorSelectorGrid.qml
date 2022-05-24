import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "./"

Column {
    id: root

    property alias titleText: title.text
    property alias title: title
    property alias columns: grid.columns

    property int selectedColorIndex: 0
    property string selectedColor: ""
    property var model:[ StatusColors.colors['black'],
                         StatusColors.colors['grey'],
                         StatusColors.colors['blue2'],
                         StatusColors.colors['purple'],
                         StatusColors.colors['cyan'],
                         StatusColors.colors['violet'],
                         StatusColors.colors['red2'],
                         StatusColors.colors['yellow'],
                         StatusColors.colors['green2'],
                         StatusColors.colors['moss'],
                         StatusColors.colors['brown'],
                         StatusColors.colors['brown2'] ]

    signal colorSelected(color color)

    spacing: 16

    StatusBaseText {
        id: title
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 13
        color: Theme.palette.baseColor1
    }

    Grid {
        id: grid
        columns: 6
        rowSpacing: 16
        columnSpacing: 32
        Repeater {
            model: root.model
            delegate: StatusColorRadioButton {
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
