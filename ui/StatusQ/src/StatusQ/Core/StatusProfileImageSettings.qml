import QtQuick 2.0
import StatusQ.Core.Theme 0.1

QtObject {
    id: root

    property int width
    property int height
    property bool isIdenticon: false

    property string name
    property string pubkey
    property bool showRing: true
    property bool interactive: true

    property int colorId // TODO: default value Utils.colorIdForPubkey(pubkey)
    property var colorHash // TODO: default value Utils.getColorHashAsJson(pubkey)

    property StatusAssetSettings assetSettings: StatusAssetSettings {
        width: root.width
        height: root.height
        name: root.name
        isLetterIdenticon: (name === "")
        imgIsIdenticon: root.isIdenticon
        color: Theme.palette.userCustomizationColors[root.colorId]
        charactersLen: 2
    }

    readonly property StatusIdenticonRingSettings ringSettings: StatusIdenticonRingSettings {
        initalAngleRad: 0
        ringPxSize: root.assetSettings.ringPxSize
        ringSpecModel: root.showRing ? root.colorHash : undefined
        distinctiveColors: Theme.palette.identiconRingColors
    }
}
