import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

TextField {
    font.family: Style.current.baseFont.name
    color: readOnly ? Style.current.secondaryText : Style.current.textColor
    selectByMouse: !readOnly
    selectedTextColor: Style.current.textColor
    selectionColor: Style.current.primarySelectionColor
}
