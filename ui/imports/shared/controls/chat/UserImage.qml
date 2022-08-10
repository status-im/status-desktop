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
    property bool showRing: true
    property bool interactive: true
    property var messageContextMenu

    property int colorId: Utils.colorIdForPubkey(pubkey)
    property var colorHash: Utils.getColorHashAsJson(pubkey)

    signal clicked()

    sourceComponent: StatusSmartIdenticon {
        name: root.name
        image {
            width: root.imageWidth
            height: root.imageHeight
            source: root.image
        }
        icon {
            width: root.imageWidth
            height: root.imageHeight
            color: Theme.palette.userCustomizationColors[root.colorId]
            charactersLen: 2
        }
        ringSettings {
            ringSpecModel: root.showRing ? root.colorHash : undefined
        }

        Loader {
            anchors.fill: parent

            active: root.interactive

            sourceComponent: MouseArea {
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    if (!!root.messageContextMenu) {
                        // Set parent, X & Y positions for the messageContextMenu
                        root.messageContextMenu.parent = root
                        root.messageContextMenu.setXPosition = function() { return root.width + 4 }
                        root.messageContextMenu.setYPosition = function() { return 0 }
                    }
                    root.clicked()
                }
            }
        }
    }
}
