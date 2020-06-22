pragma Singleton

import QtQuick 2.13

QtObject {
    function isHex(value) {
        return /^(-0x|0x)?[0-9a-f]*$/i.test(value)
    }

    function startsWith0x(value) {
        return value.startsWith('0x')
    }

    function isChatKey(value) {
        return startsWith0x(value) && isHex(value) && value.length === 132
    }

    function isAddress(value) {
        return startsWith0x(value) && isHex(value) && value.length === 42
    }

    function isPrivateKey(value) {
        return isHex(value) && ((startsWith0x(value) && value.length === 66) ||
                                (!startsWith0x(value) && value.length === 64))
    }

    function isMnemonic(value) {
        // Do we support other length than 12?
        return value.split(/\s|,/).length === 12
    }
}
