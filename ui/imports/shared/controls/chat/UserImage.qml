import QtQuick 2.15

import shared 1.0
import shared.panels 1.0

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Loader {
    id: root

    property int imageHeight: 44
    property int imageWidth: 44

    property string name
    property string image
    property bool showRing: !ensVerified && !root.isBridgedAccount
    property bool interactive: true
    property bool disabled: false
    property bool ensVerified: false
    property bool loading: false
    property bool isBridgedAccount: false
    property int onlineStatus: Constants.onlineStatus.unknown

    property int colorId
    property var colorHash: []

    signal clicked()

    sourceComponent: StatusSmartIdenticon {
        name: root.name
        asset {
            width: root.imageWidth
            height: root.imageHeight
            color: Utils.colorForColorId(root.colorId)
            name: root.image
            isImage: true
        }
        ringSettings {
            ringSpecModel: root.showRing ? root.colorHash : undefined
        }
        loading: root.loading

        badge.visible: root.onlineStatus !== Constants.onlineStatus.unknown && !root.isBridgedAccount
        badge.width: root.imageWidth/4
        badge.height: root.imageWidth/4
        badge.border.width: 0.05 * root.imageWidth
        badge.border.color: Theme.palette.statusBadge.foregroundColor
        badge.color: {
            if (root.onlineStatus === Constants.onlineStatus.online)
                return Theme.palette.successColor1
            return Theme.palette.baseColor1
        }
        badge.anchors.rightMargin: badge.border.width/2
        badge.anchors.bottomMargin: badge.border.width/2

        bridgeBadge.visible: root.isBridgedAccount
        bridgeBadge.image.source: Theme.svg("discord-bridge")

        Loader {
            anchors.fill: parent

            active: root.interactive

            sourceComponent: StatusMouseArea {
                cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                hoverEnabled: !root.disabled
                onClicked: {
                    if (!root.disabled) {
                        root.clicked()
                    }
                }
            }
        }
    }
}
