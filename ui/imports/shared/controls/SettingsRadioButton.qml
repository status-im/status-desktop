import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

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
        font.pixelSize: 13
        color: Theme.palette.directColor1
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