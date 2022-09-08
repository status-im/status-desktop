pragma Singleton

import QtQml 2.14

QtObject {
    id: root

    readonly property var d: QtObject {
        id: d

        readonly property var amPmFormatChars: ["AP", "A", "ap", "a"]

        // try to parse date from a number or ISO string timestamp
        function readDate(value) {
            if (typeof value === "string" || typeof value === "number") { // support reading ISO string or numeric timestamps
                value = new Date(value)
            }
            return value
        }
    }

    // TODO enforce 24h time format when desired
    // TODO strip trailing zeros in numbers/currencies

    // DATE/TIME
    function isDDMMYYDateFormat_default(locale = "") {
        return Qt.locale(locale).dateFormat(Locale.ShortFormat).startsWith("d")
    }

    function is24hTimeFormat_default(locale = "") {
        return !d.amPmFormatChars.some(ampm => Qt.locale(locale).timeFormat(Locale.LongFormat).includes(ampm))
    }

    /**
     Converts the Date to a string containing the date suitable for the specified locale in the specified format.

     - 'value' can be either a Date object, or a string containing a number or ISO string timestamp, or empty for "now"
     - 'format' can be one of Locale.LongFormat (default), Locale.ShortFormat
     - if 'locale' is not specified, the default locale will be used.
    */
    function formatDate(value = new Date(), format = Locale.LongFormat, locale = "") {
        value = d.readDate(value)
        if (format === Locale.ShortFormat) { // replace 2-digit year with 4-digits (yy -> yyyy) in short format
            const dateFormatStr = Qt.locale(locale).dateFormat(Locale.ShortFormat)
            if (!dateFormatStr.includes("yyyy")) {
                format = dateFormatStr.replace("yy", "yyyy")
            }
        }
        return value.toLocaleDateString(Qt.locale(locale), format)
    }

    /**
     Converts the Date to a string containing the time suitable for the specified locale in the specified format.

     - 'value' can be either a Date object, or a string containing a number or ISO string timestamp, or empty for "now"
     - 'format' can be one of Locale.LongFormat (default), Locale.ShortFormat
     - if 'locale' is not specified, the default locale will be used.
    */
    function formatTime(value = new Date(), format = Locale.LongFormat, locale = "") {
        value = d.readDate(value)
        return value.toLocaleTimeString(Qt.locale(locale), format)
    }

    /**
     Converts the Date to a string containing both the date and time suitable for the specified locale in the specified format.

     - 'value' can be either a Date object, or a string containing a number or ISO string timestamp, or empty for "now"
     - 'format' can be one of Locale.LongFormat (default), Locale.ShortFormat
     - if 'locale' is not specified, the default locale will be used.
    */
    function formatDateTime(value = new Date(), format = Locale.LongFormat, locale = "") {
        value = d.readDate(value)
        if (format === Locale.ShortFormat) { // replace 2-digit year with 4-digits (yy -> yyyy) in short format
            const dateFormatStr = Qt.locale(locale).dateTimeFormat(Locale.ShortFormat)
            if (!dateFormatStr.includes("yyyy")) {
                format = dateFormatStr.replace("yy", "yyyy")
            }
        }
        return value.toLocaleString(Qt.locale(locale), format)
    }

    function getTimeDifference(d1, d2) {
        const day1Year = d1.getFullYear()
        const day1Month = d1.getMonth()
        const day1Time = d1.getTime()

        const day2Year = d2.getFullYear()
        const day2Month = d2.getMonth()
        const day2Time = d2.getTime()

        const inYears = day2Year-day1Year
        if (inYears > 0) {
            return qsTr("%n year(s) ago", "", inYears)
        }

        const inMonths = (day2Month+12*day2Year)-(day1Month+12*day1Year)
        if (inMonths > 0) {
            return qsTr("%n month(s) ago", "", inMonths)
        }

        const inWeeks = parseInt((day2Time-day2Time)/(24*3600*1000*7))
        if (inWeeks > 0) {
            return qsTr("%n week(s) ago", "", inWeeks)
        }

        const inDays = parseInt((day2Time-day1Time)/(24*3600*1000))
        if (inDays > 0) {
            return qsTr("%n day(s) ago", "", inDays)
        }

        const inHours = parseInt((day2Time-day1Time)/(3600*1000));
        if (inHours > 0) {
            return qsTr("%n hour(s) ago", "", inHours)
        }

        const inMins = parseInt((day2Time-day1Time)/(60*1000))
        if (inMins > 0) {
            return qsTr("%n min(s) ago", "x minute(s) ago", inMins)
        }

        const inSecs = parseInt((day2Time-day1Time)/1000);
        if (inSecs > 0) {
            return qsTr("%n sec(s) ago", "x second(s) ago", inSecs)
        }

        return qsTr("now")
    }

    // NUMBERS
    // try to parse floating point number according to locale's decimal separator, fall back to '.'
    function readNumber(value, locale = "") {
        if (typeof value === "string") {
            try {
                value = Number.fromLocaleString(Qt.locale(locale), value)
            } catch (error) {
                value = Number(value)
            }
        }
        return value
    }
    /**
      Converts the Number to a string suitable for the specified locale with the specified precision.

      - 'precision': number of digits after the decimal separator (default is 2)
      - if 'locale' is not specified, the default locale will be used.
    */
    function formatNumber(value, precision = 2, locale = "") {
        value = readNumber(value, locale)
        return value.toLocaleString(Qt.locale(locale), 'f', precision)
    }

    // CURRENCY
    /**
      Converts the Number to a currency string using the currency and conventions of the specified locale.
      If symbol is specified it will be used as the currency symbol.
    */
    function formatCurrency(value, symbol = "", locale = "") {
        value = readNumber(value, locale)
        if (!symbol) {
            symbol = Qt.locale(locale).currencySymbol(Locale.CurrencySymbol)
            console.warn("LocaleUtils.formatCurrency(): missing 'symbol' for %1, will be replaced with locale's default (%2)"
                         .arg(value.toString()).arg(symbol))
        }

        return value.toLocaleCurrencyString(Qt.locale(locale), symbol)
    }

    /**
     Converts the Number to a crypto currency string using the currency and conventions of the specified locale.
     If symbol is specified it will be used as the currency symbol.
    */
    function formatCryptoCurrency(value, symbol, precision = 18, locale = "") {
        if (!symbol) {
            console.warn("LocaleUtils.formatCryptoCurrency(): missing 'symbol' for %1, will be replaced with '???'"
                         .arg(value.toString()))
            symbol = "???"
        }
        return "%1 %2".arg(formatNumber(value, precision, locale)).arg(symbol)
    }
}
