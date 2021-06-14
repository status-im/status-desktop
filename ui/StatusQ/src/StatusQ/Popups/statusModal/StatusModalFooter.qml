import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1


Rectangle {
    id: statusModalFooter

    property bool showBack: true

    property list<StatusBaseButton> buttons

    color: Theme.palette.statusModal.backgroundColor

    signal clicked(var buttonIndex)
    signal back

    radius: 6

    color: Theme.palette.indirectColor1

    onButtonsChanged: {
        for (let idx in buttons) {
            buttons[idx].parent = buttonsLayout
        }
    }

    implicitHeight: rootLayout.implicitHeight + 30

    RowLayout {
        id: rootLayout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 18

        StatusRoundButton {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            icon.name: "arrow-left"
            visible: statusModalFooter.showBack
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: 1
        }

        Row {
            id: buttonsLayout
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            spacing: 16

        }
    }

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: parent.radius
        color: parent.color
    }
}
