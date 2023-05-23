pragma Singleton

import QtQuick 2.13

import shared 1.0
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

QtObject {
    property var mainModuleInst: typeof mainModule !== "undefined" ? mainModule : null
    property var globalUtilsInst: typeof globalUtils !== "undefined" ? globalUtils : null

    readonly property int maxImgSizeBytes: Constants.maxUploadFilesizeMB * 1048576 /* 1 MB in bytes */

    function isDigit(value) {
      return /^\d$/.test(value);
    }

    function isHex(value) {
        return /^(-0x|0x)?[0-9a-fA-F]*$/i.test(value)
    }

    function startsWith0x(value) {
        return value.startsWith('0x')
    }

    function isChatKey(value) {
        return (startsWith0x(value) && isHex(value) && value.length === 132) || globalUtilsInst.isCompressedPubKey(value)
    }

    function isCommunityPublicKey(value) {
        return (startsWith0x(value) && isHex(value) && value.length === 68) || globalUtilsInst.isCompressedPubKey(value)
    }

    function isCompressedPubKey(pubKey) {
      return globalUtilsInst.isCompressedPubKey(pubKey)
    }

    function isValidETHNamePrefix(value) {
        return !(value.trim() === "" || value.endsWith(".") || value.indexOf("..") > -1)
    }

    function isAddress(value) {
        return startsWith0x(value) && isHex(value) && value.length === 42
    }

    function isValidAddressWithChainPrefix(value) {
        return value.match(/^(([a-zA-Z]{3,5}:)*)?(0x[a-fA-F0-9]{40})$/)
    }

    function getChainsPrefix(address) {
        // matchAll is not supported by QML JS engine
        return address.match(/([a-zA-Z]{3,5}:)*/)[0].split(':').filter(e => !!e)
    }

    function isLikelyEnsName(text) {
        return text.startsWith("@") || !isLikelyAddress(text)
    }

    function isLikelyAddress(text) {
        return text.includes(":") || text.includes('0x')
    }

    function richColorText(text, color) {
        return "<font color=\"" + color + "\">" + text + "</font>"
    }

    function splitToChainPrefixAndAddress(input) {
        const addressIdx = input.indexOf('0x')
        if (addressIdx < 0)
            return { prefix: input, address: "" }

        return { prefix: input.substring(0, addressIdx), address: input.substring(addressIdx) }
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

    function toLocaleString(val, locale, options) {
        if (typeof(val) === "object") {
            console.log("Wrong type for val: " + JSON.stringify(val))
            return NaN
        }
        return NumberPolyFill.toLocaleString(val, locale, options)
    }

    function isOnlyEmoji(inputText) {
        var emoji_regex = /^(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|[\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|[\ud83c[\ude32-\ude3a]|[\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff]|\s)+$/;
        return emoji_regex.test(inputText);
    }

    function isValidAddress(inputValue) {
        return inputValue !== "0x" && /^0x[a-fA-F0-9]{40}$/.test(inputValue)
    }

    function isValidEns(inputValue) {
        if (!inputValue) {
            return false
        }
        const isEmail = /(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/.test(inputValue)
        const isDomain = /\b((?=[a-z0-9-]{1,63}\.)(xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,63}\b/.test(inputValue)
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
                } else if (firstPasswordField.text.length < Constants.minPasswordLength) {
                    return [false, qsTr("Password needs to be %n character(s) or more", "", Constants.minPasswordLength)];
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
                if (firstPINField.pinInput === "") {
                    return [false, qsTr("You need to enter a PIN")];
                } else if (!/^\d+$/.test(firstPINField.pinInput)) {
                    return [false, qsTr("The PIN must contain only digits")];
                } else if (firstPINField.pinInput.length != Constants.keycard.general.keycardPinLength) {
                    return [false, qsTr("The PIN must be exactly %1 digits").arg(Constants.keycard.general.keycardPinLength)];
                }
                return [true, ""];

            case "repeat":
                if (repeatPINField.pinInput === "") {
                    return [false, qsTr("You need to repeat your PIN")];
                } else if (repeatPINField.pinInput !== firstPINField.pinInput) {
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

    function isStatusDeepLink(link) {
        return link.includes(Constants.deepLinkPrefix) || link.includes(Constants.externalStatusLink)
    }

    function hasImageExtension(url) {
        return Constants.acceptedImageExtensions.some(ext => url.toLowerCase().includes(ext))
    }

    function removeGifUrls(message) {
        return message.replace(/(?:https?|ftp):\/\/[\n\S]*(\.gif)+/gm, '');
    }

    function isValidDragNDropImage(url) {
        let lowerCaseUrl = url.toLowerCase()
        return Constants.acceptedDragNDropImageExtensions.some(ext => lowerCaseUrl.endsWith(ext)) ||
            lowerCaseUrl.startsWith(Constants.dataImagePrefix);
    }

    function isFilesizeValid(img) {
        if (img.startsWith(Constants.dataImagePrefix)) {
            return img.length < maxImgSizeBytes
        }
        let size = parseInt(globalUtils.getFileSize(img))
        return size <= maxImgSizeBytes
    }

    function deduplicate(array) {
        return Array.from(new Set(array))
    }

    function hasUpperCaseLetter(str) {
        return (/[A-Z]/.test(str))
    }

    function convertSpacesToDashes(str)
    {
        return str.replace(/ /g, "-")
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

    function getContactDetailsAsJson(publicKey, getVerificationRequest=true) {
        const defaultValue = {
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
            verificationStatus: Constants.verificationStatus.unverified,
            incomingVerificationStatus: Constants.verificationStatus.unverified
        }

        if (!mainModuleInst || !publicKey)
            return defaultValue

        const jsonObj = mainModuleInst.getContactDetailsAsJson(publicKey, getVerificationRequest)

        try {
            return JSON.parse(jsonObj)
        }
        catch (e) {
            // This log is available only in debug mode, if it's annoying we can remove it
            console.warn("error parsing contact details for public key: ", publicKey, " error: ", e.message)
            return defaultValue
        }
    }

    function isEnsVerified(publicKey) {
        if (publicKey === "" || !isChatKey(publicKey) )
            return false
        if (!mainModuleInst)
            return false
        return mainModuleInst.isEnsVerified(publicKey)
    }

    function getEmojiHashAsJson(publicKey) {
        if (publicKey === "" || !isChatKey(publicKey)) {
            return ""
        }
        let jsonObj = globalUtilsInst.getEmojiHashAsJson(publicKey)
        return JSON.parse(jsonObj)
    }

    function getColorHashAsJson(publicKey, skipEnsVerification=false) {
        if (publicKey === "" || !isChatKey(publicKey))
            return
        if (skipEnsVerification) // we know already the user is ENS verified -> no color ring
            return
        if (isEnsVerified(publicKey)) // ENS verified -> no color ring
            return
        let jsonObj = globalUtilsInst.getColorHashAsJson(publicKey)
        return JSON.parse(jsonObj)
    }

    function colorIdForPubkey(publicKey) {
        if (publicKey === "" || !isChatKey(publicKey)) {
            return 0
        }
        return globalUtilsInst.getColorId(publicKey)
    }

    function colorForColorId(colorId)  {
        if (colorId < 0 || colorId >= Theme.palette.userCustomizationColors.length) {
            console.warn("Utils.colorForColorId : colorId is out of bounds")
            return StatusColors.colors['blue']
        }
        return Theme.palette.userCustomizationColors[colorId]
    }

    function colorForPubkey(publicKey) {
        const pubKeyColorId = colorIdForPubkey(publicKey)
        return colorForColorId(pubKeyColorId)
    }

    function getCommunityShareLink(communityId, elided = false) {
        if (communityId === "") {
            return ""
        }

        let compressedPk = communityId
        if (!globalUtilsInst.isCompressedPubKey(compressedPk)) {
            compressedPk = globalUtilsInst.changeCommunityKeyCompression(compressedPk)
        }
        return Constants.communityLinkPrefix +
                (elided ? StatusQUtils.Utils.elideText(compressedPk, 4, 2) : compressedPk)
    }

    function getChatKeyFromShareLink(link) {
        let index = link.lastIndexOf("/u/")
        if (index === -1) {
            return link
        }
        return link.substring(index + 3)
    }

    function getCommunityIdFromShareLink(link) {
        let index = link.lastIndexOf("/c/")
        if (index === -1) {
            return ""
        }
        const communityKey = link.substring(index + 3)
        if (globalUtilsInst.isCompressedPubKey(communityKey)) {
            // is zQ.., need to be converted to standard compression
            return globalUtilsInst.changeCommunityKeyCompression(communityKey)
        }
        return communityKey
    }


    function changeCommunityKeyCompression(communityKey) {
        return globalUtilsInst.changeCommunityKeyCompression(communityKey)
    }

    function getCompressedPk(publicKey) {
        if (publicKey === "") {
            return ""
        }
        if (!isChatKey(publicKey))
            return publicKey
        return globalUtilsInst.getCompressedPk(publicKey)
    }

    function getElidedPk(publicKey) {
        if (publicKey === "") {
            return ""
        }
        return StatusQUtils.Utils.elideText(publicKey, 5, 3)
    }

    function getElidedCommunityPK(publicKey) {
        if (publicKey === "") {
            return ""
        }
        return StatusQUtils.Utils.elideText(publicKey, 16)
    }

    function getElidedCompressedPk(publicKey) {
        if (publicKey === "") {
            return ""
        }
        let compressedPk = getCompressedPk(publicKey)
        return getElidedPk(compressedPk, 6, 3)
    }

    function elideIfTooLong(str, maxLength) {
        return (str.length > maxLength) ? str.substr(0, maxLength-4) + '...' : str;
    }

    function escapeHtml(unsafeStr) {
        return globalUtilsInst.escapeHtml(unsafeStr)
    }

    function plainText(text) {
        return globalUtilsInst.plainText(text)
    }

    function isInvalidPasswordMessage(msg) {
        return (
            msg.includes("could not decrypt key with given password") ||
            msg.includes("invalid password")
        );
    }

    function isInvalidPrivateKey(msg) {
        return msg.includes("invalid private key");
    }

    function isInvalidPath(msg) {
        return msg.includes(Constants.wrongDerivationPathError)
    }

    function accountAlreadyExistsError(msg) {
        return msg.includes(Constants.existingAccountError)
    }

    // See also: backend/interpret/cropped_image.nim
    function getImageAndCropInfoJson(imgPath, cropRect) {
        return JSON.stringify({imagePath: String(imgPath).replace("file://", ""), cropRect: cropRect})
    }

    // handle translations for section names coming from app_sections_config.nim
    function translatedSectionName(sectionType, fallback) {
        switch(sectionType) {
        case Constants.appSection.chat:
            return qsTr("Messages")
        case Constants.appSection.wallet:
            return qsTr("Wallet")
        case Constants.appSection.browser:
            return qsTr("Browser")
        case Constants.appSection.profile:
            return qsTr("Settings")
        case Constants.appSection.node:
            return qsTr("Node Management")
        case Constants.appSection.communitiesPortal:
            return qsTr("Communities Portal")
        default:
            return fallback
        }
    }

    function getFontSizeBasedOnLetterCount(text) {
        if(text.length >= 12)
            return 18
        if(text.length >= 10)
            return 24
        if(text.length > 6)
            return 28
        else
            return 34
    }

    function getTimerString(timeInSecs) {
        let result = ""
        const hour = Math.floor(timeInSecs/60/60)
        const mins = Math.floor(timeInSecs/60%60)
        const secs = Math.floor(timeInSecs%60)
        if(hour > 0 )
            result += qsTr(" %n hour(s) ", "", hour)
        if(mins > 0)
            result += qsTr(" %n min(s) ", "", mins)
        if(secs > 0)
            result += qsTr(" %n sec(s) ", "", secs)
        return result
    }

    function appTranslation(key) {
        switch(key) {
        case Constants.appTranslatableConstants.loginAccountsListAddNewUser:
            return qsTr("Add new user")
        case Constants.appTranslatableConstants.loginAccountsListAddExistingUser:
            return qsTr("Add existing Status user")
        case Constants.appTranslatableConstants.loginAccountsListLostKeycard:
            return qsTr("Lost Keycard")
        case Constants.appTranslatableConstants.addAccountLabelNewWatchOnlyAccount:
            return qsTr("New watch-only account")
        case Constants.appTranslatableConstants.addAccountLabelWatchOnlyAccount:
            return qsTr("Watch-only account")
        case Constants.appTranslatableConstants.addAccountLabelExisting:
            return qsTr("Existing")
        case Constants.appTranslatableConstants.addAccountLabelImportNew:
            return qsTr("Import new")
        case Constants.appTranslatableConstants.addAccountLabelOptionAddNewMasterKey:
            return qsTr("Add new master key")
        case Constants.appTranslatableConstants.addAccountLabelOptionAddWatchOnlyAcc:
            return qsTr("Add watch-only account")
        }

        // special handling because on an index attached to the constant
        if (key.startsWith(Constants.appTranslatableConstants.keycardAccountNameOfUnknownWalletAccount)) {
            let num = key.substring(Constants.appTranslatableConstants.keycardAccountNameOfUnknownWalletAccount.length)
            return "%1%2".arg(qsTr("acc")).arg(num) //short name of an unknown (removed) wallet account
        }

        return key
    }

    function dropUserLinkPrefix(text) {
        if (text.startsWith(Constants.userLinkPrefix))
            text = text.slice(Constants.userLinkPrefix.length)
        return text
    }

    function dropCommunityLinkPrefix(text) {
        if (text.startsWith(Constants.communityLinkPrefix))
            text = text.slice(Constants.communityLinkPrefix.length)
        return text
    }

    function copyImageToClipboardByUrl(content) {
        globalUtilsInst.copyImageToClipboardByUrl(content)
    }

    function downloadImageByUrl(url, path) {
        globalUtilsInst.downloadImageByUrl(url, path)
    }

    // Leave this function at the bottom of the file as QT Creator messes up the code color after this
    function isPunct(c) {
        return /(!|\@|#|\$|%|\^|&|\*|\(|\)|\+|\||-|=|\\|{|}|[|]|"|;|'|<|>|\?|,|\.|\/)/.test(c)
    }
}
