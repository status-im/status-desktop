import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Action {
    id: root

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
        color: root.icon.color
        name: root.icon.name
    }

    property StatusFontSettings fontSettings: StatusFontSettings {}

    property StatusIdenticonRingSettings ringSettings: StatusIdenticonRingSettings {
        initalAngleRad: 0
        ringPxSize: Math.max(1.5, root.assetSettings.width / 24.0)
        distinctiveColors: Theme.palette.identiconRingColors
    }

    icon.color: {
        if (!root.enabled)
            return Theme.palette.baseColor1
        if (type === StatusMenuItem.Type.Danger)
            return Theme.palette.dangerColor1
        return Theme.palette.primaryColor1
    }
}
