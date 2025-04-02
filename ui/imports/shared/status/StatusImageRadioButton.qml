import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import shared 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property int padding: Theme.halfPadding
    property alias control: radioControl
    property alias image: img
    property bool isHovered: false
    signal radioCheckedChanged(bool checked)

    implicitWidth: 208
    implicitHeight: layout.height
    color: radioControl.checked ? Theme.palette.secondaryBackground :
                                  (isHovered ? Theme.palette.backgroundHover : Theme.palette.transparent)

    radius: Theme.radius

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

    StatusMouseArea {
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
