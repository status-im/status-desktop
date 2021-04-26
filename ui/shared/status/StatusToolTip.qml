import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"

ToolTip {
    id: tooltip

    enum Orientation {
        Top,
        Bottom,
        Left,
        Right
    }

    property int maxWidth: 800
    property int orientation: StatusToolTip.Orientation.Top

    implicitWidth: Math.min(maxWidth, textContent.implicitWidth + Style.current.bigPadding)
    leftPadding: Style.current.smallPadding
    rightPadding: Style.current.smallPadding
    topPadding: Style.current.smallPadding
    bottomPadding: Style.current.smallPadding
    delay: 200
    background: Item {
        id: tooltipBg
        Rectangle {
            id: tooltipContentBg
            color: Style.current.tooltipBackgroundColor
            radius: Style.current.radius
            anchors.fill: parent
            anchors.bottomMargin: Style.current.smallPadding
        }
        Rectangle {
            color: tooltipContentBg.color
            height: 26
            width: 26
            rotation: 45
            radius: 1
            x: {
                if (orientation === StatusToolTip.Orientation.Top || orientation === StatusToolTip.Orientation.Bottom) {
                    return tooltipBg.width / 2 - width / 2
                }
                if (orientation === StatusToolTip.Orientation.Left) {
                    return tooltipContentBg.width - (width / 2) - 7
                }
                if (orientation === StatusToolTip.Orientation.Right) {
                    return -width/2 + 7
                }
            }
            y: {
                if (orientation === StatusToolTip.Orientation.Bottom) {
                    return -height / 2 + 5
                }
                if (orientation === StatusToolTip.Orientation.Top) {
                    return tooltipBg.height - height - 5
                }
                if (orientation === StatusToolTip.Orientation.Left || orientation === StatusToolTip.Orientation.Right) {
                    return tooltipContentBg.height / 2 - (height / 2)
                }
            }
        }
    }
    contentItem: StyledText {
        id: textContent
        text: tooltip.text
        color: Style.current.tooltipForegroundColor
        wrapMode: Text.WordWrap
        font.pixelSize: 13
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        bottomPadding: Style.current.smallPadding
    }
}

