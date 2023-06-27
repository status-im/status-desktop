import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Control {
    id: root

    property alias title: titleText.text
    property alias subtitle: subtitleText.text

    property list<StatusButton> buttons

    contentItem: RowLayout {
        spacing: 9

        RowLayout {
            Layout.alignment: Qt.AlignVCenter

            StatusBaseText {
                id: titleText

                color: Theme.palette.directColor1
                font.pixelSize: 26
                font.bold: true
            }

            StatusBaseText {
                id: subtitleText

                Layout.leftMargin: 6
                Layout.topMargin: 6

                visible: !!text
                color: Theme.palette.baseColor1
                font.pixelSize: 15
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: buttonsRow

            spacing: parent.spacing
            children: root.buttons

            visible: children.length
        }
    }
}
