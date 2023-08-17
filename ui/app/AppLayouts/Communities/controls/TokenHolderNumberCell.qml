
import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

StatusBaseText {
    id: root

    horizontalAlignment: Qt.AlignRight
    verticalAlignment: Qt.AlignVCenter

    font.weight: Font.Medium
    font.pixelSize: 13

    color: Theme.palette.baseColor1
    elide: Qt.ElideRight
}
