import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0

InformationTag {
    id: root

    signal closed()

    tagPrimaryLabel.color: Theme.palette.directColor1
    tagSecondaryLabel.color: Theme.palette.directColor1
    middleLabel.color: Theme.palette.baseColor1
    iconAsset.color: Theme.palette.primaryColor1
    secondarylabelMaxWidth: 1000
    height: 32
    customBackground: Component {
        Rectangle {
            radius: 36
            color: Theme.palette.transparent
            border.width: 1
            border.color: Theme.palette.baseColor2
        }
    }
    rightComponent: StatusIcon {
        color: Theme.palette.primaryColor1
        width: 20
        height: 20
        icon: "close"
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.closed()
        }
    }
}
