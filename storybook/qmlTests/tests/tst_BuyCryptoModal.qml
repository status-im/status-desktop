import QtQuick 2.15
import QtTest 1.15

import SortFilterProxyModel 0.2

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Backpressure 0.1

import Models 1.0
import utils 1.0

import AppLayouts.Wallet.popups.buy 1.0
import AppLayouts.Wallet.stores 1.0

import shared.stores 1.0

Item {
    id: root
    width: 600
    height: 800

    QtObject {
        id: d
        property string uuid
        property var debounceFetchProviderUrl: Backpressure.debounce(root, 500, function() {
            d.buyCryptoStore.providerUrlReady(d.uuid, "xxxx")
        })
        property var debounceFetchProvidersList: Backpressure.debounce(root, 500, function() {
            d.buyCryptoStore.areProvidersLoading = false
        })
        readonly property var buyCryptoStore: BuyCryptoStore {
            readonly property var providersModel: _onRampProvidersModel
            property bool areProvidersLoading
            signal providerUrlReady(string uuid , string url)

            function fetchProviders() {
                console.warn("fetchProviders called >>")
                areProvidersLoading = true
                d.debounceFetchProvidersList()
            }

            function fetchProviderUrl(uuid, providerID,
                                      isRecurrent, accountAddress = "",
                                      chainID = 0, symbol = "") {
                console.warn("fetchProviderUrl called >> uuid: ", uuid, "providerID: ",providerID
                             , "isRecurrent: ", isRecurrent, "accountAddress: ", accountAddress,
                             "chainID: ", chainID, "symbol: ", symbol)
                d.uuid = uuid
                d.debounceFetchProviderUrl()
            }
        }
    }

    OnRampProvidersModel{
        id: _onRampProvidersModel
    }

    SortFilterProxyModel {
        id: recurrentOnRampProvidersModel
        sourceModel: _onRampProvidersModel
        filters: ValueFilter {
            roleName: "supportsRecurrentPurchase"
            value: true
        }
    }

    Component {
        id: componentUnderTest
        BuyCryptoModal {
            id: buySellModal
            buyCryptoAdaptor: BuyCryptoModalAdaptor {
                buyCryptoStore: d.buyCryptoStore
                readonly property var currencyStore: CurrenciesStore {}
                readonly property var assetsStore: WalletAssetsStore {
                    id: thisWalletAssetStore
                    walletTokensStore: TokensStore {
                        plainTokensBySymbolModel: TokensBySymbolModel {}
                    }
                    readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
                    assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
                }
                buyCryptoFormData: buySellModal.buyCryptoInputParamsForm
                walletAccountsModel: WalletAccountsModel{}
                networksModel: NetworksModel.flatNetworks
                areTestNetworksEnabled: true
                groupedAccountAssetsModel: assetsStore.groupedAccountAssetsModel
                plainTokensBySymbolModel: assetsStore.walletTokensStore.plainTokensBySymbolModel
                currentCurrency: currencyStore.currentCurrency
            }
            buyCryptoInputParamsForm: BuyCryptoParamsForm{
                selectedWalletAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                selectedNetworkChainId: 11155111
                selectedTokenKey: "ETH"
            }
        }
    }

    SignalSpy {
        id: notificationSpy
        target: Global
        signalName: "openLinkWithConfirmation"
    }

    TestCase {
        name: "BuyCryptoModal"
        when: windowShown

        property BuyCryptoModal controlUnderTest: null

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function launchPopup() {
            verify(!!controlUnderTest)
            controlUnderTest.open()
            verify(!!controlUnderTest.opened)
        }

        function testDelegateItems(providersList, modelToCompareAgainst) {
            for(let i =0; i< providersList.count; i++) {
                let delegateUnderTest = providersList.itemAtIndex(i)
                verify(!!delegateUnderTest)

                compare(delegateUnderTest.title, modelToCompareAgainst.get(i).name)
                compare(delegateUnderTest.subTitle, modelToCompareAgainst.get(i).description)
                compare(delegateUnderTest.asset.name, modelToCompareAgainst.get(i).logoUrl)

                const feesText = findChild(delegateUnderTest, "feesText")
                verify(!!feesText)
                compare(feesText.text,  modelToCompareAgainst.get(i).fees)

                /* TODO: fix when writing more tests for this functionality
                const externalLinkIcon = findChild(delegateUnderTest, "externalLinkIcon")
                verify(!!externalLinkIcon)
                compare(externalLinkIcon.icon, "tiny/external")
                compare(externalLinkIcon.color, Theme.palette.baseColor1) */

                // Hover over the item and check hovered state
                mouseMove(delegateUnderTest, delegateUnderTest.width/2, delegateUnderTest.height/2)
                verify(delegateUnderTest.sensor.containsMouse)
                /* TODO: fix when writing more tests for this functionality
                compare(externalLinkIcon.color, Theme.palette.directColor1) */
                verify(delegateUnderTest.color, Theme.palette.baseColor2)
            }
        }

        function test_launchAndCloseModal() {
            launchPopup()

            // close popup
            controlUnderTest.close()
            verify(!controlUnderTest.opened)
        }

        function test_ModalFooter() {
            // Launch modal
            launchPopup()

            // check if footer has Done button and action on button clicked
            compare(controlUnderTest.rightButtons.length, 2)
            verify(!controlUnderTest.rightButtons[0].visible)
            verify(controlUnderTest.rightButtons[1].visible)
            compare(controlUnderTest.rightButtons[1].text, qsTr("Done"))
            mouseClick(controlUnderTest.rightButtons[1])

            // popup should be closed
            verify(!controlUnderTest.opened)
        }

        function test_modalContent() {
            // Launch modal
            launchPopup()

            // find tab bar
            const tabBar = findChild(controlUnderTest, "tabBar")
            verify(!!tabBar)

            // find providers list
            const providersList = findChild(controlUnderTest, "providersList")
            waitForRendering(providersList)
            verify(!!providersList)

            // should have 2 items
            compare(tabBar.count, 2)

            // current index set should be to 0
            compare(tabBar.currentIndex, 0)

            // item 0 should have text "One time"
            compare(tabBar.itemAt(0).text, qsTr("One time"))

            // item 1 should have text "Recurrent"
            compare(tabBar.itemAt(1).text, qsTr("Recurrent"))

            // close popup
            controlUnderTest.close()
            verify(!controlUnderTest.opened)
        }

        function test_modalContent_OneTime_tab() {
            notificationSpy.clear()
            // Launch modal
            launchPopup()

            // find tab bar
            const tabBar = findChild(controlUnderTest, "tabBar")
            verify(!!tabBar)

            // find providers list
            const providersList = findChild(controlUnderTest, "providersList")
            waitForRendering(providersList)
            verify(!!providersList)

            tryCompare(controlUnderTest.buyCryptoAdaptor.buyCryptoStore, "areProvidersLoading", false)

            mouseClick(tabBar.itemAt(0))
            compare(tabBar.currentIndex, 0)

            // verify that 4 items are listed
            compare(providersList.count, 4)

            // check if delegate contents are as expected
            testDelegateItems(providersList, _onRampProvidersModel)

            let delegateUnderTest = providersList.itemAtIndex(0)
            verify(!!delegateUnderTest)

            // test mouse click
            tryCompare(notificationSpy, "count", 0)
            mouseClick(delegateUnderTest)
            tryCompare(notificationSpy, "count", 1)
            compare(notificationSpy.signalArguments[0][0], "xxxx")
            compare(notificationSpy.signalArguments[0][1], _onRampProvidersModel.get(0).hostname)
            notificationSpy.clear()

            // popup should be closed
            verify(!controlUnderTest.opened)
        }

        function test_modalContent_recurrent_tab() {
            notificationSpy.clear()
            // Launch modal
            launchPopup()

            // find tab bar
            const tabBar = findChild(controlUnderTest, "tabBar")
            verify(!!tabBar)

            // find providers list
            const providersList = findChild(controlUnderTest, "providersList")
            verify(!!providersList)

            tryCompare(controlUnderTest.buyCryptoAdaptor.buyCryptoStore, "areProvidersLoading", false)

            // check data in "Recurrent" tab --------------------------------------------------------
            mouseClick(tabBar.itemAt(1))
            compare(tabBar.currentIndex, 1)
            waitForRendering(providersList)
            verify(!!providersList)

            // verify that 1 item is listed
            compare(providersList.count, 1)

            // check if delegate contents are as expected
            testDelegateItems(providersList, recurrentOnRampProvidersModel)

            let delegateUnderTest = providersList.itemAtIndex(0)
            verify(!!delegateUnderTest)

            // test mouse click
            tryCompare(notificationSpy, "count", 0)
            verify(controlUnderTest.opened)
            mouseClick(delegateUnderTest)
            tryCompare(notificationSpy, "count", 0)
            notificationSpy.clear()
            //TODO: add more test logic here for second page of selecting params
        }
    }
}
