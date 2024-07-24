import QtQml 2.15

import StatusQ 0.1
import StatusQ.Models 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import SortFilterProxyModel 0.2


QObject {
    id: root

    /**
      Expected model structure:

        Tokens related part:

        tokensKey           [string] - unique identifier of a token, e.g "0x3234235"
        symbol              [string] - token's symbol e.g. "ETH" or "SNT"
        name                [string] - token's name e.g. "Ether" or "Dai"
        image               [url]    - token's icon for custom tokens
        decimals            [int]    - number of decimal places, e.g. 18 for ETH
        balances            [model]  - submodel of balances per chain/account
            chainId         [int]    - unique identifier of a chain
            account         [string] - unique identifier of an account
            balance         [string] - balance in basic unit as big integer string
        marketDetails       [object] - object holding market details
            changePct24hour [double] - percentage change of fiat price in last day
            currencyPrice   [object] - object holding fiat price details
                amount      [double] - fiat prace of 1 logical unit of cryptocurrency
        detailsLoading      [bool]   - indicatator if market details are ready to use
        position            [int]    - custom order position
        visible             [bool]   - token management visiblity flag

        Community related part (relevant for community minted assets, empty otherwise):

        communityId         [string] - unique identifier of a community, e.g. "0x6734235"
        communityName       [string] - name of a community e.g. "Crypto Kitties"
        communityImage      [url]    - community's icon url
    **/
    property var tokensModel

    // function formatting tokens balance expressed in a commonly used units,
    // e.g. 1.2 for 1.2 ETH, according to rules specific for given symbol
    property var formatBalance:
        (balance, symbol) => `${balance.toLocaleString(Qt.locale())} ${symbol}`

    // function providing error message per token depending on used chains,
    // should return empty string if no error found
    property var chainsError: chains => ""

    // array[Number]list of chain identifiers used for balance calculation
    property var chains: []

    // list of accounts used for balance calculation
    property var accounts: []

    // threshold below which the token is omitted from the output model
    property double marketValueThreshold

    /**
      Model structure:

        All roles from the source model are passed directly to the output model,
        additionally:

        key         [string] - renamed from tokensKey
        icon        [url]    - from image or fetched by symbol for well-known tokens
        balance     [double] - tokens balance is the commonly used unit, e.g. 1.2 for 1.2 ETH,
                               computed from balances according to provided criteria
        balanceText [string] - formatted and localized balance
        error       [string] - error message related to balance

        marketDetailsAvailable [bool]   - specifies if market datails are available for given token
        marketDetailsLoading   [bool]   - specifies if market datails are available for given token
        marketPrice            [double] - specifies market price in currently used currency
        marketChangePct24hour  [double] - percentage price change in last 24 hours, e.g. 0.5 for 0.5% of price change

        canBeHidden [bool] - specifies if given token can be hidden (e.g. ETH should be always visible)

        communityIcon [url] - renamed from communityImage
    **/
    readonly property alias model: sfpm

    ObjectProxyModel {
        id: proxyModel

        objectName: "assetsViewAdaptorProxyModel"

        sourceModel: root.tokensModel ?? null

        delegate: QObject {
            readonly property var rootModel: model
            readonly property bool hasCommunityId: !!model.communityId
            readonly property var marketDetails: model.marketDetails

            // Read-only roles exposed to the model:

            readonly property string key: model.tokensKey

            readonly property string error:
                root.chainsError(chainsAggregator.uniqueChains)

            readonly property double balance:
                AmountsArithmetic.toNumber(totalBalanceAggregator.value, model.decimals)
            readonly property string balanceText: root.formatBalance(balance, model.symbol)

            readonly property bool marketDetailsAvailable: !hasCommunityId
            readonly property bool marketDetailsLoading: model.detailsLoading
            readonly property real marketPrice: marketDetails.currencyPrice.amount ?? 0
            readonly property real marketChangePct24hour: marketDetails.changePct24hour ?? 0

            readonly property bool visible: {
                if (!model.visible)
                    return false

                if (filteredBalances.ModelCount.count === 0)
                    return false

                if (hasCommunityId)
                    return true

                return balance * marketPrice >= root.marketValueThreshold
            }

            readonly property url icon:
                !!model.image ? model.image
                              : Constants.tokenIcon(model.symbol, false)

            readonly property url communityIcon: model.communityImage ?? ""

            readonly property bool canBeHidden: model.symbol !== Constants.ethToken

            SortFilterProxyModel {
                id: filteredBalances

                sourceModel: rootModel.balances

                filters: [
                    FastExpressionFilter {
                        expression: root.chains.includes(model.chainId)
                        expectedRoles: ["chainId"]
                    },
                    FastExpressionFilter {
                        expression: root.accounts.includes(model.account)
                        expectedRoles: ["account"]
                    }
                ]
            }

            FunctionAggregator {
                id: totalBalanceAggregator

                model: filteredBalances
                initialValue: "0"
                roleName: "balance"

                aggregateFunction: (aggr, value) => AmountsArithmetic.sum(
                                       AmountsArithmetic.fromString(aggr),
                                       AmountsArithmetic.fromString(value)).toString()
            }

            FunctionAggregator {
                id: chainsAggregator

                readonly property var uniqueChains: [...new Set(value).values()]

                model: filteredBalances
                initialValue: []
                roleName: "chainId"

                aggregateFunction: (aggr, value) => [...aggr, value]
            }
        }

        expectedRoles:
            ["tokensKey", "symbol", "image", "balances", "decimals",
             "detailsLoading", "marketDetails", "communityId", "communityImage",
             "visible"]
        exposedRoles:
            ["key", "error", "balance", "balanceText", "icon",
             "visible", "canBeHidden", "marketDetailsAvailable", "marketDetailsLoading",
             "marketPrice", "marketChangePct24hour", "communityIcon"]
    }

    SortFilterProxyModel {
        id: sfpm

        sourceModel: proxyModel

        filters: ValueFilter {
            roleName: "visible"
            value: true
        }
    }
}
