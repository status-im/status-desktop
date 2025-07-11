import QtQuick
import QtQuick.Controls

import StatusQ.Controls
import StatusQ.Core.Theme

StatusButton {
    implicitWidth: 44
    implicitHeight: 44

    icon.name: hovered ? "arrow-up" : "arrow-down"
    icon.color: Theme.palette.baseColor1

    focusPolicy: Qt.NoFocus
    isRoundIcon: true
    normalColor: Theme.palette.indirectColor3
    disabledColor: normalColor
    opacity: enabled ? 1 : 0.4
    hoverColor: Theme.palette.directColor8
    borderWidth: 1
    borderColor: hovered ? Theme.palette.directColor7 : Theme.palette.directColor8
}
