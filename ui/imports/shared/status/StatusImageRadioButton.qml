import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14

import utils 1.0
import shared 1.0
import shared.panels 1.0
import "./"

import StatusQ.Controls 0.1 as StatusQControls

Rectangle {
    id: root

    property int padding: Style.current.halfPadding
    property alias control: radioControl
    property alias image: img
    property bool isHovered: false
    signal radioCheckedChanged(bool checked)

    implicitWidth: 208
    implicitHeight: layout.height
    color: radioControl.checked ? Style.current.secondaryBackground :
                                  (isHovered ? Style.current.backgroundHover : Style.current.transparent)

    radius: Style.current.radius

    ColumnLayout {
        id: layout
        width: parent.width
        spacing: root.padding

        SVGImage {
            id: img
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.width - root.padding*2
        }

        StatusQControls.StatusRadioButton {
            id: radioControl
            Layout.fillWidth: true
            Layout.leftMargin: root.padding
            Layout.rightMargin: root.padding
        }
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
