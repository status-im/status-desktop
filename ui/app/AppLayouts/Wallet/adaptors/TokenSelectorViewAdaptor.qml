import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

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
    */

    // input API
    required property var assetsModel
    required property var flatNetworksModel
    required property string currentCurrency // CurrenciesStore.currentCurrency, e.g. "USD"

    // optional filter properties; empty/default values means no filtering
    property var enabledChainIds: []
    property string accountAddress
    property bool showCommunityAssets
    property string searchString

    // output model
    readonly property SortFilterProxyModel outputAssetsModel: SortFilterProxyModel {
        sourceModel: assetsObjectProxyModel

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
            }
        ]

        sorters: [
            RoleSorter {
                roleName: "sectionId"
            },
            RoleSorter {
                roleName: "currencyBalance"
                sortOrder: Qt.DescendingOrder
            },
            RoleSorter {
                roleName: "name"
            }
        ]
    }

    // internals
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

            readonly property string sectionId: {
                if (root.enabledChainIds.length === 1) {
                    return currentBalance ? "section_%1".arg(root.enabledChainIds[0]) : "section_zzz"
                }
                return ""
            }
            readonly property string sectionName: {
                if (root.enabledChainIds.length === 1) {
                    return currentBalance ? qsTr("Your assets on %1").arg(ModelUtils.getByKey(root.flatNetworksModel, "chainId", root.enabledChainIds[0], "chainName"))
                                          : qsTr("Popular assets")
                }
                return ""
            }

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

        exposedRoles: ["balances", "currentBalance", "currencyBalance", "currencyBalanceAsString", "balanceAsString", "sectionId", "sectionName"]
        expectedRoles: ["communityId", "balances", "decimals", "marketDetails"]
    }
}
