pragma Singleton

import QtQuick 2.13

QtObject {
    function getAbsolutePosition(node) {
        var returnPos = {};
        returnPos.x = 0;
        returnPos.y = 0;
        if (node !== undefined && node !== null) {
            var parentValue = getAbsolutePosition(node.parent);
            returnPos.x = parentValue.x + node.x;
            returnPos.y = parentValue.y + node.y;
        }
        return returnPos;
    }
    function isValidAddress(inputValue) {
        return inputValue !== "0x" && /^0x[a-fA-F0-9]{40}$/.test(inputValue)
    }

}


