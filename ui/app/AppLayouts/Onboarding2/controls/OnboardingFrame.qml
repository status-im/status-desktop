import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

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
        color: Theme.palette.name === Constants.darkThemeName ? Theme.palette.dropShadow
                                                              : Qt.rgba(0, 34/255, 51/255, 0.03)
    }
}
