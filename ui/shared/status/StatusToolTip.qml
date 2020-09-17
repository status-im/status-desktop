import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"

ToolTip {
    id: tooltip
    implicitWidth: tooltip.width
    leftPadding: Style.current.padding
    rightPadding: Style.current.padding
    topPadding: Style.current.smallPadding
    bottomPadding: Style.current.smallPadding
    delay: 200
    background: Item {
        id: tooltipBg
        Rectangle {
            id: tooltipContentBg
            color: Style.current.blue
            radius: Style.current.radius
            anchors.fill: parent
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
        color: Style.current.white
        wrapMode: Text.WordWrap
        font.pixelSize: 13
        horizontalAlignment: Text.AlignHCenter
    }
}

