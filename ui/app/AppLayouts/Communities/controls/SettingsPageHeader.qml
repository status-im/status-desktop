import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

Control {
    id: root

    property alias title: titleText.text
    property alias subtitle: subtitleText.text

    property list<Item> buttons

    contentItem: RowLayout {
        spacing: 9

        RowLayout {
            Layout.alignment: Qt.AlignVCenter

            StatusBaseText {
                id: titleText

                color: Theme.palette.directColor1
                font.pixelSize: Theme.fontSize26
                font.bold: true
            }

            StatusBaseText {
                id: subtitleText

                Layout.leftMargin: 6
                Layout.topMargin: 6

                visible: !!text
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.primaryTextFontSize
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
