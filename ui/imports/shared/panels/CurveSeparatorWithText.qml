import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

RowLayout {
    id: root

    property string text

    Layout.preferredHeight: 32

    Canvas {
        property int cornerRadius: 9
        property int lineWidth: 2
        property int verticalLine: 12
        property int horizontalLine: 19

        width: horizontalLine + cornerRadius
        height: verticalLine + lineWidth + cornerRadius
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 12
        contextType: "2d"
        onPaint: {
            context.reset();
            context.beginPath()
            context.moveTo(width, lineWidth)
            context.arc(cornerRadius + lineWidth, cornerRadius + lineWidth, cornerRadius, 3 * Math.PI / 2, Math.PI, true/*anticlockwise*/)
            context.lineTo(lineWidth, cornerRadius + verticalLine + lineWidth)
            context.strokeStyle = Style.current.separator
            context.lineWidth = 2
            context.stroke()
        }
    }
    StatusBaseText {
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 2
        text: root.text
        color: Theme.palette.directColor1
        font.pixelSize: 17
    }
}
