import QtQuick 2.13
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1

RadioButton {
    id: control

    property string radioButtonColor: ""
    property string selectionColor: StatusColors.colors['white']
    property int diameter: 44
    property int selectorDiameter: 16

    spacing: 0

    implicitWidth: 44
    implicitHeight: 44

    indicator: Rectangle {
        implicitWidth: control.diameter
        implicitHeight: control.diameter
        radius: width/2
        color: radioButtonColor

        Rectangle {
            anchors.centerIn: parent
            width: control.selectorDiameter
            height: control.selectorDiameter
            visible: control.checked
            radius: width/2
            color: selectionColor
            border.color: StatusColors.colors['grey3']
        }
    }
}

