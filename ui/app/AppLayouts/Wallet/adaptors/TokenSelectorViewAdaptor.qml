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
    property string searchString

    // output model
    readonly property SortFilterProxyModel outputAssetsModel: SortFilterProxyModel {
        sourceModel: showAllTokens && !!plainTokensBySymbolModel ? concatModel : assetsObjectProxyModel

        proxyRoles: [
            FastExpressionRole {
                name: "sectionId"
                expression: {
                    if (!model.currentBalance)
                        return d.favoritesSectionId

                    if (root.enabledChainIds.length === 1)
                        return "section_%1".arg(root.enabledChainIds[0])
                }
                expectedRoles: ["currentBalance"]
            },
            FastExpressionRole {
                name: "sectionName"
                function getSectionName(sectionId, hasBalance) {
                    if (sectionId === d.favoritesSectionId)
                        return qsTr("Popular assets")

                    if (root.enabledChainIds.length === 1 && hasBalance)
                        return qsTr("Your assets on %1").arg(ModelUtils.getByKey(root.flatNetworksModel, "chainId", root.enabledChainIds[0], "chainName"))
                }
                expression: getSectionName(model.sectionId, !!model.currentBalance)
                expectedRoles: ["sectionId", "currentBalance"]
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

        filters: [
            AnyOf {
                RegExpFilter {
                    roleName: "name"
                    pattern: root.searchString
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter {
                    roleName: "symbol"
                    pattern: root.searchString
                    caseSensitivity: Qt.CaseInsensitive
                }
            },
            ValueFilter {
                roleName: "communityId"
                value: ""
                enabled: !root.showCommunityAssets
            },
            // duplicate tokens filter
            FastExpressionFilter {
                function hasDuplicateKey(tokensKey) {
                    return ModelUtils.indexOf(assetsObjectProxyModel, "tokensKey", tokensKey) > -1
                }

                expression: {
                    if (model.which_model === "plain_tokens_model") {
                        return !hasDuplicateKey(model.tokensKey)
                    }
                    return true
                }
                expectedRoles: ["which_model", "tokensKey"]
                enabled: root.showAllTokens
            },
            // remove tokens not available on selected network(s)
            FastExpressionFilter {
                function isPresentOnEnabledNetworks(addressPerChain) {
                    if(!addressPerChain)
                           return true
                    return !!ModelUtils.getFirstModelEntryIf(
                                addressPerChain,
                                (addPerChain) => {
                                    return root.enabledChainIds.includes(addPerChain.chainId)
                                })
                }
                expression: isPresentOnEnabledNetworks(model.addressPerChain)
                expectedRoles: ["addressPerChain"]
            }
        ]

        sorters: [
            RoleSorter {
                roleName: "sectionId"
            },
            FastExpressionSorter {
                expression: {
                    if (modelLeft.sectionId === d.favoritesSectionId && modelRight.sectionId === d.favoritesSectionId)
                        return 0

                    const lhs = modelLeft.currencyBalance
                    const rhs = modelRight.currencyBalance
                    if (lhs < rhs)
                        return 1
                    else if (lhs > rhs)
                        return -1
                    return 0
                }
                expectedRoles: ["currencyBalance", "sectionId"]
            },
            RoleSorter {
                roleName: "name"
            }
            // FIXME #15277 sort by assetsController instead, to have the sorting/order as in the main wallet view
        ]
    }

    // internals
    QtObject {
        id: d

        readonly property string favoritesSectionId: "section_zzz"
    }

    RolesRenamingModel {
        id: renamedTokensBySymbolModel
        sourceModel: root.plainTokensBySymbolModel
        mapping: [
            RoleRename {
                from: "key"
                to: "tokensKey"
            }
        ]
    }

    ConcatModel {
        id: concatModel
        sources: [
            SourceModel {
                model: renamedTokensBySymbolModel
                markerRoleValue: "plain_tokens_model"
            },
            SourceModel {
                model: assetsObjectProxyModel
                markerRoleValue: "wallet_assets_model"
            }
        ]

        markerRoleName: "which_model"
        expectedRoles: ["tokensKey", "name", "symbol", "balances", "currentBalance", "currencyBalance", "currencyBalanceAsString", "communityId", "marketDetails"]
    }

    ObjectProxyModel {
        id: assetsObjectProxyModel
        sourceModel: root.assetsModel

        delegate: SortFilterProxyModel {
            id: delegateRoot

            // properties exposed as roles to the top-level model
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
                FastExpressionFilter {
                    expression: root.enabledChainIds.includes(model.chainId)
                    expectedRoles: ["chainId"]
                    enabled: root.enabledChainIds.length
                },
                RegExpFilter {
                    roleName: "account"
                    pattern: root.accountAddress
                    caseSensitivity: Qt.CaseInsensitive
                    enabled: root.accountAddress !== ""
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

        exposedRoles: ["balances", "currentBalance", "currencyBalance", "currencyBalanceAsString", "balanceAsString"]
        expectedRoles: ["communityId", "balances", "decimals", "marketDetails"]
    }
}
