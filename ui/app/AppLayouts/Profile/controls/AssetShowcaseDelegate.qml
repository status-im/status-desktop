import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core 0.1

import utils 1.0

ShowcaseDelegate {
    id: root

    property var formatCurrencyAmount: function(amount, symbol){}
    property double totalValue: !!showcaseObj && !!showcaseObj.decimals ? balancesAggregator.value/(10 ** showcaseObj.decimals): 0

    title: !!showcaseObj && !!showcaseObj.name ? showcaseObj.name : ""
    secondaryTitle: !!showcaseObj && !!showcaseObj.enabledNetworkBalance ?
                       LocaleUtils.currencyAmountToLocaleString(showcaseObj.enabledNetworkBalance) :
                       !!showcaseObj && !!showcaseObj.symbol ? formatCurrencyAmount(totalValue, showcaseObj.symbol): Qt.locale().zeroDigit
    hasImage: true
    icon.source: !!showcaseObj ? Constants.tokenIcon(showcaseObj.symbol) : ""

    SumAggregator {
        id: balancesAggregator
        model: !!showcaseObj && !!showcaseObj.balances ? showcaseObj.balances: null
        roleName: "balance"
    }
}
