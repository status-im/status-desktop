import QtQuick 2.13
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1

RadioButton {
    id: control

    property string radioButtonColor: ""
    property string selectionColor: StatusColors.colors['white']

    implicitWidth: 48
    implicitHeight: 48

    indicator: Rectangle {
        implicitWidth: 48
        implicitHeight: 48
        radius: width/2
        color: radioButtonColor

        Rectangle {
            width: 20
            height: 20
            radius: width/2
            color: selectionColor
            border.color: StatusColors.colors['grey3']
            visible: control.checked
            anchors.centerIn: parent
        }
    }
}

