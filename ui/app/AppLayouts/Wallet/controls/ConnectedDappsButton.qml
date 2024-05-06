import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import shared.controls 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusButton {
    id: root

    implicitHeight: 38

    size: StatusBaseButton.Size.Small

    borderColor: Theme.palette.directColor7
    normalColor: Theme.palette.transparent
    hoverColor: Theme.palette.baseColor2
    textPosition: StatusBaseButton.TextPosition.Left
    textColor: Theme.palette.baseColor1

    icon.name: "dapp"
    icon.height: 16
    icon.width: 16
    icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
}
