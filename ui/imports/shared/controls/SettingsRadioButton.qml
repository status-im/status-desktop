import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls

Item {
    property string label
    property alias checked: radioButton.checked
    property ButtonGroup group
    signal clicked()

    id: root
    width: childrenRect.width
    height: 24

    StatusRadioButton {
        id: radioButton
        ButtonGroup.group: root.group
    }

    StatusBaseText {
        text: root.label
        color: Theme.palette.directColor1
        font.pixelSize: Theme.additionalTextSize
        anchors.left: radioButton.right
        anchors.leftMargin: 12
        anchors.verticalCenter: radioButton.verticalCenter
    }

    StatusMouseArea {
        enabled: !radioButton.checked
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }              
}