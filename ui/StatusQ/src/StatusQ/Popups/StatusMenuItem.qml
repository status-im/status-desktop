import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Core 0.1

Action {
    id: statusMenuItem

    enum Type {
        Normal,
        Danger
    }

    property int type: StatusMenuItem.Type.Normal

    property StatusAssetSettings assetSettings: StatusAssetSettings {
        width: 18
        height: 18
        rotation: 0
        isLetterIdenticon: false
        imgIsIdenticon: false
        color: "transparent"
        name: statusMenuItem.icon.name
    }

    property StatusFontSettings fontSettings: StatusFontSettings {}

    icon.color: "transparent"
}
