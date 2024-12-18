import QtQuick 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

StatusFlatRoundButton {
    type: StatusFlatRoundButton.Type.Secondary
    icon.name: "clear"
    icon.width: 16
    icon.height: 16
    implicitWidth: 24
    implicitHeight: 24
    icon.color: Theme.palette.directColor9
    backgroundHoverColor: "transparent"
    tooltip.text: qsTr("Clear")
}
