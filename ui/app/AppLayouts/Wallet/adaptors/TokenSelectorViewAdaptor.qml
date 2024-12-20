import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

import utils 1.0

QObject {
    id: root

    /**
      Transforms and prepares input data (assets) for TokenSelectorView needs. The assets model is internally
      joined with `flatNetworksModel` for the `balances` submodel

      Expected assets model structure:
      - tokensKey: string -> unique string ID of the token (asset); e.g. "ETH" or contract address
      - name: string -> user visible token name (e.g. "Ethereum")
      - symbol: string -> user visible token symbol (e.g. "ETH")
      - decimals: int -> number of decimal places
      - communityId: string -> optional; ID of the community this token belongs to, if any
      - marketDetails: var -> object containing props like `currencyPrice` for the computed values below
      - balances: submodel -> [ chainId:int, account:string, balance:BigIntString, iconUrl:string ]

      Computed values:
      - currentBalance: double (amount of tokens)
      - currencyBalance: double (e.g. `1000.42` in user's fiat currency)
      - currencyBalanceAsString: string (e.g. "1 000,42 CZK" formatted as a string according to the user's locale)
      - balanceAsString: string (`1.42` formatted as e.g. "1,42" in user's locale)
      - iconSource: string
    */

    // input API
    required property var assetsModel

    // expected roles: key, name, symbol, image, communityId
    property var plainTokensBySymbolModel // optional all tokens model, no balances

    // expected roles: chainId, chainName, iconUrl
    required property var flatNetworksModel

    // CurrenciesStore.currentCurrency, e.g. "USD"
    required property string currentCurrency

    // optional filter properties; empty/default values means no filtering
    property bool showAllTokens // whether to show all tokens, or just the ones we own
    property var enabledChainIds: []
    property string accountAddress
    property bool showCommunityAssets

    // output model
    readonly property SortFilterProxyModel outputAssetsModel: SortFilterProxyModel {

        objectName: "TokenSelectorViewAdaptor_outputAssetsModel"

        sourceModel: allTokensLoader.item && allTokensLoader.item.ModelCount.count > 0 ?
                                    allTokensLoader.item :
                                    (tokensWithBalance.ModelCount.count ? tokensWithBalance : null)

        proxyRoles: [
            FastExpressionRole {
                name: "sectionName"
                function getSectionName(hasBalance) {
                    if (!hasBalance)
                        return qsTr("Popular assets")

                    if (firstEnabledChain.available)
                        return qsTr("Your assets on %1").arg(firstEnabledChain.item.chainName)
                }
                expression: getSectionName(!!model.currentBalance)
                expectedRoles: ["currentBalance"]
            },
            FastExpressionRole {
                function tokenIcon(symbol) {
                    return Constants.tokenIcon(symbol)
                }
                name: "iconSource"
                expression: model.image || tokenIcon(model.symbol)
                expectedRoles: ["image", "symbol"]
            }
        ]

        sorters: [
            RoleSorter {
                roleName: "currencyBalance"
                ascendingOrder: false
            },
            RoleSorter {
                roleName: "name"
            }
            // FIXME #15277 sort by assetsController instead, to have the sorting/order as in the main wallet view
        ]
        filters: [
            ValueFilter {
                roleName: "communityId"
                value: ""
                enabled: !root.showCommunityAssets
            }
        ]
    }

    Loader {
        id: allTokensLoader
        active: showAllTokens && !!plainTokensBySymbolModel
        sourceComponent: allTokensComponent
    }

    SortFilterProxyModel {
        id: tokensWithBalance
        filters: [
            ValueFilter {
                roleName: "currencyBalance"
                value: 0
                inverted: true
            }
        ]
        sorters: [
            FastExpressionSorter {
                expression: {
                    const lhs = modelLeft.currencyBalance
                    const rhs = modelRight.currencyBalance
                    if (lhs < rhs)
                        return 1
                    else if (lhs > rhs)
                        return -1
                    return 0
                }
                expectedRoles: ["currencyBalance"]
            }
        ]
        sourceModel: ObjectProxyModel {
            sourceModel: root.assetsModel

            objectName: "TokenSelectorViewAdaptor_assetsObjectProxyModel"

            delegate: SortFilterProxyModel {
                id: delegateRoot

                // properties exposed as roles to the top-level model
                readonly property string tokensKey: model.tokensKey
                readonly property int decimals: model.decimals
                readonly property double currentBalance: aggregator.value
                readonly property double currencyBalance: {
                    if (!!model.marketDetails) {
                        return currentBalance * model.marketDetails.currencyPrice.amount
                    }
                    return 0
                }
                readonly property int displayDecimals: !!model.marketDetails ? model.marketDetails.currencyPrice.displayDecimals : 0
                readonly property string currencyBalanceAsString:
                    currencyBalance ? LocaleUtils.currencyAmountToLocaleString({amount: currencyBalance, symbol: root.currentCurrency, displayDecimals})
                                    : ""

                readonly property var balances: this

                sourceModel: joinModel

                proxyRoles: [
                    FastExpressionRole {
                        name: "balanceAsDouble"
                        function balanceToDouble(balance: string, decimals: int) {
                            if (typeof balance !== 'string')
                                return 0
                            let bigIntBalance = AmountsArithmetic.fromString(balance)
                            return AmountsArithmetic.toNumber(bigIntBalance, decimals)
                        }
                        expression: balanceToDouble(model.balance, delegateRoot.decimals)
                        expectedRoles: ["balance"]
                    },
                    FastExpressionRole {
                        name: "balanceAsString"
                        function convert(amount: double) {
                            return LocaleUtils.currencyAmountToLocaleString({amount, displayDecimals: 2}, {noSymbol: true})
                        }

                        expression: convert(model.balanceAsDouble)
                        expectedRoles: ["balanceAsDouble"]
                    }
                ]

                filters: [
                    ValueFilter {
                        roleName: "balance"
                        value: "0"
                        inverted: true
                    },
                    RegExpFilter {
                        roleName: "account"
                        pattern: root.accountAddress
                        caseSensitivity: Qt.CaseInsensitive
                        enabled: root.accountAddress !== ""
                    },
                    FastExpressionFilter {
                        expression: root.enabledChainIds.includes(model.chainId)
                        expectedRoles: ["chainId"]
                        enabled: root.enabledChainIds.length
                    }
                ]

                sorters: [
                    // sort by biggest (sub)balance first
                    RoleSorter {
                        roleName: "balanceAsDouble"
                        sortOrder: Qt.DescendingOrder
                    }
                ]

                readonly property LeftJoinModel joinModel: LeftJoinModel {
                    leftModel: model.balances
                    rightModel: root.flatNetworksModel
                    joinRole: "chainId"
                }

                readonly property SumAggregator aggregator: SumAggregator {
                    model: delegateRoot
                    roleName: "balanceAsDouble"
                }
            }

            exposedRoles: ["tokensKey", "balances", "currentBalance", "currencyBalance", "currencyBalanceAsString", "balanceAsString"]
            expectedRoles: [ "tokensKey", "communityId", "balances", "decimals", "marketDetails"]
        }
    }

    ModelEntry {
        id: firstEnabledChain
        sourceModel: root.flatNetworksModel
        key: "chainId"
        value: root.enabledChainIds.length ? root.enabledChainIds[0] : null
    }

    // internals
    QtObject {
        id: d

        readonly property string favoritesSectionId: "section_zzz"
    }

    Component {
        id: allTokensComponent
        LeftJoinModel {
            id: allTokens
            rightModel: tokensWithBalance
            leftModel: RolesRenamingModel {
                id: renamedTokensBySymbolModel
                sourceModel: SortFilterProxyModel {
                    sourceModel: root.plainTokensBySymbolModel
                    filters: [
                        // remove tokens not available on selected network(s)
                        FastExpressionFilter {
                            function isPresentOnEnabledNetworks(addressPerChain) {
                                if(!addressPerChain)
                                    return true
                                if (root.enabledChainIds.length === 0)
                                    return true
                                return !!ModelUtils.getFirstModelEntryIf(
                                            addressPerChain,
                                            (addPerChain) => {
                                                return root.enabledChainIds.includes(addPerChain.chainId)
                                            })
                            }
                            expression: {
                                root.enabledChainIds
                                return isPresentOnEnabledNetworks(model.addressPerChain)
                            }
                            expectedRoles: ["addressPerChain"]
                        }
                    ]
                }
                mapping: [
                    RoleRename {
                        from: "key"
                        to: "tokensKey"
                    }
                ]
            }
            joinRole: "tokensKey"
            rolesToJoin: ["tokensKey", "currentBalance", "currencyBalance", "currencyBalanceAsString", "balanceAsString", "balances"]
        }
    }
}
