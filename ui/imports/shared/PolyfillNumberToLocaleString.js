.pragma library
// polyfill.number.toLocaleDateString
// Copied from: https://github.com/willsp/polyfill-Number.toLocaleString-with-Locales
// Got this from MDN: 
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toLocaleString#Example:_Checking_for_support_for_locales_and_options_arguments 
function toLocaleStringSupportsLocales() { 
    var number = 0; 
    try { 
        number.toLocaleString("i"); 
    } catch (e) { 
        return e.name === "RangeError"; 
    } 
    return false; 
} 

var replaceSeparators = function(sNum, separators) { 
    var sNumParts = sNum.split('.'); 
    if (separators && separators.thousands) { 
        sNumParts[0] = sNumParts[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1" + separators.thousands); 
    } 
    sNum = sNumParts.join(separators.decimal); 

    return sNum; 
}; 

var mapMatch = function(map, locale) { 
    var match = locale; 
    var language = locale && locale.toLowerCase().match(/^\w+/); 

    if (!map.hasOwnProperty(locale)) { 
        if (map.hasOwnProperty(language)) { 
            match = language; 
        } else { 
            match = "en"; 
        } 
    } 

    return map[match]; 
}; 

var dotThousCommaDec = function(sNum) { 
    var separators = { 
        decimal: ',', 
        thousands: '.' 
    }; 

    return replaceSeparators(sNum, separators); 
}; 

var commaThousDotDec = function(sNum) { 
    var separators = { 
        decimal: '.', 
        thousands: ',' 
    }; 

    return replaceSeparators(sNum, separators); 
}; 

var spaceThousCommaDec = function(sNum) { 
    var seperators = { 
        decimal: ',', 
        thousands: '\u00A0' 
    }; 

    return replaceSeparators(sNum, seperators); 
}; 

var apostrophThousDotDec = function(sNum) { 
    var seperators = { 
        decimal: '.', 
        thousands: '\u0027' 
    }; 

    return replaceSeparators(sNum, seperators); 
}; 

var transformForLocale = { 
    en: commaThousDotDec, 
    'en-GB': commaThousDotDec, 
    'en-US': commaThousDotDec, 
    it: dotThousCommaDec, 
    fr: spaceThousCommaDec, 
    de: dotThousCommaDec, 
    "de-DE": dotThousCommaDec, 
    "de-AT": dotThousCommaDec, 
    "de-CH": apostrophThousDotDec, 
    "de-LI": apostrophThousDotDec, 
    "de-BE": dotThousCommaDec, 
    "nl": dotThousCommaDec, 
    "nl-BE": dotThousCommaDec, 
    "nl-NL": dotThousCommaDec, 
    ro: dotThousCommaDec, 
    "ro-RO": dotThousCommaDec, 
    ru: spaceThousCommaDec, 
    "ru-RU": spaceThousCommaDec, 
    hu: spaceThousCommaDec, 
    "hu-HU": spaceThousCommaDec, 
    "da-DK": dotThousCommaDec, 
    "nb-NO": spaceThousCommaDec 
}; 

var currencyFormatMap = { 
    en: "pre", 
    'en-GB': "pre", 
    'en-US': "pre", 
    it: "post", 
    fr: "post", 
    de: "post", 
    "de-DE": "post", 
    "de-AT": "prespace", 
    "de-CH": "prespace", 
    "de-LI": "post", 
    "de-BE": "post", 
    "nl": "post", 
    "nl-BE": "post", 
    "nl-NL": "post", 
    ro: "post", 
    "ro-RO": "post", 
    ru: "post", 
    "ru-RU": "post", 
    hu: "post", 
    "hu-HU": "post", 
    "da-DK": "post", 
    "nb-NO": "post" 
}; 

function toLocaleString(val, locale, options) { 
    if (locale && locale.length < 2) 
        throw new RangeError("Invalid language tag: " + locale); 

    var sNum; 

    if (options && (options.minimumFractionDigits || options.minimumFractionDigits === 0)) { 
        sNum = Number(val).toFixed(options.minimumFractionDigits); 
    } else { 
        sNum = Number(val).toString(); 
    } 

    sNum = mapMatch(transformForLocale, locale)(sNum, options); 

    if(options && options.currency) {
        sNum = convertToInternationalCurrencySystem(val)
    }

    return sNum; 
}; 

function convertToInternationalCurrencySystem (val) {
    // Nine 0's - Billions
    return Math.abs(Number(val)) >= 1.0e+9
    ? (Math.abs(Number(val)) / 1.0e+9).toFixed(2) + "B"
    // Six 0's - Millions
    : Math.abs(Number(val)) >= 1.0e+6
    ? (Math.abs(Number(val)) / 1.0e+6).toFixed(2) + "M"
    : Math.abs(Number(val));
}

