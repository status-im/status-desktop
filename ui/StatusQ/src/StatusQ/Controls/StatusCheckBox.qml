import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1


CheckBox {
    id: statusCheckBox

    indicator: Rectangle {
        implicitWidth: 18
        implicitHeight: 18
        x: statusCheckBox.leftPadding
        y: parent.height / 2 - height / 2
        radius: 2
        color: (statusCheckBox.down || statusCheckBox.checked) ? Theme.palette.primaryColor1
                                                               : Theme.palette.directColor8

        StatusIcon {
            icon: "checkbox"
            width: 11
            height: 8
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 1
            color: Theme.palette.white
            visible: statusCheckBox.down || statusCheckBox.checked
        }
    }

    contentItem: StatusBaseText {
        text: statusCheckBox.text
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        width: parent.width
        leftPadding: !!statusCheckBox.text ? statusCheckBox.indicator.width + statusCheckBox.spacing
                                           : statusCheckBox.indicator.width
    }
}
