import QtQuick 2.13
import QtQuick.Controls 2.13

import "../../../../shared/status"

StatusRoundButton {
    id: btnAdd

    width: 36
    height: 36
    icon.name: "plusSign"
    pressedIconRotation: 45
    size: "medium"
    type: "secondary"
}
