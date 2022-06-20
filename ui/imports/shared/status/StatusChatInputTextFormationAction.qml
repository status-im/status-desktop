import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

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
    icon.width: Style.dp(12)
    icon.height: Style.dp(16)
    checked: surroundedBy(wrapper)
}
