pragma Singleton

import QtQuick 2.13

QtObject {

    // Logical operators
    enum Operators {
        None,
        And,
        Or
    }

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
}


