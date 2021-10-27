import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1

StatusFlatRoundButton {
    id: control
    property bool selected: false
    icon.source: Style.svg("walletIcon")
    icon.width: 24
    icon.height: 24
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: control.hovered ? control.icon.color : "transparent"
        opacity: 0.1
        radius: 8
    }

    Rectangle {
        width: 16
        height: 16
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: 2
        visible: control.selected
        radius: width / 2
        color: Style.current.green
        SVGImage {
            id: checkmark
            source: Style.svg("checkmark")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: 10
            fillMode: Image.PreserveAspectFit
        }
    }
}
