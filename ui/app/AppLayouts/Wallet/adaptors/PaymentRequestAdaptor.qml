import QtQuick

import StatusQ
import StatusQ.Core.Utils

import QtModelsToolkit
import SortFilterProxyModel

import utils

QObject {
    id: root

    // Input API
    /** Plain tokens model without balances **/
    required property var tokenGroupsModel
    /** All networks model **/
    required property var flatNetworksModel
    /** Selected network chain id **/
    required property int selectedNetworkChainId

    // output model
    readonly property SortFilterProxyModel outputModel: SortFilterProxyModel {
        objectName: "TokenSelectorViewAdaptor_outputModel"

        readonly property string networkName: ModelUtils.getByKey(root.flatNetworksModel, "chainId", root.selectedNetworkChainId, "chainName")

        sourceModel: SortFilterProxyModel {
            objectName: "PaymentRequestAdaptor_allTokensPlain"
            sourceModel: root.tokenGroupsModel
            filters: [
                FastExpressionFilter {
                    function isPresentOnEnabledNetwork(tokens, selectedChainId) {
                        if(selectedChainId < 0)
                            return true
                        return !!ModelUtils.getFirstModelEntryIf(
                                    tokens,
                                    (t) => {
                                        return selectedChainId === t.chainId
                                    })
                    }
                    expression: {
                        return isPresentOnEnabledNetwork(model.tokens, root.selectedNetworkChainId)
                    }
                    expectedRoles: ["tokens"]
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
                expression: model.logoUri || tokenIcon(model.symbol)
                expectedRoles: ["logoUri", "symbol"]
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
