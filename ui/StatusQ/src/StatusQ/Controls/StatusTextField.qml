import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Universal

import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils

TextField {
    id: root
    Accessible.name: Utils.formatAccessibleName(placeholderText, objectName)

    font.family: Theme.baseFont.name
    font.pixelSize: Theme.primaryTextFontSize
    color: readOnly ? Theme.palette.baseColor1 : Theme.palette.directColor1
    selectByMouse: true
    selectedTextColor: Theme.palette.directColor1
    selectionColor: Theme.palette.primaryColor2
    placeholderTextColor: Theme.palette.baseColor1

    opacity: enabled ? 1 : Theme.disabledOpacity

    cursorDelegate: StatusCursorDelegate {
        cursorVisible: root.cursorVisible
    }
}
