import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Column {
    id: statusBanner
    width: parent.width

    property string statusText
    property int type: StatusBanner.Type.Info
    property int textPixels: 15
    property int statusBannerHeight: 38

    // "private" properties
    QtObject {
           id: d
           property color backgroundColor
           property color bordersColor
           property color fontColor
    }

    enum Type {
        Info, // 0
        Danger, // 1
        Success, // 2
        Warning // 3
    }    

    // Component definition
    Rectangle {
        id: topDiv
        color: d.bordersColor
        height: 1
        width: parent.width
    }

    Rectangle {
        id: box
        width: parent.width
        height: statusBanner.statusBannerHeight
        color: d.backgroundColor

        StatusBaseText {
            id: statusTxt
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: statusBanner.textPixels
            text: statusBanner.statusText
            color: d.fontColor
        }
    }

    Rectangle {
        id: bottomDiv
        color: d.bordersColor
        height: 1
        width: parent.width
    }

    // Behavior
    states: [
        State {
            when: statusBanner.type === StatusBanner.Type.Info
            PropertyChanges { target: d; backgroundColor: Theme.palette.primaryColor3}
            PropertyChanges { target: d; bordersColor: Theme.palette.primaryColor2}
            PropertyChanges { target: d; fontColor: Theme.palette.primaryColor1}
        },
        State {
            when: statusBanner.type === StatusBanner.Type.Danger
            PropertyChanges { target: d; backgroundColor: Theme.palette.dangerColor3}
            PropertyChanges { target: d; bordersColor: Theme.palette.dangerColor2}
            PropertyChanges { target: d; fontColor: Theme.palette.dangerColor1}
        },
        State {
            when: statusBanner.type === StatusBanner.Type.Success
            PropertyChanges { target: d; backgroundColor: Theme.palette.successColor2}
            PropertyChanges { target: d; bordersColor: Theme.palette.successColor2}
            PropertyChanges { target: d; fontColor: Theme.palette.successColor1}
        },
        State {
            when: statusBanner.type === StatusBanner.Type.Warning
            PropertyChanges { target: d; backgroundColor: Theme.palette.pinColor3}
            PropertyChanges { target: d; bordersColor: Theme.palette.pinColor2}
            PropertyChanges { target: d; fontColor: Theme.palette.pinColor1}
        }
    ]
}
