import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1

Rectangle {
    id: root

    property var buttonGroup
    property string btnText: qsTr("TODO")
    property bool checkedByDefault: false

    signal checked()
    signal toggled(bool checked)

    function toggle() {
        radioBtn.toggle()
    }

    border.color: mouseArea.containsMouse || radioBtn.checked ? Style.current.primary : Style.current.border
    border.width: 1
    color: Style.current.transparent
    implicitWidth: 130
    implicitHeight: 120
    radius: Style.current.radius

    StatusRadioButton {
        id: radioBtn
        ButtonGroup.group: buttonGroup
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        checked: root.checkedByDefault
        onCheckedChanged: {
            if (checked) {
                root.checked()
            }
        }
    }

    StyledText {
        id: txt
        text: btnText
        font.pixelSize: 15
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: radioBtn.bottom
        anchors.topMargin: 6
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (radioBtn.checked)
                return
            radioBtn.toggle()
            root.toggled(radioBtn.checked)
        }
    }
}
