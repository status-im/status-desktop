import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme

import shared.controls

InformationTag {
    id: root

    signal closed()

    tagPrimaryLabel.color: Theme.palette.directColor1
    tagSecondaryLabel.color: Theme.palette.directColor1
    middleLabel.color: Theme.palette.baseColor1
    asset.color: Theme.palette.primaryColor1
    secondarylabelMaxWidth: 1000
    height: 32
    customBackground: Component {
        Rectangle {
            radius: 36
            color: StatusColors.colors.transparent
            border.width: 1
            border.color: Theme.palette.baseColor2
        }
    }
    rightComponent: StatusIcon {
        color: Theme.palette.primaryColor1
        width: 20
        height: 20
        icon: "close"
        StatusMouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.closed()
        }
    }
}
