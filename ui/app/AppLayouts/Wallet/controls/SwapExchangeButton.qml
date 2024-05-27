import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusButton {
    implicitWidth: 44
    implicitHeight: 44

    icon.name: hovered ? "arrow-up" : "arrow-down"
    icon.color: Theme.palette.baseColor1

    isRoundIcon: true
    radius: height/2
    normalColor: Theme.palette.indirectColor3
    hoverColor: Theme.palette.directColor8
    borderWidth: 1
    borderColor: hovered ? Theme.palette.directColor7 : Theme.palette.directColor8
}
