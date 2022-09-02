import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Core 0.1

Action {
    id: statusMenuItem

    enum Type {
        Normal,
        Danger
    }
    icon.color: "transparent"
    property int type: StatusMenuItem.Type.Normal
    property real iconRotation: 0
    property StatusAssetSettings assetSettings: StatusAssetSettings {
        width: 16
        height: 16
        color: "transparent"
        isLetterIdenticon: false
        imgIsIdenticon: false
        name: statusMenuItem.icon.name
    }

    property StatusFontSettings fontSettings: StatusFontSettings {}
}
