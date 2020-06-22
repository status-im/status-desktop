pragma Singleton

import QtQuick 2.13

QtObject {
    function isHex(value) {
        return /^[0-9a-f]*$/i.test(value)
    }

    function startsWith0x(value) {
        return value.startsWith('0x')
    }

    function isChatKey(value) {
        return startsWith0x(value) && isHex(value) && value.length === 132
    }
}
