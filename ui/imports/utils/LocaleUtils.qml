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

        // try to parse floating point number according to locale's decimal separator, fall back to '.'
        function readNumber(value, locale) {
            if (typeof value === "string") {
                try {
                    value = Number.fromLocaleString(Qt.locale(locale), value)
                } catch (error) {
                    value = Number(value)
                }
            }
            return value
        }
    }

    // TODO enforce 24h time format when desired
    // TODO check default (crypto) currency float precision
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

    // NUMBERS
    /**
      Converts the Number to a string suitable for the specified locale with the specified precision.

      - 'precision': number of digits after the decimal separator (default is 2)
      - if 'locale' is not specified, the default locale will be used.
    */
    function formatNumber(value, precision = 2, locale = "") {
        value = d.readNumber(value, locale)
        return value.toLocaleString(Qt.locale(locale), 'f', precision)
    }

    // CURRENCY
    /**
      Converts the Number to a currency string using the currency and conventions of the specified locale.
      If symbol is specified it will be used as the currency symbol.
    */
    function formatCurrency(value, symbol = "", locale = "") {
        value = d.readNumber(value, locale)
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
    function formatCryptoCurrency(value, symbol, precision = 15, locale = "") {
        if (!symbol) {
            console.warn("LocaleUtils.formatCryptoCurrency(): missing 'symbol' for %1, will be replaced with '???'"
                         .arg(value.toString()))
            symbol = "???"
        }
        return "%1 %2".arg(formatNumber(value, precision, locale)).arg(symbol)
    }
}
