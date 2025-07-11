import QtQuick

import StatusQ.Controls

StatusButton {
    id: root

    implicitWidth: 320
    // inside a Column (or another Positioner), make all but the first button outline
    isOutline: !root.Positioner.isFirstItem
}
