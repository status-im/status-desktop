import QtQuick 2.15

import AppLayouts.Wallet.popups.swap 1.0
import AppLayouts.stores 1.0 as AppLayoutStores
import AppLayouts.Wallet.stores 1.0 as WalletStores

import shared.stores 1.0

import utils 1.0

QtObject {
    id: root

    required property var popupParent

    required property CurrenciesStore currencyStore
    required property AppLayoutStores.RootStore rootStore
    required property WalletStores.WalletAssetsStore walletAssetsStore
    required property NetworksStore networksStore

    function openSendModal(params = {}, callback = null) {
        d.swapInputParams = params
        let swapModalInst = swapModalComponent.createObject(popupParent)
        swapModalInst.open()

        if (callback)
            callback(swapModalInst)
    }

    readonly property QtObject _d: QtObject {
        id: d

        function addMetricsEvent(subEvent) {
            Global.addCentralizedMetricIfEnabled("swap", {subEvent: subEvent})
        }

        readonly property WalletStores.SwapStore swapStore: WalletStores.SwapStore {
            onTransactionSent: (returnedUuid, chainId, approvalTx, txHash, error) => {
                                   if(returnedUuid !== d.lastUuid || approvalTx) {
                                       return
                                   }

                                   if (!!error) {
                                       d.addMetricsEvent("transaction error")
                                   } else {
                                       d.addMetricsEvent("transaction successful")
                                   }
                               }
        }

        property string lastUuid

        property var swapInputParams
    }

    readonly property Component swapModalComponent: Component {
        // TODO: Update the API to be explicit and avoid direct store access
        SwapModal {
            swapAdaptor: SwapModalAdaptor {
                swapStore: d.swapStore
                walletAssetsStore: root.walletAssetsStore
                currencyStore: root.currencyStore
                networksStore: root.networksStore
                swapFormData: d.swapInputParams
                swapOutputData: SwapOutputData{}

                onUuidChanged: {
                    if (!!uuid)
                        d.lastUuid = uuid
                }
            }
            swapInputParamsForm: d.swapInputParams
            loginType: root.rootStore.loginType
            onAddMetricsEvent: (subEvent) => d.addMetricsEvent(subEvent)
            onClosed: {
                destroy()
                swapInputParamsForm.resetFormData()
            }
        }
    }
}
