import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

TextField {
    font.family: Style.current.fontRegular.name
    color: readOnly ? Style.current.secondaryText : Style.current.textColor
    selectByMouse: !readOnly
    selectedTextColor: Style.current.textColor
    selectionColor: Style.current.primarySelectionColor
}
