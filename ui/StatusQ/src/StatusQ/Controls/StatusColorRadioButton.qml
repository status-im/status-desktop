import QtQuick 2.13
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1

RadioButton {
    id: control

    property string radioButtonColor: ""
    property string selectionColor: StatusColors.colors['white']
    property int diameter: 48
    property int selectorDiameter: 20

    implicitWidth: 48
    implicitHeight: 48

    indicator: Rectangle {
        implicitWidth: control.diameter
        implicitHeight: control.diameter
        radius: width/2
        color: radioButtonColor

        Rectangle {
            width: control.selectorDiameter
            height: control.selectorDiameter
            radius: width/2
            color: selectionColor
            border.color: StatusColors.colors['grey3']
            visible: control.checked
            anchors.centerIn: parent
        }
    }
}

