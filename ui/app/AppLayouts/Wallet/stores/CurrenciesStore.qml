import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property string currentCurrency: walletSection.currentCurrency
    property ListModel currenciesModel: ListModel {
       ListElement {
           key: "usd"
           shortName: "USD"
           //% "US Dollars"
           name: qsTrId("us-dollars")
           symbol: "$"
           category: ""
           imageSource: "../../assets/twemoji/26x26/1f1fa-1f1f8.png"
           selected: false
       }

       ListElement {
           key: "gbp"
           shortName: "GBP"
           //% "British Pound"
           name: qsTrId("british-pound")
           symbol: "£"
           category: ""
           imageSource: "../../assets/twemoji/26x26/1f1ec-1f1e7.png"
           selected: false
       }

       ListElement {
           key: "eur"
           shortName: "EUR"
           //% "Euros"
           name: qsTrId("euros")
           symbol: "€"
           category: ""
           imageSource: "../../assets/twemoji/26x26/1f1ea-1f1fa.png"
           selected: false
       }

       ListElement {
           key: "rub"
           shortName: "RUB"
           //% "Russian ruble"
           name: qsTrId("russian-ruble")
           symbol: "₽"
           category: ""
           imageSource: "../../assets/twemoji/26x26/1f1f7-1f1fa.png"
           selected: false
       }

       ListElement {
           key: "krw"
           shortName: "KRW"
           //% "South Korean won"
           name: qsTrId("south-korean-won")
           symbol: "₩"
           category: ""
           imageSource: "../../assets/twemoji/26x26/1f1f0-1f1f7.png"
           selected: false
       }

       ListElement {
           key: "eth"
           shortName: "ETH"
           name: qsTr("Ethereum")
           symbol: "Ξ"
           category: "Tokens"
           imageSource: "../../../../imports/assets/png/tokens/ETH.png"
           selected: false
       }

       ListElement {
           key: "btc"
           shortName: "BTC"
           name: qsTr("Bitcoin")
           symbol: "฿"
           category: "Tokens"
           imageSource: "../../../../imports/assets/png/tokens/WBTC.png"
           selected: false
       }

       ListElement {
           key: "stn"
           shortName: "SNT"
           name: qsTr("Status Network Token")
           symbol: ""
           category: "Tokens"
           imageSource: "../../../../imports/assets/png/tokens/SNT.png"
           selected: false
       }

       ListElement {
           key: "dai"
           shortName: "DAI"
           name: qsTr("Dai")
           symbol: "◈"
           category: "Tokens"
           imageSource: "../../../../imports/assets/png/tokens/DAI.png"
           selected: false
       }

       ListElement {
           key: "aed"
           shortName: "AED"
           //% "United Arab Emirates dirham"
           name: qsTrId("united-arab-emirates-dirham")
           symbol: "د.إ"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e6-1f1ea.png"
           selected: false
       }

       ListElement {
           key: "afn"
           shortName: "AFN"
           //% "Afghan afghani"
           name: qsTrId("afghan-afghani")
           symbol: "؋"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e6-1f1eb.png"
           selected: false
       }

       ListElement {
           key: "ars"
           shortName: "ARS"
           //% "Argentine peso"
           name: qsTrId("argentine-peso")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e6-1f1f7.png"
           selected: false
       }

       ListElement {
           key: "aud"
           shortName: "AUD"
           //% "Australian dollar"
           name: qsTrId("australian-dollar")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e6-1f1fa.png"
           selected: false
       }

       ListElement {
           key: "bbd"
           shortName: "BBD"
           //% "Barbadian dollar"
           name: qsTrId("barbadian-dollar")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e7-1f1e7.png"
           selected: false
       }

       ListElement {
           key: "bdt"
           shortName: "BDT"
           //% "Bangladeshi taka"
           name: qsTrId("bangladeshi-taka")
           symbol: " Tk"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e7-1f1e9.png"
           selected: false
       }

       ListElement {
           key: "bgn"
           shortName: "BGN"
           //% "Bulgarian lev"
           name: qsTrId("bulgarian-lev")
           symbol: "лв"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e7-1f1ec.png"
           selected: false
       }

       ListElement {
           key: "bhd"
           shortName: "BHD"
           //% "Bahraini dinar"
           name: qsTrId("bahraini-dinar")
           symbol: "BD"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e7-1f1ed.png"
           selected: false
       }

       ListElement {
           key: "bnd"
           shortName: "BND"
           //% "Brunei dollar"
           name: qsTrId("brunei-dollar")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e7-1f1f3.png"
           selected: false
       }

       ListElement {
           key: "bob"
           shortName: "BOB"
           //% "Bolivian boliviano"
           name: qsTrId("bolivian-boliviano")
           symbol: "$b"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e7-1f1f4.png"
           selected: false
       }

       ListElement {
           key: "brl"
           shortName: "BRL"
           //% "Brazillian real"
           name: qsTrId("brazillian-real")
           symbol: "R$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e7-1f1f7.png"
           selected: false
       }

       ListElement {
           key: "btn"
           shortName: "BTN"
           //% "Bhutanese ngultrum"
           name: qsTrId("bhutanese-ngultrum")
           symbol: "Nu."
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e7-1f1f9.png"
           selected: false
       }

       ListElement {
           key: "cad"
           shortName: "CAD"
           //% "Canadian dollar"
           name: qsTrId("canadian-dollar")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e8-1f1e6.png"
           selected: false
       }

       ListElement {
           key: "chf"
           shortName: "CHF"
           //% "Swiss franc"
           name: qsTrId("swiss-franc")
           symbol: "CHF"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e8-1f1ed.png"
           selected: false
       }

       ListElement {
           key: "clp"
           shortName: "CLP"
           //% "Chilean peso"
           name: qsTrId("chilean-peso")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e8-1f1f1.png"
           selected: false
       }

       ListElement {
           key: "cny"
           shortName: "CNY"
           //% "Chinese yuan"
           name: qsTrId("chinese-yuan")
           symbol: "¥"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e8-1f1f3.png"
           selected: false
       }

       ListElement {
           key: "cop"
           shortName: "COP"
           //% "Colombian peso"
           name: qsTrId("colombian-peso")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e8-1f1f4.png"
           selected: false
       }

       ListElement {
           key: "crc"
           shortName: "CRC"
           //% "Costa Rican colón"
           name: qsTrId("costa-rican-colón")
           symbol: "₡"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e8-1f1f7.png"
           selected: false
       }

       ListElement {
           key: "czk"
           shortName: "CZK"
           //% "Czech koruna"
           name: qsTrId("czech-koruna")
           symbol: "Kč"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e8-1f1ff.png"
           selected: false
       }

       ListElement {
           key: "dkk"
           shortName: "DKK"
           //% "Danish krone"
           name: qsTrId("danish-krone")
           symbol: "kr"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e9-1f1f0.png"
           selected: false
       }

       ListElement {
           key: "dop"
           shortName: "DOP"
           //% "Dominican peso"
           name: qsTrId("dominican-peso")
           symbol: "RD$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1e9-1f1f4.png"
           selected: false
       }

       ListElement {
           key: "egp"
           shortName: "EGP"
           //% "Egyptian pound"
           name: qsTrId("egyptian-pound")
           symbol: "£"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ea-1f1ec.png"
           selected: false
       }

       ListElement {
           key: "etb"
           shortName: "ETB"
           //% "Ethiopian birr"
           name: qsTrId("ethiopian-birr")
           symbol: "Br"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ea-1f1f9.png"
           selected: false
       }

       ListElement {
           key: "gel"
           shortName: "GEL"
           //% "Georgian lari"
           name: qsTrId("georgian-lari")
           symbol: "₾"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ec-1f1ea.png"
           selected: false
       }

       ListElement {
           key: "ghs"
           shortName: "GHS"
           //% "Ghanaian cedi"
           name: qsTrId("ghanaian-cedi")
           symbol: "¢"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ec-1f1ed.png"
           selected: false
       }

       ListElement {
           key: "hkd"
           shortName: "HKD"
           //% "Hong Kong dollar"
           name: qsTrId("hong-kong-dollar")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ed-1f1f0.png"
           selected: false
       }

       ListElement {
           key: "hrk"
           shortName: "HRK"
           //% "Croatian kuna"
           name: qsTrId("croatian-kuna")
           symbol: "kn"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ed-1f1f7.png"
           selected: false
       }

       ListElement {
           key: "huf"
           shortName: "HUF"
           //% "Hungarian forint"
           name: qsTrId("hungarian-forint")
           symbol: "Ft"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ed-1f1fa.png"
           selected: false
       }

       ListElement {
           key: "idr"
           shortName: "IDR"
           //% "Indonesian rupiah"
           name: qsTrId("indonesian-rupiah")
           symbol: "Rp"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ee-1f1e9.png"
           selected: false
       }

       ListElement {
           key: "ils"
           shortName: "ILS"
           //% "Israeli new shekel"
           name: qsTrId("israeli-new-shekel")
           symbol: "₪"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ee-1f1f1.png"
           selected: false
       }

       ListElement {
           key: "inr"
           shortName: "INR"
           //% "Indian rupee"
           name: qsTrId("indian-rupee")
           symbol: "₹"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ee-1f1f3.png"
           selected: false
       }

       ListElement {
           key: "isk"
           shortName: "ISK"
           //% "Icelandic króna"
           name: qsTrId("icelandic-króna")
           symbol: "kr"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ee-1f1f8.png"
           selected: false
       }

       ListElement {
           key: "jmd"
           shortName: "JMD"
           //% "Jamaican dollar"
           name: qsTrId("jamaican-dollar")
           symbol: "J$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ef-1f1f2.png"
           selected: false
       }

       ListElement {
           key: "jpy"
           shortName: "JPY"
           //% "Japanese yen"
           name: qsTrId("japanese-yen")
           symbol: "¥"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ef-1f1f5.png"
           selected: false
       }

       ListElement {
           key: "kes"
           shortName: "KES"
           //% "Kenyan shilling"
           name: qsTrId("kenyan-shilling")
           symbol: "KSh"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f0-1f1ea.png"
           selected: false
       }

       ListElement {
           key: "kwd"
           shortName: "KWD"
           //% "Kuwaiti dinar"
           name: qsTrId("kuwaiti-dinar")
           symbol: "د.ك"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f0-1f1fc.png"
           selected: false
       }

       ListElement {
           key: "kzt"
           shortName: "KZT"
           //% "Kazakhstani tenge"
           name: qsTrId("kazakhstani-tenge")
           symbol: "лв"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f0-1f1ff.png"
           selected: false
       }

       ListElement {
           key: "lkr"
           shortName: "LKR"
           //% "Sri Lankan rupee"
           name: qsTrId("sri-lankan-rupee")
           symbol: "₨"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f1-1f1f0.png"
           selected: false
       }

       ListElement {
           key: "mad"
           shortName: "MAD"
           //% "Moroccan dirham"
           name: qsTrId("moroccan-dirham")
           symbol: "MAD"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f2-1f1e6.png"
           selected: false
       }

       ListElement {
           key: "mdl"
           shortName: "MDL"
           //% "Moldovan leu"
           name: qsTrId("moldovan-leu")
           symbol: "MDL"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f2-1f1e9.png"
           selected: false
       }

       ListElement {
           key: "mur"
           shortName: "MUR"
           //% "Mauritian rupee"
           name: qsTrId("mauritian-rupee ")
           symbol: "₨"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f2-1f1f7.png"
           selected: false
       }

       ListElement {
           key: "mwk"
           shortName: "MWK"
           //% "Malawian kwacha"
           name: qsTrId("malawian-kwacha")
           symbol: "MK"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f2-1f1fc.png"
           selected: false
       }

       ListElement {
           key: "mxn"
           shortName: "MXN"
           //% "Mexican peso"
           name: qsTrId("mexican-peso")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f2-1f1fd.png"
           selected: false
       }

       ListElement {
           key: "myr"
           shortName: "MYR"
           //% "Malaysian ringgit"
           name: qsTrId("malaysian-ringgit")
           symbol: "RM"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f2-1f1fe.png"
           selected: false
       }

       ListElement {
           key: "mzn"
           shortName: "MZN"
           //% "Mozambican metical"
           name: qsTrId("mozambican-metical")
           symbol: "MT"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f2-1f1ff.png"
           selected: false
       }

       ListElement {
           key: "nad"
           shortName: "NAD"
           //% "Namibian dollar"
           name: qsTrId("namibian-dollar")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f3-1f1e6.png"
           selected: false
       }

       ListElement {
           key: "ngn"
           shortName: "NGN"
           //% "Nigerian naira"
           name: qsTrId("nigerian-naira")
           symbol: "₦"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f3-1f1ec.png"
           selected: false
       }

       ListElement {
           key: "nok"
           shortName: "NOK"
           //% "Norwegian krone"
           name: qsTrId("norwegian-krone")
           symbol: "kr"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f3-1f1f4.png"
           selected: false
       }

       ListElement {
           key: "npr"
           shortName: "NPR"
           //% "Nepalese rupee"
           name: qsTrId("nepalese-rupee")
           symbol: "₨"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f3-1f1f5.png"
           selected: false
       }

       ListElement {
           key: "nzd"
           shortName: "NZD"
           //% "New Zealand dollar"
           name: qsTrId("new-zealand-dollar")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f3-1f1ff.png"
           selected: false
       }

       ListElement {
           key: "omr"
           shortName: "OMR"
           //% "Omani rial"
           name: qsTrId("omani-rial")
           symbol: "﷼"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f4-1f1f2.png"
           selected: false
       }

       ListElement {
           key: "pen"
           shortName: "PEN"
           //% "Peruvian sol"
           name: qsTrId("peruvian-sol")
           symbol: "S/."
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f5-1f1ea.png"
           selected: false
       }

       ListElement {
           key: "pgk"
           shortName: "PGK"
           //% "Papua New Guinean kina"
           name: qsTrId("papua-new-guinean-kina")
           symbol: "K"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f5-1f1ec.png"
           selected: false
       }

       ListElement {
           key: "php"
           shortName: "PHP"
           //% "Philippine peso"
           name: qsTrId("philippine-peso")
           symbol: "₱"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f5-1f1ed.png"
           selected: false
       }

       ListElement {
           key: "pkr"
           shortName: "PKR"
           //% "Pakistani rupee"
           name: qsTrId("pakistani-rupee")
           symbol: "₨"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f5-1f1f0.png"
           selected: false
       }

       ListElement {
           key: "pln"
           shortName: "PLN"
           //% "Polish złoty"
           name: qsTrId("polish-złoty")
           symbol: "zł"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f5-1f1f1.png"
           selected: false
       }

       ListElement {
           key: "pyg"
           shortName: "PYG"
           //% "Paraguayan guaraní"
           name: qsTrId("paraguayan-guaraní")
           symbol: "Gs"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f5-1f1fe.png"
           selected: false
       }

       ListElement {
           key: "qar"
           shortName: "QAR"
           //% "Qatari riyal"
           name: qsTrId("qatari-riyal")
           symbol: "﷼"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f6-1f1e6.png"
           selected: false
       }

       ListElement {
           key: "ron"
           shortName: "RON"
           //% "Romanian leu"
           name: qsTrId("romanian-leu")
           symbol: "lei"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f7-1f1f4.png"
           selected: false
       }

       ListElement {
           key: "rsd"
           shortName: "RSD"
           //% "Serbian dinar"
           name: qsTrId("serbian-dinar")
           symbol: "Дин."
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f7-1f1f8.png"
           selected: false
       }

       ListElement {
           key: "sar"
           shortName: "SAR"
           //% "Saudi riyal"
           name: qsTrId("saudi-riyal")
           symbol: "﷼"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f8-1f1e6.png"
           selected: false
       }

       ListElement {
           key: "sek"
           shortName: "SEK"
           //% "Swedish krona"
           name: qsTrId("swedish-krona")
           symbol: "kr"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f8-1f1ea.png"
           selected: false
       }

       ListElement {
           key: "sgd"
           shortName: "SGD"
           //% "Singapore dollar"
           name: qsTrId("singapore-dollar")
           symbol: "$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f8-1f1ec.png"
           selected: false
       }

       ListElement {
           key: "thb"
           shortName: "THB"
           //% "Thai baht"
           name: qsTrId("thai-baht")
           symbol: "฿"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f9-1f1ed.png"
           selected: false
       }

       ListElement {
           key: "ttd"
           shortName: "TTD"
           //% "Trinidad and Tobago dollar"
           name: qsTrId("trinidad-and-tobago-dollar")
           symbol: "TT$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f9-1f1f9.png"
           selected: false
       }

       ListElement {
           key: "twd"
           shortName: "TWD"
           //% "New Taiwan dollar"
           name: qsTrId("new-taiwan-dollar")
           symbol: "NT$"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f9-1f1fc.png"
           selected: false
       }

       ListElement {
           key: "tzs"
           shortName: "TZS"
           //% "Tanzanian shilling"
           name: qsTrId("tanzanian-shilling")
           symbol: "TSh"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f9-1f1ff.png"
           selected: false
       }

       ListElement {
           key: "try"
           shortName: "TRY"
           //% "Turkish lira"
           name: qsTrId("turkish-lira")
           symbol: "₺"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1f9-1f1f7.png"
           selected: false
       }

       ListElement {
           key: "uah"
           shortName: "UAH"
           //% "Ukrainian hryvnia"
           name: qsTrId("ukrainian-hryvnia")
           symbol: "₴"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1fa-1f1e6.png"
           selected: false
       }

       ListElement {
           key: "ugx"
           shortName: "UGX"
           //% "Ugandan shilling"
           name: qsTrId("ugandan-shilling")
           symbol: "USh"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1fa-1f1ec.png"
           selected: false
       }

       ListElement {
           key: "uyu"
           shortName: "UYU"
           //% "Uruguayan peso"
           name: qsTrId("uruguayan-peso")
           symbol: "$U"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1fa-1f1fe.png"
           selected: false
       }

       ListElement {
           key: "vef"
           shortName: "VEF"
           //% "Venezuelan bolívar"
           name: qsTrId("venezuelan-bolívar")
           symbol: "Bs"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1fb-1f1ea.png"
           selected: false
       }

       ListElement {
           key: "vnd"
           shortName: "VND"
           //% "Vietnamese đồng"
           name: qsTrId("vietnamese-đồng")
           symbol: "₫"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1fb-1f1f3.png"
           selected: false
       }

       ListElement {
           key: "zar"
           shortName: "ZAR"
           //% "South African rand"
           name: qsTrId("south-african-rand")
           symbol: "R"
           category: "Other Fiat"
           imageSource: "../../assets/twemoji/26x26/1f1ff-1f1e6.png"
           selected: false
       }
    }

    onCurrentCurrencyChanged: { updateCurrenciesModel() }

    function updateCurrenciesModel() {
        var isSelected = false
        for(var i = 0; i < currenciesModel.count; i++) {
            if(root.currentCurrency === root.currenciesModel.get(i).key) {
                root.currenciesModel.get(i).selected = isSelected = true
            }
            else {
                root.currenciesModel.get(i).selected = false
            }
        }

        // Set default:
        if(!isSelected)
            root.currenciesModel.get(0).selected = true
    }

    function updateCurrency(newCurrency) {
        walletSection.updateCurrency(newCurrency)
    }
}
