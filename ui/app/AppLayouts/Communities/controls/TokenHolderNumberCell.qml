
import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import utils

StatusBaseText {
    id: root

    horizontalAlignment: Qt.AlignRight
    verticalAlignment: Qt.AlignVCenter

    font.weight: Font.Medium
    font.pixelSize: Theme.additionalTextSize

    color: Theme.palette.baseColor1
    elide: Qt.ElideRight
}
