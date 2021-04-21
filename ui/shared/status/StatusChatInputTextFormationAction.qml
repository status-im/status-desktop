import QtQuick 2.13
import QtQuick.Controls 2.13

Action {
    property string wrapper
    icon.width: 12
    icon.height: 16
    onTriggered: textFormatMenu.surroundedBy(wrapper) ? unwrapSelection(wrapper) : wrapSelection(wrapper)
    checked: textFormatMenu.surroundedBy(wrapper)
}
