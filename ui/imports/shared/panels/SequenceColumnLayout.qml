import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

ColumnLayout {
    id: root

    property alias title: text.text

    readonly property int lineWidth: 2
    readonly property int lineHeight: 24
    readonly property int lineMargin: 15

    readonly property int curvedLineWidth: 29
    readonly property int curvedLineHeight: 21
    readonly property int curvedLineRadius: 9
    readonly property int curvedLineToTextSpacing: 4

    spacing: 0

    component Separator: Rectangle {
        Layout.leftMargin: parent.lineMargin
        Layout.preferredWidth: parent.lineWidth
        Layout.preferredHeight: parent.lineHeight
        color: Theme.palette.baseColor4
    }

    RowLayout {
        visible: !!root.title

        Layout.preferredHeight: text.implicitHeight / 2 + root.curvedLineHeight
        Layout.fillWidth: true
        Layout.leftMargin: root.lineMargin

        Item {
            Layout.preferredWidth: root.curvedLineWidth
            Layout.preferredHeight: root.curvedLineHeight
            Layout.alignment: Qt.AlignBottom

            clip: true

            Rectangle {
                width: parent.width * 2
                height: parent.height * 2
                radius: root.curvedLineRadius

                color: "transparent"
                border.width: root.lineWidth
                border.color: Theme.palette.baseColor4
            }
        }

        StatusBaseText {
            id: text

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            color: Theme.palette.directColor1
            font.pixelSize: Theme.primaryTextFontSize + 2
            elide: Text.ElideRight
        }
    }
}
