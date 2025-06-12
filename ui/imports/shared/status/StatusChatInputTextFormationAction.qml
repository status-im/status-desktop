import QtQuick 2.15
import QtQuick.Controls 2.15

Action {
    property string wrapper
    property string selectedTextWithFormationChars: ""
    function surroundedBy(chars) {
        if (selectedTextWithFormationChars === "") {
            return false;
        }

        const firstIndex = selectedTextWithFormationChars.indexOf(chars);
        if (firstIndex === -1) {
            return false;
        }

        return (selectedTextWithFormationChars.lastIndexOf(chars) > firstIndex);
    }
    // adding this signal due to a known limitation from Qt: Menu closes when Action is triggered
    signal actionTriggered()
    icon.width: 12
    icon.height: 16
    checked: surroundedBy(wrapper)
}
