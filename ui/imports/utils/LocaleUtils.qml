pragma Singleton

import QtQml 2.14

QtObject {

    function fractionalPartLength(num) {
        if (Number.isInteger(num))
            return 0

        let parts = num.toString().split('.')
        // Decimal trick doesn't work for numbers represented in scientific notation, hence the hardcoded fallback
        return (parts.length > 1 && parts[1].indexOf("e") == -1) ? parts[1].length : 2
    }

    function numberToLocaleString(num, precision = -1, locale = null) {
        locale = locale || Qt.locale()

        if (precision === -1)
            precision = fractionalPartLength(num)

        return num.toLocaleString(locale, 'f', precision)
    }
}
