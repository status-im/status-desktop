pragma Singleton

import QtQml 2.14

QtObject {

    function fractionalPartLength(num) {
        if (Number.isInteger(num))
            return 0

        return num.toString().split('.')[1].length
    }

    function numberToLocaleString(num, precision = -1, locale = null) {
        locale = locale || Qt.locale()

        if (precision === -1)
            precision = fractionalPartLength(num)

        return num.toLocaleString(locale, 'f', precision)
    }
}
