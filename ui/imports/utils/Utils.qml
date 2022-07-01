pragma Singleton

import QtQuick 2.13

import shared 1.0
import StatusQ.Core.Theme 0.1

QtObject {
    property var globalUtilsInst: globalUtils

    function isHex(value) {
        return /^(-0x|0x)?[0-9a-fA-F]*$/i.test(value)
    }

    function startsWith0x(value) {
        return value.startsWith('0x')
    }

    function isChatKey(value) {
        return (startsWith0x(value) && isHex(value) && value.length === 132) || globalUtilsInst.isCompressedPubKey(value)
    }

    function isValidETHNamePrefix(value) {
        return !(value.trim() === "" || value.endsWith(".") || value.indexOf("..") > -1)
    }

    function isAddress(value) {
        return startsWith0x(value) && isHex(value) && value.length === 42
    }

    function isPrivateKey(value) {
        return isHex(value) && ((startsWith0x(value) && value.length === 66) ||
                                (!startsWith0x(value) && value.length === 64))
    }

    function getCurrentThemeAccountColor(color) {
        const upperCaseColor = color.toUpperCase()
        if (Style.current.accountColors.indexOf(upperCaseColor) > -1) {
            return upperCaseColor
        }

        let colorIndex
        if (Style.current.name === Constants.lightThemeName) {
            colorIndex = Style.darkTheme.accountColors.indexOf(upperCaseColor)
        } else {
             colorIndex = Style.lightTheme.accountColors.indexOf(upperCaseColor)
        }
        if (colorIndex === -1) {
            // Unknown color
            return false
        }
        return Style.current.accountColors[colorIndex]
    }

    function getMessageWithStyle(msg, isCurrentUser, hoveredLink = "") {
        return `<style type="text/css">` +
                    `img, a, del, code, blockquote { margin: 0; padding: 0; }` +
                    `code {` +
                        `font-family: ${Style.current.fontCodeRegular.name};` +
                        `font-weight: 400;` +
                        `font-size: ${Style.current.secondaryTextFontSize};` +
                        `padding: 2px 4px;` +
                        `border-radius: 4px;` +
                        `background-color: ${Style.current.codeBackground};` +
                        `color: ${Style.current.black};` +
                        `white-space: pre;` +
                    `}` +
                    `p {` +
                        `line-height: 22px;` +
                    `}` +
                    `a {` +
                        `color: ${Style.current.linkColor};` +
                    `}` +
                    `a.mention {` +
                        `color: ${Style.current.mentionColor};` +
                        `background-color: ${Style.current.mentionBgColor};` +
                        `text-decoration: none;` +
                        `padding: 0px 2px;` +
                    `}` +
                    (hoveredLink !== "" ? `a.mention[href="${hoveredLink}"] { background-color: ${Style.current.mentionBgHoverColor}; }` : ``) +
                    `del {` +
                        `text-decoration: line-through;` +
                    `}` +
                    `table.blockquote td {` +
                        `padding-left: 10px;` +
                        `color: ${isCurrentUser ? Style.current.chatReplyCurrentUser : Style.current.secondaryText};` +
                    `}` +
                    `table.blockquote td.quoteline {` +
                        `background-color: ${isCurrentUser ? Style.current.chatReplyCurrentUser : Style.current.secondaryText};` +
                        `height: 100%;` +
                        `padding-left: 0;` +
                    `}` +
                    `.emoji {` +
                        `vertical-align: bottom;` +
                    `}` +
                    `span.isEdited {` +
                        `color: ${Style.current.secondaryText};` +
                        `margin-left: 5px` +
                    `}` +
                `</style>` +
                `${msg}`
    }

    function getReplyMessageStyle(msg, isCurrentUser) {
        return `<style type="text/css">`+
                    `a {`+
                        `color: ${Style.current.textColor};`+
                    `}`+
                    `a.mention {`+
                        `color: ${isCurrentUser ? Style.current.mentionColor : Style.current.turquoise};`+
                        `background-color: ${Style.current.mentionBgColor};` +
                    `}`+
               `</style>`+
               `</head>`+
               `<body>`+
                   `${msg}`+
               `</body>`+
            `</html>`
    }

    function getLinkStyle(link, hoveredLink, textColor) {
        return `<style type="text/css">` +
                `a {` +
                `color: ${textColor};` +
                `text-decoration: none;` +
                `}` +
                (hoveredLink !== "" ? `a[href="${hoveredLink}"] { text-decoration: underline; }` : "") +
                `</style>` +
                `<a href="${link}">${link}</a>`
    }

    function isMnemonic(value) {
        if(!value.match(/^([a-z\s]+)$/)){
            return false;
        }
        return  Utils.seedPhraseValidWordCount(value);
    }

    function compactAddress(addr, numberOfChars) {
        if(addr.length <= 5 + (numberOfChars * 2)){  //   5 represents these chars 0x...
            return addr;
        }
        return addr.substring(0, 2 + numberOfChars) + "..." + addr.substring(addr.length - numberOfChars);
    }

    function linkifyAndXSS(inputText) {
        //URLs starting with http://, https://, or ftp://
        var replacePattern1 = /(\b(https?|ftp|statusim):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
        var replacedText = inputText.replace(replacePattern1, "<a href='$1'>$1</a>");

        //URLs starting with "www." (without // before it, or it'd re-link the ones done above).
        var replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
        replacedText = replacedText.replace(replacePattern2, "$1<a href='http://$2'>$2</a>");

        return XSS.filterXSS(replacedText)
    }

    function filterXSS(inputText) {
        return XSS.filterXSS(inputText)
    }

    function toLocaleString(val, locale, options) {
      return NumberPolyFill.toLocaleString(val, locale, options)
    }

    function isOnlyEmoji(inputText) {
        var emoji_regex = /^(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|[\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|[\ud83c[\ude32-\ude3a]|[\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff]|\s)+$/;
        return emoji_regex.test(inputText);
    }

    function removeStatusEns(userName){
        return userName.endsWith(".stateofus.eth") ? userName.substr(0, userName.length - 14) : userName
    }

    function addStatusEns(userName){
        return userName.endsWith(".eth") ? userName : userName + ".stateofus.eth"
    }

    function isValidAddress(inputValue) {
        return inputValue !== "0x" && /^0x[a-fA-F0-9]{40}$/.test(inputValue)
    }

    function isValidEns(inputValue) {
        if (!inputValue) {
            return false
        }
        const isEmail = /(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/.test(inputValue)
        const isDomain = /(?:(?:(?<thld>[\w\-]*)(?:\.))?(?<sld>[\w\-]*))\.(?<tld>[\w\-]*)/.test(inputValue)
        return isEmail || isDomain || (inputValue.startsWith("@") && inputValue.length > 1)
    }


    /**
     * Removes trailing zeros from a string-representation of a number. Throws
     * if parameter is not a string
     */
    function stripTrailingZeros(strNumber) {
        if (!(typeof strNumber === "string")) {
            try {
                strNumber = strNumber.toString()
            } catch(e) {
                throw "[Utils.stripTrailingZeros] input parameter must be a string"
            }
        }
        return strNumber.replace(/(\.[0-9]*[1-9])0+$|\.0*$/,'$1')
    }

    /**
     * Removes starting zeros from a string-representation of a number. Throws
     * if parameter is not a string
     */
    function stripStartingZeros(strNumber) {
        if (!(typeof strNumber === "string")) {
            try {
                strNumber = strNumber.toString()
            } catch(e) {
                throw "[Utils.stripStartingZeros] input parameter must be a string"
            }
        }
        return strNumber.replace(/^(0*)([0-9\.]+)/, "$2")
    }


    function setColorAlpha(color, alpha) {
        return Qt.hsla(color.hslHue, color.hslSaturation, color.hslLightness, alpha)
    }

    function checkTimestamp(value, errorLocation) {
        if(Number.isInteger(value) && value > 0) {
            return true;
        }
        return false;
    }

    function formatTime(value, is24hTimeFormat) {
        const format24h = "hh:mm:ss t"
        const format12h = "h:mm:ss AP t"
        const currentTimeFormat = is24hTimeFormat ? format24h : format12h

        return checkTimestamp(value, "formatTime") ? Qt.formatTime(new Date(value), currentTimeFormat) :
                         Qt.formatTime(new Date(), currentTimeFormat)
    }

    function formatShortTime(value, is24hTimeFormat) {
        const format24h = "hh:mm"
        const format12h = "h:mm AP"
        const currentTimeFormat = is24hTimeFormat ? format24h : format12h

        return checkTimestamp(value, "formatShortTime") ? Qt.formatTime(new Date(value), currentTimeFormat) :
                         Qt.formatTime(new Date(), currentTimeFormat)
    }

    function formatShortDateStr(longStr) {
        const dmKeys = {
            // Days
            Sunday: qsTr("Sun"),
            Monday: qsTr("Mon"),
            Tuesday: qsTr("Tue"),
            Wednesday: qsTr("Wed"),
            Thursday: qsTr("Thu"),
            Friday: qsTr("Fri"),
            Saturday: qsTr("Sat"),
            // Months
            January: qsTr("Jan"),
            February: qsTr("Feb"),
            March: qsTr("Mar"),
            April: qsTr("Apr"),
            May: qsTr("May"),
            June: qsTr("Jun"),
            July: qsTr("Jul"),
            August: qsTr("Aug"),
            September: qsTr("Sep"),
            October: qsTr("Oct"),
            November: qsTr("Nov"),
            December: qsTr("Dec")
        };

        let shortStr = longStr;
        for (const [key, value] of Object.entries(dmKeys)) {
            shortStr = shortStr.replace(key, value);
            shortStr = shortStr.replace(key.toLowerCase(), value);
            shortStr = shortStr.replace(key.toUpperCase(), value);
        }

        return shortStr;
    }

    function formatLongDate(value, isDDMMYYDateFormat) {
        const formatDDMMYY = "dddd d MMMM yyyy"
        const formatMMDDYY = "dddd, MMMM d, yyyy"
        const currentFormat = isDDMMYYDateFormat ? formatDDMMYY : formatMMDDYY
        return checkTimestamp(value, "formatLongDate") ? Qt.formatDate(new Date(value), currentFormat) :
                         Qt.formatDate(new Date(), currentFormat)
    }

    function formatLongDateTime(value, isDDMMYYDateFormat, is24hTimeFormat) {
        const formatDDMMYY = "dddd d MMMM yyyy"
        const formatMMDDYY = "dddd, MMMM d, yyyy"
        const format24h = "hh:mm:ss t"
        const format12h = "h:mm:ss AP t"
        const currentDateFormat = isDDMMYYDateFormat ? formatDDMMYY : formatMMDDYY
        const currentTimeFormat = is24hTimeFormat ? format24h : format12h
        return checkTimestamp(value, "formatLongDateTime") ? Qt.formatDateTime(new Date(value), currentDateFormat + " " + currentTimeFormat) :
                         Qt.formatDateTime(new Date(), currentDateFormat + " " + currentTimeFormat)
    }

     // WARN: It is not used!! TO BE REMOVE??
    function formatDateTime(timestamp, locale) {
        let now = new Date()
        let yesterday = new Date()
        yesterday.setDate(now.getDate()-1)
        let messageDate = new Date(Math.floor(timestamp))
        let lastWeek = new Date()
        lastWeek.setDate(now.getDate()-7)

        let minutes = messageDate.getMinutes();
        let hours = messageDate.getHours();

        if (now.toDateString() === messageDate.toDateString()) {
            return (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes)
        } else if (yesterday.toDateString() === messageDate.toDateString()) {
            return qsTr("Yesterday")
        } else if (lastWeek.getTime() < messageDate.getTime()) {
            let days = [qsTr("Sunday"),
                        qsTr("Monday"),
                        qsTr("Tuesday"),
                        qsTr("Wednesday"),
                        qsTr("Thursday"),
                        qsTr("Friday"),
                        qsTr("Saturday")];
            return days[messageDate.getDay()];
        } else {
            return formatShortDateStr(new Date().toLocaleDateString(Qt.locale(locale)))
        }
    }

    // WARN: It is not used!! TO BE REMOVE??
    function formatAgeFromTime(timestamp, epoch) {
        epoch++ // pretending the parameter is not unused
        const now = new Date()
        const messageDate = new Date(Math.floor(timestamp))
        const diffMs = now - messageDate
        const diffMin = Math.floor(diffMs / 60000)
        if (diffMin < 1) {
            return qsTr("NOW")
        }
        const diffHour = Math.floor(diffMin / 60)
        if (diffHour < 1) {
            return qsTr("%1M").arg(diffMin)
        }
        const diffDay = Math.floor(diffHour / 24)
        if (diffDay < 1) {
            return qsTr("%1H").arg(diffHour)
        }
        return qsTr("%1D").arg(diffDay)
    }

    // To-do move to Wallet Store, this should not be under Utils.
    function findAssetByChainAndSymbol(chainIdToFind, assets, symbolToFind) {
        for(var i=0; i<assets.rowCount(); i++) {
            const symbol = assets.rowData(i, "symbol")
            if (symbol.toLowerCase() === symbolToFind.toLowerCase() && assets.hasChain(i, parseInt(chainIdToFind))) {
                return {
                    name: assets.rowData(i, "name"),
                    symbol,
                    totalBalance: assets.rowData(i, "totalBalance"),
                    totalCurrencyBalance: assets.rowData(i, "totalCurrencyBalance"),
                    fiatBalance: assets.rowData(i, "totalCurrencyBalance"),
                    chainId: chainIdToFind,
                }
            }
        }
    }

    function isValidChannelName(channelName) {
        return (/^[a-z0-9\-]+$/.test(channelName))
    }

    function isURL(text) {
        return (/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}(\.[a-zA-Z0-9()]{1,6})?\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)/.test(text))
    }

    function isURLWithOptionalProtocol(text) {
        return (/^(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)/.test(text))
    }

    function isHexColor(c) {
        return (/^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$/i.test(c))
    }

    function isSpace(c) {
        return (/( |\t|\n|\r)/.test(c))
    }

    function getTick(wordCount) {
        return (wordCount === 12 || wordCount === 15 ||
                wordCount === 18 || wordCount === 21 || wordCount === 24)
                ? "✓ " : "";
    }

    function isValidNumberOfWords(wordCount) {
        return !!getTick(wordCount);
    }

    function countWords(text) {
        if (text.trim() === "")
            return 0;
        return text.trim().replace(/  +/g, " ").split(" ").length;
    }

    function seedPhraseValidWordCount(text) {
        return isValidNumberOfWords(countWords(text))
    }

    /**
     * Returns text in the format "✓ 12 words" for seed phrases input boxes
     */
    function seedPhraseWordCountText(text) {
        let wordCount = countWords(text);
        return getTick(wordCount) + wordCount.toString() + " " + qsTr("words")
    }

    function uuid() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2, 5)
    }


    function validatePasswords(item, firstPasswordField, repeatPasswordField) {
        switch (item) {
            case "first":
                if (firstPasswordField.text === "") {
                    return [false, qsTr("You need to enter a password")];
                } else if (firstPasswordField.text.length < 6) {
                    return [false, qsTr("Password needs to be 6 characters or more")];
                }
                return [true, ""];

            case "repeat":
                if (repeatPasswordField.text === "") {
                    return [false, qsTr("You need to repeat your password")];
                } else if (repeatPasswordField.text !== firstPasswordField.text) {
                    return [false, qsTr("Passwords don't match")];
                }
                return [true, ""];

            default:
                return [false, ""];
        }
    }

      function validatePINs(item, firstPINField, repeatPINField) {
        switch (item) {
            case "first":
                if (firstPINField.text === "") {
                    return [false, qsTr("You need to enter a PIN")];
                } else if (!/^\d+$/.test(firstPINField.text)) {
                    return [false, qsTr("The PIN must contain only digits")];
                } else if (firstPINField.text.length != 6) {
                    return [false, qsTr("The PIN must be exactly 6 digits")];
                }
                return [true, ""];

            case "repeat":
                if (repeatPINField.text === "") {
                    return [false, qsTr("You need to repeat your PIN")];
                } else if (repeatPINField.text !== firstPINField.text) {
                    return [false, qsTr("PIN don't match")];
                }
                return [true, ""];

            default:
                return [false, ""];
        }
    }

    function getHostname(url) {
        const rgx = /\:\/\/(?:[a-zA-Z0-9\-]*\.{1,}){1,}[a-zA-Z0-9]*/i
        const matches = rgx.exec(url)
        if (!matches || !matches.length) {
            if (url.includes(Constants.deepLinkPrefix)) {
                return Constants.deepLinkPrefix
            }
            return  ""
        }
        return matches[0].substring(3)
    }

    function hasImageExtension(url) {
        return Constants.acceptedImageExtensions.some(ext => url.toLowerCase().includes(ext))
    }

    function removeGifUrls(message) {
        return message.replace(/(?:https?|ftp):\/\/[\n\S]*(\.gif)+/gm, '');
    }

    function hasDragNDropImageExtension(url) {
        return Constants.acceptedDragNDropImageExtensions.some(ext => url.toLowerCase().includes(ext))
    }

    function deduplicate(array) {
        return Array.from(new Set(array))
    }

    function hasUpperCaseLetter(str) {
        return (/[A-Z]/.test(str))
    }

    function convertSpacesToDashesAndUpperToLowerCase(str)
    {
        if (str.includes(" "))
            str = str.replace(/ /g, "-")

        if(hasUpperCaseLetter(str))
            str = str.toLowerCase()

        return str
    }

    /* Validation section start */

    enum Validate {
        NoEmpty = 0x01,
        TextLength = 0x02,
        TextHexColor = 0x04,
        TextLowercaseLettersNumberAndDashes = 0x08
    }

    function validateAndReturnError(str, validation, fieldName = "field", limit = 0)
    {
        let errMsg = ""

        if(validation & Utils.Validate.NoEmpty && str === "") {
            errMsg = qsTr("You need to enter a %1").arg(fieldName)
        }

        if(validation & Utils.Validate.TextLength && str.length > limit) {
            errMsg = qsTr("The %1 cannot exceed %2 characters").arg(fieldName, limit)
        }

        if(validation & Utils.Validate.TextHexColor && !isHexColor(str)) {
            errMsg = qsTr("Must be an hexadecimal color (eg: #4360DF)")
        }

        if(validation & Utils.Validate.TextLowercaseLettersNumberAndDashes && !isValidChannelName(str)) {
            errMsg = qsTr("Use only lowercase letters (a to z), numbers & dashes (-). Do not use chat keys.")
        }

        return errMsg
    }

    function getErrorMessage(errors, fieldName) {
        if (errors) {
            if (errors.minLength) {
                return errors.minLength.min === 1 ?
                    qsTr("You need to enter a %1").arg(fieldName) :
                    qsTr("Value has to be at least %1 characters long").arg(errors.minLength.min)
            }
        }
        return ""
    }

    /* Validation section end */

    function getLabelForEstimatedTxTime(estimatedFlag) {
        if (estimatedFlag === Constants.transactionEstimatedTime.unknown) {
            return qsTr("Unknown")
        }

        if (estimatedFlag === Constants.transactionEstimatedTime.lessThanOneMin) {
            return qsTr("< 1 min")
        }
        if (estimatedFlag === Constants.transactionEstimatedTime.lessThanThreeMins) {
            return qsTr("< 3 mins")
        }
        if (estimatedFlag === Constants.transactionEstimatedTime.lessThanFiveMins) {
                return qsTr("< 5 mins")
        }

        return qsTr("> 5 mins")
    }

    function getContactDetailsAsJson(publicKey) {
        let jsonObj = mainModule.getContactDetailsAsJson(publicKey)
        try {
            let obj = JSON.parse(jsonObj)
            return obj
        }
        catch (e) {
            // This log is available only in debug mode, if it's annoying we can remove it
            console.debug("error parsing contact details for public key: ", publicKey, " error: ", e.message)

            return {
                displayName: "",
                displayIcon: "",
                publicKey: publicKey,
                name: "",
                ensVerified: false,
                alias: "",
                lastUpdated: 0,
                lastUpdatedLocally: 0,
                localNickname: "",
                thumbnailImage: "",
                largeImage: "",
                isContact: false,
                isAdded: false,
                isBlocked: false,
                requestReceived: false,
                isSyncing: false,
                removed: false,
                trustStatus: Constants.trustStatus.unknown,
                verificationStatus: Constants.verificationStatus.unverified
            }
        }
    }

    function getEmojiHashAsJson(publicKey) {
        if (publicKey === "") {
            return ""
        }
        let jsonObj = globalUtils.getEmojiHashAsJson(publicKey)
        return JSON.parse(jsonObj)
    }

    function getColorHashAsJson(publicKey) {
        if (publicKey === "") {
            return ""
        }
        let jsonObj = globalUtils.getColorHashAsJson(publicKey)
        return JSON.parse(jsonObj)
    }

    function colorIdForPubkey(publicKey) {
        if (publicKey === "") {
            return 0
        }
        return globalUtils.getColorId(publicKey)
    }

    function colorForPubkey(publicKey) {
        return Theme.palette.userCustomizationColors[colorIdForPubkey(publicKey)]
    }

    function getCompressedPk(publicKey) {
        if (publicKey === "") {
            return ""
        }
        return globalUtils.getCompressedPk(publicKey)
    }

    function getElidedCompressedPk(publicKey) {
        if (publicKey === "") {
            return ""
        }
        let compressedPk = getCompressedPk(publicKey)
        return elideText(compressedPk, 6, 3)
    }

    function elideText(text, leftCharsCount, rightCharsCount = leftCharsCount) {
        return text.substr(0, leftCharsCount) + "..." + text.substr(text.length - rightCharsCount)
    }

    function getTimeDifference(d1, d2) {
        var timeString = ""
        var day1Year = d1.getFullYear()
        var day1Month = d1.getMonth()
        var day1Time = d1.getTime()

        var day2Year = d2.getFullYear()
        var day2Month = d2.getMonth()
        var day2Time = d2.getTime()

        var inYears = day2Year-day1Year

        if(inYears > 0) {
            timeString =  inYears > 1 ? qsTr("years ago") : qsTr("year ago")
            return inYears + " " + timeString
        }

        var inMonths = (day2Month+12*day2Year)-(day1Month+12*day1Year)

        if(inMonths > 0) {
            timeString =  inMonths > 1 ? qsTr("months ago") : qsTr("month ago")
            return inMonths + " " + timeString
        }

        var inWeeks = parseInt((day2Time-day2Time)/(24*3600*1000*7))

        if(inWeeks > 0) {
            timeString =  inWeeks > 1 ? qsTr("weeks ago") : qsTr("week ago")
            return inWeeks + " " + timeString
        }

        var inDays = parseInt((day2Time-day1Time)/(24*3600*1000))

        if(inDays > 0) {
            timeString =  inDays > 1 ? qsTr("days ago") : qsTr("day ago")
            return inDays + " " + timeString
        }

        var inHours = parseInt((day2Time-day1Time)/(3600*1000));

        if(inHours > 0) {
            timeString =  inHours > 1 ? qsTr("hours ago") : qsTr("hour ago")
            return inHours + " " + timeString
        }

        var inMins = parseInt((day2Time-day1Time)/(60*1000))

        if(inMins > 0) {
            timeString =  inMins > 1 ? qsTr("mins ago") : qsTr("min ago")
            return inMins + " " + timeString
        }

        var inSecs = parseInt((day2Time-day1Time)/(1000));

        if(inSecs > 0) {
            timeString =  inSecs > 1 ? qsTr("secs ago") : qsTr("sec ago")
            return inSecs + " " + timeString
        }

        return qsTr("now")
    }

    function elideIfTooLong(str, maxLength) {
        return (str.length > maxLength) ? str.substr(0, maxLength-4) + '...' : str;
    }

    function escapeHtml(unsafeStr)
    {
        return unsafeStr
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    function isInvalidPasswordMessage(msg) {
        return (
            msg.includes("could not decrypt key with given password") ||
            msg.includes("invalid password")
        );
    }

    function isInvalidPath(msg) {
        return msg.includes("error parsing derivation path")
    }

    function accountAlreadyExistsError(msg) {
        return msg.includes("account already exists")
    }

    // Leave this function at the bottom of the file as QT Creator messes up the code color after this
    function isPunct(c) {
        return /(!|\@|#|\$|%|\^|&|\*|\(|\)|_|\+|\||-|=|\\|{|}|[|]|"|;|'|<|>|\?|,|\.|\/)/.test(c)
    }

}
