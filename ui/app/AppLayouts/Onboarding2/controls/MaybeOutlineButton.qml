import QtQuick 2.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

StatusButton {
    id: root

    implicitWidth: 320

    // inside a Column (or another Positioner), make all but the first button outline
    Binding on normalColor {
        value: "transparent"
        when: !root.Positioner.isFirstItem
        restoreMode: Binding.RestoreBindingOrValue
    }
    Binding on borderWidth {
        value: 1
        when: !root.Positioner.isFirstItem
        restoreMode: Binding.RestoreBindingOrValue
    }
    Binding on borderColor {
        value: Theme.palette.baseColor2
        when: !root.Positioner.isFirstItem
        restoreMode: Binding.RestoreBindingOrValue
    }
}
