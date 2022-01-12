import QtQuick 2.14

import StatusQ.Core 0.1

Column {
    id: statusBanner
    width: parent.width

    property color backgroundColor
    property color bordersColor
    property color fontColor
    property string statusText
    property int textPixels: 15
    property int statusBannerHeight: 38

    Rectangle {
        id: topDiv
        color: statusBanner.bordersColor
        height: 1
        width: parent.width
    }

    // Status banner content:
    Rectangle {
        id: statusBox
        width: parent.width
        height: statusBanner.statusBannerHeight
        color: statusBanner.backgroundColor

        StatusBaseText {
            id: statusTxt
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: statusBanner.textPixels
            text: statusBanner.statusText
            color: statusBanner.fontColor
        }
    }

    Rectangle {
        id: bottomDiv
        color: statusBanner.bordersColor
        height: 1
        width: parent.width
    }
}
