import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

RadioButton {
    id: control

    property string radioButtonColor: ""
    property string selectionColor: StatusColors.colors['white']
    property int diameter: 44
    property int selectorDiameter: 16

    spacing: 0

    implicitWidth: 44
    implicitHeight: 44

    QtObject {
        id: d
        readonly property string yinYangColor: Utils.getYinYangColor(radioButtonColor)
    }

    indicator: Rectangle {
        implicitWidth: control.diameter
        implicitHeight: control.diameter
        radius: width/2
        color: radioButtonColor
        border.width: 1
        border.color: Theme.palette.directColor7

        Item {
            id: dualColor
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width/2
            height: parent.height
            clip: true
            Rectangle {
                width: parent.height
                height: parent.height
                radius: width/2
                color: d.yinYangColor
            }
            visible: !!d.yinYangColor
        }

        Rectangle {
            anchors.centerIn: parent
            width: control.selectorDiameter
            height: control.selectorDiameter
            visible: control.checked
            radius: width/2
            color: selectionColor
            border.color: StatusColors.colors['grey3']
            border.width: 1
        }
    }

    HoverHandler {
        enabled: control.enabled
        cursorShape: Qt.PointingHandCursor
    }
}

