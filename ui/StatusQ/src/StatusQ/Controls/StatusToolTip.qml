import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

ToolTip {
    id: statusToolTip

    enum Orientation {
        Top,
        Bottom,
        Left,
        Right
    }

    property int maxWidth: 800
    property int orientation: StatusToolTip.Orientation.Top
    property int offset: 0
    property alias arrow: arrow
    property color color: Theme.palette.black

    implicitWidth: Math.min(maxWidth, implicitContentWidth + 16)
    padding: 8
    margins: 8
    delay: 200
    background: Item {
        id: statusToolTipBackground
        Rectangle {
            id: statusToolTipContentBackground
            color: statusToolTip.color
            radius: 8
            anchors.fill: parent
            anchors.bottomMargin: 8
        }
        Rectangle {
            id: arrow
            color: statusToolTipContentBackground.color
            height: 20
            width: 20
            rotation: 45
            radius: 1
            x: {
                if (orientation === StatusToolTip.Orientation.Top || orientation === StatusToolTip.Orientation.Bottom) {
                    return statusToolTipBackground.width / 2 - width / 2 + offset
                }
                if (orientation === StatusToolTip.Orientation.Left) {
                    return statusToolTipContentBackground.width - (width / 2) - 8 + offset
                }
                if (orientation === StatusToolTip.Orientation.Right) {
                    return -width/2 + 8 + offset
                }
            }
            y: {
                if (orientation === StatusToolTip.Orientation.Bottom) {
                    return -height / 2 + 5
                }
                if (orientation === StatusToolTip.Orientation.Top) {
                    return statusToolTipBackground.height - height - 5
                }
                if (orientation === StatusToolTip.Orientation.Left || orientation === StatusToolTip.Orientation.Right) {
                    return statusToolTipContentBackground.height / 2 - (height / 2)
                }
            }
        }
    }
    contentItem: StatusBaseText {
        text: statusToolTip.text
        color: Theme.palette.white
        linkColor: Theme.palette.white
        wrapMode: Text.Wrap
        font.pixelSize: Theme.additionalTextSize
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        bottomPadding: 8
        textFormat: Text.RichText
        elide: Text.ElideRight
    }
}
