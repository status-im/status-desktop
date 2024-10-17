import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

TextField {
    id: root

    font.family: Theme.baseFont.name
    font.pixelSize: Theme.primaryTextFontSize
    color: readOnly ? Theme.palette.baseColor1 : Theme.palette.directColor1
    selectByMouse: true
    selectedTextColor: Theme.palette.directColor1
    selectionColor: Theme.palette.primaryColor2
    placeholderTextColor: Theme.palette.baseColor1

    opacity: enabled ? 1 : 0.3

    cursorDelegate: StatusCursorDelegate {
        cursorVisible: root.cursorVisible
    }
}
