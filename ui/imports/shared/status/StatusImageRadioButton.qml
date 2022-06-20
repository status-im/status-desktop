import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Universal 2.12

import utils 1.0
import shared 1.0
import shared.panels 1.0
import "./"

import StatusQ.Controls 0.1 as StatusQControls

Rectangle {
    id: root

    property int padding: Style.current.padding
    property alias control: radioControl
    property alias image: img
    property bool isHovered: false
    signal radioCheckedChanged(checked: bool)

    width: Style.dp(312)
    height: Style.dp(258)
    color: radioControl.checked ? Style.current.secondaryBackground :
                                  (isHovered ? Style.current.backgroundHover : Style.current.transparent)

    radius: Style.current.radius

    SVGImage {
        id: img
        anchors.top: parent.top
        anchors.topMargin: root.padding
        anchors.left: parent.left
        anchors.leftMargin: root.padding
        anchors.right: parent.right
        anchors.rightMargin: root.padding
    }

    StatusQControls.StatusRadioButton {
        id: radioControl
        anchors.top: img.bottom
        anchors.topMargin: root.padding
        anchors.left: parent.left
        anchors.leftMargin: root.padding
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: {
            root.radioCheckedChanged(!radioControl.checked)
        }
        cursorShape: Qt.PointingHandCursor
    }
}
