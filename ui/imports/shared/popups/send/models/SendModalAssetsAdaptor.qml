import QtQml 2.15

import StatusQ 0.1
import StatusQ.Models 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import SortFilterProxyModel 0.2

QObject {
    id: root

    // Controller providing information about visibility and order defined
    // by a user (token management)
    required property /*ManageTokensController*/ var controller

    property bool showCommunityAssets: false

    property string assetSearchString: ""

    /**
      Expected model structure:

        Tokens related part:

        tokensKey           [string] - unique identifier of a token, e.g "0x3234235"
        symbol              [string] - token's symbol e.g. "ETH" or "SNT"
        name                [string] - token's name e.g. "Ether" or "Dai"
        image               [url]    - token's icon for custom tokens
        decimals            [int]    - number of decimal places, e.g. 18 for ETH
        balances            [model]  - submodel of balances per chain/account
            chainId         [string] - unique identifier of a chain
            account         [string] - unique identifier of an account
            balance         [string] - balance in basic unit as big integer string
        marketDetails       [object] - object holding market details
            changePct24hour [double] - percentage change of fiat price in last day
            currencyPrice   [object] - object holding fiat price details
                amount      [double] - fiat prace of 1 logical unit of cryptocurrency
        detailsLoading      [bool]   - indicatator if market details are ready to use
        addressPerChain     [model]  - submodel of addresses per chain
            chainId         [string] - unique identifier of a chain
            address         [string] - address of a token contract

        Community related part (relevant for community minted assets, empty otherwise):

        communityId         [string] - unique identifier of a community, e.g. "0x6734235"
    **/
    property var tokensModel

    // function formatting tokens balance expressed in a commonly used units,
    // e.g. 1.2 for 1.2 ETH, according to rules specific for given symbol
    property var formatBalance:
        (balance, symbol) => `${balance.toLocaleString(Qt.locale())} ${symbol}`

    // account used for balance calculation
    property string account: ""

    // threshold below which the token is omitted from the output model
    property double marketValueThreshold

    /**
      Model structure:

        All roles from the source model are passed directly to the output model,
        additionally:

        key                     [string] - renamed from tokensKey
        icon                    [url]    - from image or fetched by symbol for well-known tokens
        currentbalance          [double] - tokens balance is the commonly used unit, e.g. 1.2 for 1.2 ETH,
                                           computed from balances according to provided criteria
        currentBalanceText      [string] - formatted and localized balance
        currentCurrencyBalance  [double] - tokens fiat balance computed from balance and market price

        marketDetailsAvailable [bool]   - specifies if market datails are available for given token
        marketDetailsLoading   [bool]   - specifies if market datails are available for given token
        marketPrice            [double] - specifies market price in currently used currency
        marketChangePct24hour  [double] - percentage price change in last 24 hours, e.g. 0.5 for 0.5% of price change
        balancesModel          [model]  - filtered balances model by selected account
    **/
    readonly property alias model: sfpm

    ObjectProxyModel {
        id: proxyModel

        objectName: "sendModalAssetsAdaptor_proxyModel"

        sourceModel: root.tokensModel ?? null

        delegate: QObject {
            readonly property var rootModel: model
            readonly property bool isCommunityAsset: !!model.communityId
            readonly property var marketDetails: model.marketDetails

            // Read-only roles exposed to the model:
            readonly property string key: model.tokensKey

            readonly property double currentBalance: AmountsArithmetic.toNumber(totalBalanceAggregator.value, model.decimals)
            readonly property double currentCurrencyBalance: currentBalance * marketPrice

            readonly property string currentBalanceText: root.formatBalance(currentBalance, model.symbol)

            readonly property bool marketDetailsAvailable: !isCommunityAsset
            readonly property bool marketDetailsLoading: model.detailsLoading
            readonly property real marketPrice: marketDetails.currencyPrice.amount ?? 0
            readonly property real marketChangePct24hour: marketDetails.changePct24hour ?? 0

            readonly property bool visible: {
                root.controller.revision

                if (!root.controller.filterAcceptsSymbol(model.symbol))
                    return false

                if (isCommunityAsset) {
                    return root.showCommunityAssets
                }
                return currentCurrencyBalance >= root.marketValueThreshold
            }

            readonly property url icon: !!model.image ? model.image : Constants.tokenIcon(model.symbol, false)

            readonly property var balancesModel: filteredBalances

            SortFilterProxyModel {
                id: filteredBalances

                sourceModel: rootModel.balances

                filters: [
                    FastExpressionFilter {
                        expression: root.account === model.account
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
        }

        expectedRoles:
            ["tokensKey", "symbol", "image", "balances", "decimals",
             "detailsLoading", "marketDetails", "communityId", "addressPerChain"]
        exposedRoles:
            ["key", "error", "currentBalance", "currentCurrencyBalance", "currentBalanceText",
             "icon", "visible", "marketDetailsAvailable", "marketDetailsLoading",
             "marketPrice", "marketChangePct24hour", "isCommunityAsset", "balancesModel"]


        /* Internal function to search token address */
        function __searchAddressInList(addressPerChain, searchString) {
            const uppercaseSearchString = searchString.toUpperCase()
            let addressFound = false
            let tokenAddresses = ModelUtils.modelToFlatArray(addressPerChain, "address")
            for (let i =0; i< tokenAddresses.length; i++){
                if(tokenAddresses[i].toUpperCase().startsWith(uppercaseSearchString)) {
                    addressFound = true
                    break;
                }
            }
            return addressFound
        }
    }

    SortFilterProxyModel {
        id: sfpm

        sourceModel: proxyModel
        objectName: "SendModalAssetsAdaptorModel"

        filters: [
            FastExpressionFilter {
                function search(symbol, name, addressPerChain, searchString) {
                    const uppercaseSearchString = searchString.toUpperCase()
                    return (
                        symbol.toUpperCase().startsWith(uppercaseSearchString) ||
                                name.toUpperCase().startsWith(uppercaseSearchString) || proxyModel.__searchAddressInList(addressPerChain, searchString)
                    )
                }
                expression: search(symbol, name, addressPerChain, root.assetSearchString)
                expectedRoles: ["symbol", "name", "addressPerChain"]
            },
            ValueFilter {
                roleName: "visible"
                value: true
            }
        ]
        sorters: RoleSorter {
            roleName: "isCommunityAsset"
        }
    }
}
