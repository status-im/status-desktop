import QtQuick 2.3
import shared 1.0
import shared.panels 1.0

import utils 1.0

import StatusQ.Components 0.1

Loader {
    id: root

    property int imageHeight: compact ? 36 : 40
    property int imageWidth: compact ? 36 : 40
    property bool compact: true

    property string name
    property string pubkey
    property string image
    property bool showRing: false
    property bool interactive: true

    signal clicked()

    height: active ? item.height : 0

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
            color: Style.current.background
            textColor: Style.current.secondaryText
            letterSize: Math.max(4, root.imageWidth / 2.4)
            charactersLen: 2
        }
        ringSettings {
            ringSpecModel: root.showRing ? Utils.getColorHashAsJson(root.pubkey) : undefined
            ringPxSize: Math.max(root.imageWidth / 24.0)
        }

        Loader {
            anchors.fill: parent

            active: root.interactive

            sourceComponent: MouseArea {
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.clicked()
            }
        }
    }
}
