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

            Layout.horizontalStretchFactor: 1
            Layout.fillWidth: true
            Layout.preferredWidth: 0

            StatusBaseText {
                id: titleText

                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 0

                color: Theme.palette.directColor1
                font.pixelSize: Theme.fontSize(26)
                font.bold: true

                elide: Text.ElideRight
            }

            StatusBaseText {
                id: subtitleText

                Layout.leftMargin: 6
                Layout.topMargin: 6
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                Layout.horizontalStretchFactor: 1

                visible: !!text
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.primaryTextFontSize
                elide: Text.ElideRight
            }
        }

        RowLayout {
            id: buttonsRow

            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            Layout.horizontalStretchFactor: 0
            Layout.fillWidth: true


            spacing: parent.spacing
            children: root.buttons

            visible: children.length
        }
    }
}
