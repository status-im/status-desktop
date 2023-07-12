import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1


Control {
    id: root

    property alias title: titleComponent.text
    property alias text: textComponent.text
    property alias buttonText: button.text
    property alias buttonVisible: button.visible

    signal clicked

    verticalPadding: 40
    horizontalPadding: 56

    background: Rectangle {
        color: Theme.palette.statusListItem.backgroundColor
        radius: 8
        border.color: Theme.palette.baseColor2
    }

    contentItem: ColumnLayout {
        StatusBaseText {
            id: titleComponent

            Layout.fillWidth: true

            wrapMode: Text.Wrap
            font.pixelSize: 17
            font.weight: Font.Bold

            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.directColor1
        }

        StatusBaseText {
            id: textComponent

            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 16

            wrapMode: Text.Wrap
            font.pixelSize: 15
            lineHeight: 1.2

            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.baseColor1
        }

        StatusButton {
            id: button

            Layout.alignment: Qt.AlignHCenter

            visible: true

            onClicked: root.clicked()
        }
    }
}
