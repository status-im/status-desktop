import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

import utils 1.0

QObject {
    id: root

    // Input API
    /** Plain tokens model without balances **/
    required property var plainTokensBySymbolModel
    /** All networks model **/
    required property var flatNetworksModel
    /** Selected network chain id **/
    required property int selectedNetworkChainId

    // output model
    readonly property SortFilterProxyModel outputModel: SortFilterProxyModel {
        objectName: "TokenSelectorViewAdaptor_outputModel"

        readonly property string networkName: ModelUtils.getByKey(root.flatNetworksModel, "chainId", root.selectedNetworkChainId, "chainName")

        sourceModel: RolesRenamingModel {
            objectName: "PaymentRequestAdaptor_allTokensPlain"
            sourceModel: SortFilterProxyModel {
                sourceModel: root.plainTokensBySymbolModel
                filters: [
                    FastExpressionFilter {
                        function isPresentOnEnabledNetwork(addressPerChain, selectedChainId) {
                            if(!addressPerChain || selectedChainId < 0)
                                return true
                            return !!ModelUtils.getFirstModelEntryIf(
                                        addressPerChain,
                                        (addPerChain) => {
                                            return selectedChainId === addPerChain.chainId
                                        })
                        }
                        expression: {
                            return isPresentOnEnabledNetwork(model.addressPerChain, root.selectedNetworkChainId)
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

        proxyRoles: [
            ConstantRole {
                name: "sectionName"
                value: qsTr("Popular assets on %1").arg(outputModel.networkName)
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
            // FIXME popular first and then by name
            RoleSorter {
                roleName: "name"
            }
        ]
        filters: [
            ValueFilter {
                roleName: "communityId"
                value: ""
            }
        ]
    }
}
