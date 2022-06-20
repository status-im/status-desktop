import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1

StatusRoundButton {
    id: btnAdd
    property bool checked: false

    width: Style.dp(36)
    height: Style.dp(36)
    icon.name: "add"
    icon.rotation: checked ? 45 : 0
    type: StatusRoundButton.Type.Secondary
    onPressed: checked = !checked
}
