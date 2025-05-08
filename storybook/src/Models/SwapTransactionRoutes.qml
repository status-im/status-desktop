import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core 0.1

import utils 1.0

QtObject {
    id: root

    property var txNoRoutes: ({
                                  suggestedRoutes: root.noRoutes,
                                  gasTimeEstimate: {
                                      totalFeesInNativeCrypto:0.0,
                                      totalTokenFees:0.0,
                                      totalTime:0
                                  },
                                  gasFees:{
                                      gasPrice:0.061734012,
                                      baseFee:0.055187939,
                                      maxPriorityFeePerGas:0.001,
                                      maxFeePerGasL:0.059980417,
                                      maxFeePerGasM:0.060071775,
                                      maxFeePerGasH:0.110375878,
                                      l1GasFee:318800.0,
                                      eip1559Enabled:true
                                  },
                                  amountToReceive:"0",
                                  toNetworksModel:[],
                                  error:""
                              })


    property var txHasRouteNoApproval: ({
                                            suggestedRoutes: root.goodRouteNoApprovalNeeded,
                                            gasTimeEstimate:{
                                                totalFeesInNativeCrypto:0.0005032000000000001,
                                                totalTokenFees:-0.004508663259772343,
                                                totalTime:2
                                            },
                                            gasFees:{
                                                gasPrice:0.061734012,
                                                baseFee:0.055187939,
                                                maxPriorityFeePerGas:0.001,
                                                maxFeePerGasL:0.059980417,
                                                maxFeePerGasM:0.060071775,
                                                maxFeePerGasH:0.110375878,
                                                l1GasFee:318800.0,
                                                eip1559Enabled:true
                                            },
                                            amountToReceive: "379295138519599728000",
                                            toNetworksModel: root.toModel
                                        })

    property var txHasRoutesApprovalNeeded: ({
                                                 suggestedRoutes: root.goodRouteApprovalNeeded,
                                                 gasTimeEstimate:{
                                                     totalFeesInNativeCrypto:0.0005032000000000001,
                                                     totalTokenFees:-0.004508663259772343,
                                                     totalTime:2
                                                 },
                                                 gasFees:{
                                                     gasPrice:0.061734012,
                                                     baseFee:0.055187939,
                                                     maxPriorityFeePerGas:0.001,
                                                     maxFeePerGasL:0.059980417,
                                                     maxFeePerGasM:0.060071775,
                                                     maxFeePerGasH:0.110375878,
                                                     l1GasFee:318800.0,
                                                     eip1559Enabled:true
                                                 },
                                                 amountToReceive: "379295138519599728000",
                                                 toNetworksModel: root.toModel
                                             })

    property ListModel toModel: ListModel {
        ListElement {
            chainId: 11155420
            chainName: "Optimism"
            iconUrl: "network/Network=Optimism"
            amountOut: "3003845308235848343"
        }
    }
    property ListModel goodRouteNoApprovalNeeded: ListModel {
        Component.onCompleted: append(suggestesRoutes)

        property var suggestesRoutes: [
            {
                route: {
                    bridgeName:"Paraswap",
                    fromNetwork: NetworksModel.flatNetworks.get(1),
                    toNetwork: NetworksModel.flatNetworks.get(1),
                    maxAmountIn:"22562169837824631",
                    amountIn:"100000000000000",
                    amountOut:"379295138519599728",
                    gasAmount:169300,
                    gasFees:{
                        gasPrice:0.061734012,
                        baseFee:0.055187939,
                        maxPriorityFeePerGas:0.001,
                        maxFeePerGasL:0.059980417,
                        maxFeePerGasM:0.060071775,
                        maxFeePerGasH:0.110375878,
                        l1GasFee:318800.0,
                        eip1559Enabled:true
                    },
                    tokenFees:0.0,
                    bonderFees:"0x0",
                    cost:1211911824.038662,
                    estimatedTime:3,
                    isFirstSimpleTx:true,
                    isFirstBridgeTx:true,
                    approvalRequired:false,
                    approvalGasFees:0.0,
                    approvalAmountRequired:"0",
                    approvalContractAddress:"0x216b4b4ba9f3e719726886d34a177484278bfcae"
                }
            }
        ]
    }
    property ListModel goodRouteApprovalNeeded: ListModel {
        Component.onCompleted: append(suggestesRoutes)

        property var suggestesRoutes: [
            {
                route: {
                    bridgeName:"Paraswap",
                    fromNetwork: NetworksModel.flatNetworks.get(1),
                    toNetwork: NetworksModel.flatNetworks.get(1),
                    maxAmountIn:"22562169837824631",
                    amountIn:"100000000000000",
                    amountOut:"379295138519599728",
                    gasAmount:169300,
                    gasFees:{
                        gasPrice:0.061734012,
                        baseFee:0.055187939,
                        maxPriorityFeePerGas:0.001,
                        maxFeePerGasL:0.059980417,
                        maxFeePerGasM:0.060071775,
                        maxFeePerGasH:0.110375878,
                        l1GasFee:318800.0,
                        eip1559Enabled:true
                    },
                    tokenFees:0.0,
                    bonderFees:"0x0",
                    cost:1211911824.038662,
                    estimatedTime:3,
                    isFirstSimpleTx:true,
                    isFirstBridgeTx:true,
                    approvalRequired:true,
                    approvalGasFees:0.100000000000000007,
                    approvalAmountRequired:"100000000000000000000",
                    approvalContractAddress:"0x216b4b4ba9f3e719726886d34a177484278bfcae"
                }
            }
        ]
    }

    property ListModel noRoutes: ListModel {}
}
