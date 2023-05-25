import QtQuick 2.15

import StatusQ.Core 0.1

import utils 1.0

ShowcaseDelegate {
    title: !!showcaseObj && !!showcaseObj.name ? showcaseObj.name : ""
    secondaryTitle: !!showcaseObj ? LocaleUtils.currencyAmountToLocaleString(showcaseObj.enabledNetworkBalance) : Qt.locale().zeroDigit
    hasImage: true
    icon.source: !!showcaseObj ? Constants.tokenIcon(showcaseObj.symbol) : ""
}
