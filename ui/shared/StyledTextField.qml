import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

TextField {
    font.family: Style.current.fontRegular.name
    color: Style.current.textColor
    selectByMouse: true
    selectedTextColor: Style.current.textColor
    selectionColor: Style.current.secondaryHover
}
