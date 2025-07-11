import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import utils

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
                border.color: Theme.palette.separator
            }
        }

        StatusBaseText {
            id: text

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            color: Theme.palette.directColor1
            font.pixelSize: Theme.secondaryAdditionalTextSize
            elide: Text.ElideRight
        }
    }
}
