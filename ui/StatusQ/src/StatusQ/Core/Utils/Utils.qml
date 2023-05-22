pragma Singleton

import QtQuick 2.13
import StatusQ.Core.Theme 0.1
import "./xss.js" as XSS

QtObject {
    id: root

    function getAbsolutePosition(node) {
        var returnPos = {};
        returnPos.x = 0;
        returnPos.y = 0;
        if (node !== undefined && node !== null) {
            var parentValue = getAbsolutePosition(node.parent);
            returnPos.x = parentValue.x + node.x;
            returnPos.y = parentValue.y + node.y;
        }
        return returnPos;
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

    function isURL(text) {
        return (/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}(\.[a-zA-Z0-9()]{1,6})?\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)/.test(text))
    }

    function uuid() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2, 5)
    }

    function getThemeAccountColor(c, accountColors) {
        const upperCaseColor = c.toUpperCase()
        let colorIndex = accountColors.indexOf(upperCaseColor)

        if (colorIndex > -1) {
            return upperCaseColor
        }
        return false
    }

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

    function isHtml(text) {
        return (/<\/?[a-z][\s\S]*>/i.test(text))
    }

    // function to draw arrow
    function drawArrow(context, fromx, fromy, tox, toy, color, offset) {
        const fromX = fromx + 8
        const toX = tox - 8
        const dx = toX - fromX;
        const dy = toy - fromy;
        const headlen = 8; // length of head in pixels
        const angle = 0
        const radius = 4

        context.strokeStyle = color ? color : '#627EEA'

        // straight line
        if(dy === 0) {
            // draw circle
            context.setLineDash([20,0])
            context.beginPath()
            context.arc(fromX+radius, fromy, radius, 0, 360)
            context.stroke()

            // draw straightline
            context.setLineDash([3])
            context.beginPath()
            context.moveTo(fromX + 2*radius, fromy)
            context.lineTo(toX, toy)
            context.stroke()

            // draw arrow
            context.setLineDash([20,0])
            context.beginPath()
            context.moveTo(toX - headlen * Math.cos(angle - Math.PI / 4), toy - headlen * Math.sin(angle - Math.PI / 4))
            context.lineTo(toX, toy)
            context.lineTo(toX - headlen * Math.cos(angle + Math.PI / 4), toy - headlen * Math.sin(angle + Math.PI / 4))
            context.stroke()
        }
        // connecting between 2 different y positions
        else {
            // draw circle
            context.setLineDash([20,0])
            context.beginPath()
            context.arc(fromX+radius, fromy, radius, 0, 360)
            context.stroke()

            // draw bent line
            context.setLineDash([3])
            context.beginPath()
            context.moveTo(fromX + 2*radius, fromy)
            context.lineTo(fromX + dx / 2 - offset, fromy)
            context.lineTo(fromX + dx / 2 - offset, toy + (dy < 0 ? radius : -radius))
            context.stroke()

            // draw connecting circle
            context.setLineDash([20,0])
            context.beginPath()
            context.moveTo(fromX + dx / 2 + radius - offset, toy)
            context.arc(fromX + dx / 2 - offset, toy, radius, 0, 2*Math.PI,false)
            context.stroke()

            // draw straightline
            context.setLineDash([3])
            context.beginPath()
            context.moveTo(fromX + dx / 2 + 2*radius - offset, toy);
            context.lineTo(toX, toy)
            context.stroke()

            // draw arrow
            context.setLineDash([20,0])
            context.beginPath()
            context.moveTo(toX - headlen * Math.cos(angle - Math.PI / 6), toy - headlen * Math.sin(angle - Math.PI / 6))
            context.lineTo(toX, toy )
            context.lineTo(toX - headlen * Math.cos(angle + Math.PI / 6), toy - headlen * Math.sin(angle + Math.PI / 6))
            context.stroke()
        }
    }

    function linkifyAndXSS(inputText) {
        //URLs starting with http://, https://, ftp:// or status-app://
        var replacePattern1 = /(\b(https?|ftp|status-app):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;\(\)]*[-A-Z0-9+&@#\/%=~_|])/gim;
        var replacedText = inputText.replace(replacePattern1, "<a href='$1'>$1</a>");

        //URLs starting with "www." (without // before it, or it'd re-link the ones done above).
        var replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
        replacedText = replacedText.replace(replacePattern2, "$1<a href='http://$2'>$2</a>");

        return XSS.filterXSS(replacedText)
    }

    function filterXSS(inputText) {
        return XSS.filterXSS(inputText)
    }

    function getMessageWithStyle(msg, hoveredLink = "") {
        return `<style type="text/css">` +
                    `img, a, del, code, blockquote { margin: 0; padding: 0; }` +
                    `code {` +
                        `font-family: ${Theme.palette.codeFont.name};` +
                        `font-weight: 400;` +
                        `font-size: 14;` +
                        `padding: 2px 4px;` +
                        `border-radius: 4px;` +
                        `background-color: ${Theme.palette.baseColor2};` +
                        `color: ${Theme.palette.directColor1};` +
                        `white-space: pre;` +
                    `}` +
                    `p {` +
                        `line-height: 22px;` +
                    `}` +
                    `a {` +
                        `color: ${Theme.palette.primaryColor1};` +
                    `}` +
                    `a.mention {` +
                        `color: ${Theme.palette.mentionColor1};` +
                        `background-color: ${Theme.palette.mentionColor4};` +
                        `text-decoration: none;` +
                        `padding: 0px 2px;` +
                    `}` +
                    (hoveredLink !== "" ? `a.mention[href="${hoveredLink}"] { background-color: ${Theme.palette.mentionColor2}; }` : ``) +
                    `del {` +
                        `text-decoration: line-through;` +
                    `}` +
                    `.emoji {` +
                        `vertical-align: bottom;` +
                    `}` +
                    `span.isEdited {` +
                        `color: ${Theme.palette.baseColor1};` +
                        `margin-left: 5px` +
                    `}` +
                `</style>` +
                `${msg}`
    }

    function convertToSingleLine(text) {
        return text.replace(/<br\s*\/>/gm, " ")
    }

    function stripHtmlTags(text) {
        return text.replace(/<[^>]*>?/gm, '')
    }

    function delegateModelSort(srcGroup, dstGroup, lessThan) {
        const insertPosition = (lessThan, item) => {
            let lower = 0
            let upper = dstGroup.count
            while (lower < upper) {
                const middle = Math.floor(lower + (upper - lower) / 2)
                const result = lessThan(item.model, dstGroup.get(middle).model);
                if (result)
                    upper = middle
                else
                    lower = middle + 1
            }
            return lower
        }

        while (srcGroup.count > 0) {
            const item = srcGroup.get(0)
            const index = insertPosition(lessThan, item)
            item.groups = dstGroup.name
            dstGroup.move(item.itemsIndex, index)
        }
    }

    function elideText(text, leftCharsCount, rightCharsCount = leftCharsCount) {
        return text.substr(0, leftCharsCount) + "..." + text.substr(text.length - rightCharsCount)
    }

    function ensureVisible(flickable, rect) {
        const rectRight = rect.x + rect.width
        const rectBottom = rect.y + rect.height
        const flickableRight = flickable.contentX + flickable.width
        const flickableBottom = flickable.contentY + flickable.height

        if (flickable.contentX >= rect.x)
            flickable.contentX = rect.x
        else if (flickableRight <= rectRight)
            flickable.contentX = rectRight - flickable.width

        if (flickable.contentY >= rect.y)
            flickable.contentY = rect.y
        else if (flickableBottom <= rectBottom)
            flickable.contentY = rectBottom - flickable.height
    }

    function encodeUtf8(str){
        return unescape(encodeURIComponent(str));
    }

    function deviceIcon(deviceType) {
        const isMobileDevice = deviceType === "ios" || deviceType === "android"
        return isMobileDevice ? "mobile" : "desktop"
    }

    function getYinYangColor(color) {
        if (color.toString().toUpperCase() === Theme.palette.customisationColors.yinYang.toString().toUpperCase()) {
            return Theme.palette.name === "light" ? "#FFFFFF" : "#09101C"
        }
        return ""
    }
}


