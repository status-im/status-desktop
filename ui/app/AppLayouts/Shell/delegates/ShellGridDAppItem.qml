import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

ShellGridItem {
    id: root

    property url connectorBadge

    signal disconnectRequested

    sectionType: Constants.appSection.dApp
    extraMenuActions: [disconnectAction]

    background: Rectangle {
        color: hovered ? Qt.lighter(Theme.palette.baseColor4, 1.5) : Theme.palette.baseColor4
        Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
        radius: Theme.padding

        opacity: pressed || down ? Theme.pressedOpacity : enabled ? 1 : Theme.disabledOpacity
        Behavior on opacity { NumberAnimation { duration: Theme.AnimationDuration.Fast } }
    }

    iconLoaderComponent: StatusSmartIdenticon {
        asset.color: root.icon.color
        asset.bgColor: Qt.lighter(asset.color, 1.8)
        asset.name: root.icon.name
        asset.width: 30
        asset.height: 30

        name: root.title

        bridgeBadge {
            image.source: root.connectorBadge
            border.width: 0
            implicitHeight: 16
            implicitWidth: 16
            anchors.rightMargin: 1
            anchors.bottomMargin: 1
        }
        bridgeBadge.visible: root.connectorBadge != "" && !bridgeBadge.isError
    }

    bottomRowComponent: StatusBaseText {
        width: root.availableWidth
        text: root.itemId
        color: Theme.palette.baseColor1
        font.pixelSize: Theme.tertiaryTextFontSize
        font.weight: Font.Medium
        elide: Text.ElideRight

        HoverHandler {
            id: titleTextHHandler
            enabled: parent.truncated
        }
        StatusToolTip {
            visible: titleTextHHandler.hovered
            offset: -(x + width/2 - root.width/2)
            text: root.itemId
        }
    }

    StatusAction {
        id: disconnectAction
        objectName: "disconnectAction"
        icon.name: "disconnect"
        text: qsTr("Disconnect")
        onTriggered: root.disconnectRequested()
    }
}
