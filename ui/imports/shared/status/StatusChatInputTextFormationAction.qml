import QtQuick.Controls

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

    checkable: true
    checked: surroundedBy(wrapper)
}
