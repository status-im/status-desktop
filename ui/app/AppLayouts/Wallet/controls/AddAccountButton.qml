import QtQuick
import QtQuick.Controls

import StatusQ.Controls

StatusRoundButton {
    id: btnAdd
    property bool checked: false

    width: 36
    height: 36
    icon.name: "add"
    icon.rotation: checked ? 45 : 0
    type: StatusRoundButton.Type.Secondary
    onPressed: checked = !checked
}
