import QtQuick 2.3
import shared 1.0
import shared.panels 1.0

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

Loader {
    id: root

    property int imageHeight: 44
    property int imageWidth: 44

    property string name
    property string pubkey
    property string image
    property bool showRing: !ensVerified && !root.isBridgedAccount
    property bool interactive: true
    property bool disabled: false
    property bool ensVerified: false
    property bool loading: false
    property bool isBridgedAccount: false

    property int colorId: Utils.colorIdForPubkey(pubkey)
    property var colorHash: Utils.getColorHashAsJson(pubkey, ensVerified)

    signal clicked()

    sourceComponent: StatusSmartIdenticon {
        name: root.name
        asset {
            width: root.imageWidth
            height: root.imageHeight
            color: Utils.colorForColorId(root.colorId)
            name: root.image
            charactersLen: 2
            isImage: true
        }
        ringSettings {
            ringSpecModel: root.showRing ? root.colorHash : undefined
        }
        loading: root.loading
        bridgeBadge.visible: root.isBridgedAccount
        bridgeBadge.image.source: Style.svg("discord-bridge")

        Loader {
            anchors.fill: parent

            active: root.interactive

            sourceComponent: MouseArea {
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
