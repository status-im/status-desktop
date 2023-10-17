import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Action {
    id: root

    enum Type {
        Normal,
        Danger,
        Success
    }

    property int type: StatusAction.Type.Normal

    property StatusAssetSettings assetSettings: StatusAssetSettings {
        width: 18
        height: 18
        rotation: 0
        isLetterIdenticon: false
        imgIsIdenticon: false
        color: root.icon.color
        name: root.icon.name
        hoverColor: Theme.palette.statusMenu.hoverBackgroundColor
    }

    property StatusFontSettings fontSettings: StatusFontSettings {}

    property StatusIdenticonRingSettings ringSettings: StatusIdenticonRingSettings {
        initalAngleRad: 0
        ringPxSize: root.assetSettings.ringPxSize
        distinctiveColors: Theme.palette.identiconRingColors
    }

    icon.color: {
        if (!root.enabled)
            return Theme.palette.baseColor1
        if (type === StatusAction.Type.Danger)
            return Theme.palette.dangerColor1
        if (type === StatusAction.Type.Success)
            return Theme.palette.successColor1
        return Theme.palette.primaryColor1
    }
}
