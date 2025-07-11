import QtQuick
import QtQuick.Layouts

import StatusQ.Core.Theme
import StatusQ.Core
import StatusQ.Controls

StatusRadioButton {
    id: root
    implicitHeight: 34
    property bool checkedState: false
    contentItem: StatusBaseText {
        width: parent.width
        font.pixelSize: Theme.additionalTextSize
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        color: Theme.palette.directColor1
        leftPadding: 14
        rightPadding: 24
        text: root.text
    }
    indicator: StatusIcon {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        icon: "checkbox"
        width: 12
        height: 12
        color: Theme.palette.primaryColor1
        visible: root.checkedState
    }
    background: Rectangle {
        color: root.hovered ? Theme.palette.baseColor2 : Theme.palette.statusModal.backgroundColor
    }
}
