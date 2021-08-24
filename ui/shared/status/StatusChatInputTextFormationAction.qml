import QtQuick 2.13
import QtQuick.Controls 2.13

Action {
    property string wrapper
    // adding this signal due to a known limitation from Qt: Menu closes when Action is triggered
    signal actionTriggered()
    icon.width: 12
    icon.height: 16
    onActionTriggered: checked ?
                     unwrapSelection(wrapper, textFormatMenu.selectedTextWithFormationChars) :
                     wrapSelection(wrapper)
    checked: textFormatMenu.surroundedBy(wrapper)
}
