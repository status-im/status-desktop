import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core 0.1

import utils 1.0

ShowcaseDelegate {
    property var getCurrencyAmount: function(){}
    title: !!showcaseObj && !!showcaseObj.name ? showcaseObj.name : ""
    secondaryTitle: !!showcaseObj && !!showcaseObj.decimals && !!showcaseObj.symbol ?
                        LocaleUtils.currencyAmountToLocaleString(root.getCurrencyAmount(balancesAggregator.value/(10 ** showcaseObj.decimals), showcaseObj.symbol)) :
                        Qt.locale().zeroDigit
    hasImage: true
    icon.source: !!showcaseObj ? Constants.tokenIcon(showcaseObj.symbol) : ""

    SumAggregator {
        id: balancesAggregator
        model: !!showcaseObj && !!showcaseObj.balances ? showcaseObj.balances: null
        roleName: "balance"
    }
}
