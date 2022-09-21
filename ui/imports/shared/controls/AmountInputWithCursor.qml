import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusInput {
    id: cursorInput

    property string cursorColor: Theme.palette.primaryColor1

    leftPadding: 0
    rightPadding: 0

    placeholderText: ""
    input.edit.objectName: "amountInput"
    input.edit.cursorVisible: true
    input.edit.font.pixelSize: 32
    input.placeholderFont.pixelSize: 32
    input.leftPadding: 0
    input.rightPadding: 0
    input.topPadding: 0
    input.bottomPadding: 0
    input.edit.padding: 0
    input.background.color: "transparent"
    input.background.border.width: 0
    // To-do this needs to be removed once https://github.com/status-im/StatusQ/issues/578 is implemented and cursor is moved to StatusInput
    input.edit.cursorDelegate: StatusCursorDelegate {
        color: cursorColor
        visible: input.edit.cursorVisible
    }
}
