import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

RowLayout {
    property alias text: text.text

    implicitHeight: 32

    Item {
        readonly property int cornerRadius: 9
        readonly property int lineWidth: 2
        readonly property int verticalLine: 12
        readonly property int horizontalLine: 19

        Layout.preferredWidth: horizontalLine + cornerRadius
        Layout.preferredHeight: verticalLine + lineWidth + cornerRadius
        Layout.topMargin: 12

        clip: true

        Rectangle {
            width: parent.width * 2
            height: parent.height * 2
            color: "transparent"
            radius: parent.cornerRadius

            border.width: parent.lineWidth
            border.color: Style.current.separator
        }
    }

    StatusBaseText {
        id: text

        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 2

        color: Theme.palette.directColor1
        font.pixelSize: 17
    }
}
