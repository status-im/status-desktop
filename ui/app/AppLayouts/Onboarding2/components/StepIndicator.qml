import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

ColumnLayout {
    id: root

    required property int currentStep
    required property int totalSteps
    required property string caption

    StatusBaseText {
        Layout.fillWidth: true
        text: qsTr("Step %1 of %2").arg(root.currentStep).arg(root.totalSteps)
        font.pixelSize: Theme.additionalTextSize
        color: Theme.palette.baseColor1
        horizontalAlignment: Text.AlignHCenter
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 2
        Repeater {
            model: root.totalSteps
            Rectangle {
                width: 80
                height: 4
                radius: 2
                color: index <= root.currentStep - 1 ? Theme.palette.primaryColor1 : Theme.palette.baseColor2
            }
        }
    }
    StatusBaseText {
        Layout.fillWidth: true
        text: root.caption
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
}
