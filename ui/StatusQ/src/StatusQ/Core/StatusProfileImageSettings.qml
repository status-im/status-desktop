import QtQuick 2.0
import StatusQ.Core.Theme 0.1

QtObject {
    id: root

    property url source
    property int width
    property int height
    property bool isIdenticon: false

    property string name
    property string pubkey
    property string image
    property bool showRing: true
    property bool interactive: true

    property int colorId // TODO: default value Utils.colorIdForPubkey(pubkey)
    property var colorHash // TODO: default value Utils.getColorHashAsJson(pubkey)

    property StatusImageSettings imageSettings: StatusImageSettings {
        width: root.width
        height: root.height
        source: root.source
    }

    readonly property StatusIconSettings iconSettings: StatusIconSettings {
        width: root.width
        height: root.height
        color: Theme.palette.userCustomizationColors[root.colorId]
        charactersLen: 2
    }

    readonly property StatusIdenticonRingSettings ringSettings: StatusIdenticonRingSettings {
        initalAngleRad: 0
        ringPxSize: Math.max(1.5, root.width / 24.0)
        ringSpecModel: root.showRing ? root.colorHash : undefined
        distinctiveColors: Theme.palette.identiconRingColors
    }
}
