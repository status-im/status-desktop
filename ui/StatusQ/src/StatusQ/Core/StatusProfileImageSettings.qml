import QtQuick
import StatusQ.Core.Theme

QtObject {
    id: root

    property int width
    property int height
    property bool isIdenticon: false

    property string name
    property string pubkey
    property bool interactive: true

    property int colorId // TODO: default value Utils.colorIdForPubkey(pubkey)

    property StatusAssetSettings assetSettings: StatusAssetSettings {
        width: root.width
        height: root.height
        name: root.name
        isLetterIdenticon: (name === "")
        imgIsIdenticon: root.isIdenticon
        color: Theme.palette.userCustomizationColors[root.colorId]
        charactersLen: 2
    }
}
