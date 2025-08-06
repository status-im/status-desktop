import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import StatusQ.Core
import StatusQ.Core.Theme

Frame {
    id: root

    property bool dropShadow: true
    property alias cornerRadius: background.radius

    padding: Theme.bigPadding

    background: Rectangle {
        id: background
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: 20
        color: Theme.palette.background
    }

    layer.enabled: root.dropShadow
    layer.effect: DropShadow {
        verticalOffset: 4
        radius: 7
        samples: 15
        cached: true
        color: Theme.palette.dropShadow
    }
}
