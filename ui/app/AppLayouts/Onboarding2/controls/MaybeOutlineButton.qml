import QtQuick 2.15

import StatusQ.Controls 0.1

StatusButton {
    id: root

    implicitWidth: 320
    // inside a Column (or another Positioner), make all but the first button outline
    isOutline: !root.Positioner.isFirstItem
}
