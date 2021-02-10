import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"

ToolTip {
    id: tooltip
    property int maxWidth: 800
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
            height: 24
            width: 24
            rotation: 135
            radius: 1
            x: tooltipBg.width / 2 - width / 2
            anchors.top: tooltipContentBg.bottom
            anchors.topMargin: -20
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

