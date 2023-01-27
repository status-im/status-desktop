pragma Singleton

import QtQml 2.14
import Qt.labs.settings 1.0

QtObject {
    id: root

    function fractionalPartLength(num) {
        if (Number.isInteger(num))
            return 0

        return num.toString().split('.')[1].length
    }

    function stripTrailingZeroes(numStr, locale) {
        let regEx = locale.decimalPoint == "." ? /(\.[0-9]*[1-9])0+$|\.0*$/ : /(\,[0-9]*[1-9])0+$|\,0*$/
        return numStr.replace(regEx, '$1')
    }

    function numberToLocaleString(num, precision = -1, locale = null) {
        locale = locale || Qt.locale()

        if (precision === -1)
            precision = fractionalPartLength(num)

        return num.toLocaleString(locale, 'f', precision)
    }

    function numberFromLocaleString(num, locale = null) {
        locale = locale || Qt.locale()
        try {
            return Number.fromLocaleString(locale, num)
        } catch (_) {
            return parseFloat(num)
        }
    }

    function currencyAmountToLocaleString(currencyAmount, options = null, locale = null) {
        locale = locale || Qt.locale()

        if (!currencyAmount) {
            return "N/A"
        }
        if (typeof(currencyAmount) !== "object") {
            console.warn("Wrong type for currencyAmount: " + JSON.stringify(currencyAmount))
            console.trace()
            return NaN
        }

        var amountStr
        let minAmount = 10**-currencyAmount.displayDecimals
        if (currencyAmount.amount > 0 && currencyAmount.amount < minAmount && !(options && options.onlyAmount))
        {
            // Handle amounts smaller than resolution
            amountStr = "<%1".arg(numberToLocaleString(minAmount, currencyAmount.displayDecimals, locale))
        } else {
            // Normal formatting
            amountStr = numberToLocaleString(currencyAmount.amount, currencyAmount.displayDecimals, locale)
            if (currencyAmount.stripTrailingZeroes) {
                amountStr = stripTrailingZeroes(amountStr, locale)
            }
        }

        // Add symbol
        if (currencyAmount.symbol && !(options && options.onlyAmount)) {
            amountStr = "%1 %2".arg(amountStr).arg(currencyAmount.symbol)
        }

        return amountStr
    }

    // DATE/TIME
    readonly property var d: QtObject {
        id: d

        readonly property var amPmFormatChars: ["AP", "A", "ap", "a"]

        // try to parse date from a number or ISO string timestamp
        function readDate(value) {
            if (typeof value === "undefined") // default to "now" if omitted
                return new Date()
            if (typeof value === "string" || typeof value === "number")  // support reading ISO string or numeric timestamps
                return new Date(value)
            return value
        }

        // enforce correct 12/24 time format when not using defaults
        function fixupTimeFormatString(formatString) {
            if (settings.timeFormatUsesDefaults) // OS defaults, nothing to change
                return formatString
            if (settings.timeFormatUses24Hours) { // enforce 24h time format
                // remove any amPmFormatChars from the format string and use 0-23 hours (h->H, hh->HH)
                return formatString.replace(/\ba\b|\bap\b/ig, "").replace(/h/g, "H")
            } else { // enforce 12hr time format
                // use 0-12 hours (H->h, HH->h) and append any of amPmFormatChars to the format string
                var result = formatString.replace(/H/g, "h")
                if (!d.amPmFormatChars.some(ampm => result.includes(ampm)))
                    result = result.concat(" ap")
                return result
            }
        }
    }

    readonly property Settings settings: Settings {
        category: "Locale"
        property bool timeFormatUsesDefaults: true
        property bool timeFormatUses24Hours: is24hTimeFormatDefault()
    }

    function is24hTimeFormatDefault() {
        const timeFormatString = Qt.locale().timeFormat(Locale.LongFormat)
        return !d.amPmFormatChars.some(ampm => timeFormatString.includes(ampm))
    }

    /**
      Converts the Date to a string containing the date suitable for the specified locale in the specified format.

      - 'value' can be either a Date object, or a string containing a number or ISO string timestamp, or empty for "now"
      - 'format' can be one of Locale.LongFormat (default), Locale.ShortFormat
    */
    function formatDate(value, format = Locale.LongFormat) {
        value = d.readDate(value)
        const loc = Qt.locale()
        if (format === Locale.ShortFormat) { // replace 2-digit year with 4-digits (yy -> yyyy) in short format
            const dateFormatStr = loc.dateFormat(Locale.ShortFormat)
            if (!dateFormatStr.includes("yyyy")) {
                format = dateFormatStr.replace("yy", "yyyy")
            }
        }
        return value.toLocaleDateString(loc, format)
    }

    /**
      Converts the Date to a string containing the time suitable for the specified locale in the specified format.

      - 'value' can be either a Date object, or a string containing a number or ISO string timestamp, or empty for "now"
      - 'format' can be one of Locale.LongFormat (default), Locale.ShortFormat
    */
    function formatTime(value, format = Locale.LongFormat) {
        value = d.readDate(value)
        const loc = Qt.locale()
        const formatString = d.fixupTimeFormatString(loc.timeFormat(format))
        return value.toLocaleTimeString(loc, formatString)
    }

    /**
      Converts the Date to a string containing both the date and time suitable for the specified locale in the specified format.

      - 'value' can be either a Date object, or a string containing a number or ISO string timestamp, or empty for "now"
      - 'format' can be one of Locale.LongFormat (default), Locale.ShortFormat
    */
    function formatDateTime(value, format = Locale.LongFormat) {
        value = d.readDate(value)
        const loc = Qt.locale()
        var formatString = d.fixupTimeFormatString(loc.dateTimeFormat(format))
        if (format === Locale.ShortFormat && !formatString.includes("yyyy"))  // replace 2-digit year with 4-digits (yy -> yyyy) in short format
            formatString = formatString.replace("yy", "yyyy")

        return value.toLocaleString(loc, formatString)
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

    // FIXME Qt6 use IntlFormat (partial string)
    function getDayMonth(value) {
        const currentFormat = is24hTimeFormatDefault() ? "d MMM" : "MMM d"
        return formatDate(value, currentFormat)
    }

    // FIXME Qt6 use IntlFormat (partial string)
    function getMonthYear(value) {
        return formatDate(value, "MMM yyyy")
    }
}
