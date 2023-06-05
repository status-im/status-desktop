pragma Singleton

import QtQml 2.14
import Qt.labs.settings 1.0

QtObject {
    id: root

    readonly property var userInputLocale: Qt.locale("en_US")

    function integralPartLength(num) {
        num = Math.abs(num)

        // According to the JS Reference:
        //
        // Scientific notation is used if the radix is 10 and the number's
        // magnitude (ignoring sign) is greater than or equal to 10^21 or less
        // than 10^-6. In this case, the returned string always explicitly
        // specifies the sign of the exponent.
        //
        // In order to take it into account, numbers in scientific notation
        // is handled separately.

        if (num < 1) {
            return 1
        }

        if (num >= 10**21) {
            const split = num.toString().split('e')
            if (split.length === 2) {
                const base = parseFloat(split[0])
                const exp = parseInt(split[1], 10)
                return integralPartLength(base) + exp
            }
        }

        return num.toFixed().length
    }

    function fractionalPartLength(num) {
        if (Number.isInteger(num))
            return 0

        // According to the JS Reference:
        //
        // Scientific notation is used if the radix is 10 and the number's
        // magnitude (ignoring sign) is greater than or equal to 10^21 or less
        // than 10^-6. In this case, the returned string always explicitly
        // specifies the sign of the exponent.
        //
        // In order to take it into account, numbers in scientific notation
        // is handled separately.

        if (Math.abs(num) < 10**-6) {
            const split = num.toString().split('e-')
            const base = parseFloat(split[0])
            const exp = parseInt(split[1])
            return fractionalPartLength(base) + exp
        }

        if (num >= 10**21) {
            return 0
        }

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
            return NaN
        }
    }

    function getLocalizedDigitsCount(str, locale = null) {
        if (!str)
            return 0

        locale = locale || Qt.locale()

        if (d.nonDigitCharacterRegExpLocale !== locale)
            d.nonDigitCharacterRegExpLocale = locale

        return str.replace(d.nonDigitCharacterRegExp, "").length
    }

    function currencyAmountToLocaleString(currencyAmount, options = null, locale = null) {
        locale = locale || Qt.locale()

        if (!currencyAmount) {
            return qsTr("N/A")
        }
        if (typeof(currencyAmount) !== "object") {
            console.warn("Wrong type for currencyAmount: " + JSON.stringify(currencyAmount))
            console.trace()
            return qsTr("N/A")
        }
        if (typeof currencyAmount.amount === "undefined")
            return qsTr("N/A")

        // Parse options
        var optNoSymbol = false
        var optRawAmount = false
        var optDisplayDecimals = currencyAmount.displayDecimals
        var optStripTrailingZeroes = currencyAmount.stripTrailingZeroes
        if (options) {
            if (options.noSymbol !== undefined) {
                optNoSymbol = true
            }
            if (options.rawAmount !== undefined) {
                optRawAmount = true
            }
            if (options.minDecimals !== undefined && options.minDecimals > optDisplayDecimals) {
                optDisplayDecimals = options.minDecimals
            }
            if (options.stripTrailingZeroes !== undefined) {
                optStripTrailingZeroes = options.stripTrailingZeroes
            }
        }

        var amountStr = ""
        var amountSuffix = ""

        let minAmount = 10**-optDisplayDecimals
        if (currencyAmount.amount > 0 && currencyAmount.amount < minAmount && !optRawAmount)
        {
            // Handle amounts smaller than resolution
            amountStr = "<%1".arg(numberToLocaleString(minAmount, displayDecimals, locale))
        } else {
            var amount
            var displayDecimals
            const numIntegerDigits = integralPartLength(currencyAmount.amount)
            const maxDigits = 11 // We add "B" suffix only after 999 Billion
            const maxDigitsToShowDecimal = 6 // We do not display decimal places after 1 million
            // For large numbers, we use the short scale system (https://en.wikipedia.org/wiki/Long_and_short_scales)
            // and 2 decimal digits.
            if (numIntegerDigits > maxDigits && !optRawAmount) {
                amount = currencyAmount.amount/10**9 // Billion => 9 zeroes
                displayDecimals = 2
                amountSuffix = qsTr("B", "Billion")
            } else {
                // For normal numbers, we show the whole integral part and as many decimal places not
                // not to exceed the maximum
                amount = currencyAmount.amount
		 // For numbers over 1M , dont show decimal places
                if(numIntegerDigits > maxDigitsToShowDecimal) {
                    displayDecimals = 0
                }
                else {
                    displayDecimals = Math.min(optDisplayDecimals, Math.max(0, maxDigits - numIntegerDigits))
                }
            }
            amountStr = numberToLocaleString(amount, displayDecimals, locale)
            if (optStripTrailingZeroes) {
                amountStr = stripTrailingZeroes(amountStr, locale)
            }
        }

        // Add symbol
        if (currencyAmount.symbol && !optNoSymbol) {
            amountStr = "%1%2 %3".arg(amountStr).arg(amountSuffix).arg(currencyAmount.symbol)
        }

        return amountStr
    }

    // DATE/TIME
    readonly property var d: QtObject {
        id: d

        readonly property var amPmFormatChars: ["AP", "A", "ap", "a"]

        readonly property int msInADay: 86400000

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

        property var nonDigitCharacterRegExpLocale

        readonly property var nonDigitCharacterRegExp: {
            const localizedNumbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map(
                    n => LocaleUtils.numberToLocaleString(n, 0, nonDigitCharacterRegExpLocale))

            return new RegExp(`[^${localizedNumbers.join("")}]`, "g")
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

    // return full days between 2 dates
    function daysBetween(firstDate, secondDate) {
        firstDate.setHours(0, 0, 0) // discard time
        secondDate.setHours(0, 0, 0)
        return Math.round(Math.abs((firstDate - secondDate) / d.msInADay)) // Math.round: not all days are 24 hours long!
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

    // TODO use JS Intl.RelativeTimeFormat in Qt 6?
    function formatRelativeTimestamp(timestamp) {
        const now = new Date()
        const value = d.readDate(timestamp)
        const loc = Qt.locale()
        const formatString = d.fixupTimeFormatString(loc.timeFormat(Locale.ShortFormat)) // format string for the time part
        const dayDifference = daysBetween(d.readDate(timestamp), now)

        // within last day, 2 or 7 days
        if (dayDifference < 1) // today -> "Today 14:23"
            return qsTr("Today %1").arg(value.toLocaleTimeString(loc, formatString))

        if (dayDifference < 2) // yesterday -> "Yesterday 14:23"
            return qsTr("Yesterday %1").arg(value.toLocaleTimeString(loc, formatString))

        if (dayDifference < 7) // last 7 days -> "Mon 14:23"
            return qsTr("%1 %2").arg(loc.standaloneDayName(value.getDay(), Locale.ShortFormat)).arg(value.toLocaleTimeString(loc, formatString))

        // otherwise
        var fullFormatString = d.fixupTimeFormatString(loc.dateTimeFormat(Locale.ShortFormat))
        if (now.getFullYear() === value.getFullYear()) {
            // strip year part, if current year -> "31 December 09:41"
            // It remove preceding dot or space
            fullFormatString = fullFormatString.replace(/([.\s])?\b(y+)\b/g, "")
        } else if (!fullFormatString.includes("yyyy")) {
            fullFormatString = fullFormatString.replace("yy", "yyyy") // different year -> "31 December 2022 09:41"
        }

        return value.toLocaleString(loc, fullFormatString)
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

    function getDayName(value) {
        return Qt.locale().standaloneDayName(value.getDay())
    }
}
