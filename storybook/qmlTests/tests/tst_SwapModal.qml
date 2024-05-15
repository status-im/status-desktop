import QtQuick 2.15
import QtTest 1.15

import StatusQ 0.1 // See #10218
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1

import QtQuick.Controls 2.15

import Models 1.0
import Storybook 1.0

import utils 1.0
import shared.stores 1.0
import AppLayouts.Wallet.popups.swap 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet 1.0

Item {
    id: root
    width: 600
    height: 400

    readonly property var swapStore: SwapStore {
        readonly property var accounts: WalletAccountsModel {}
        readonly property var flatNetworks: NetworksModel.flatNetworks
        readonly property bool areTestNetworksEnabled: true
    }

    readonly property var swapAdaptor: SwapModalAdaptor {
        currencyStore: CurrenciesStore {}
        walletAssetsStore: WalletAssetsStore {
            id: thisWalletAssetStore
            walletTokensStore: TokensStore {
                readonly property var plainTokensBySymbolModel: TokensBySymbolModel {}
            }
            readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
            assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
        }
        swapStore: root.swapStore
        swapFormData: root.swapFormData
    }

    readonly property var swapFormData: SwapInputParamsForm {}

    Component {
        id: componentUnderTest
        SwapModal {
            swapInputParamsForm: root.swapFormData
            swapAdaptor: root.swapAdaptor
        }
    }

    TestCase {
        name: "SwapModal"
        when: windowShown

        property SwapModal controlUnderTest: null

        // helper functions -------------------------------------------------------------
        function launchAndVerfyModal() {
            verify(!!controlUnderTest)
            controlUnderTest.open()
            verify(!!controlUnderTest.opened)
        }

        function closeAndVerfyModal() {
            verify(!!controlUnderTest)
            controlUnderTest.close()
            verify(!controlUnderTest.opened)
        }

        function getAndVerifyAccountsModalHeader() {
            const accountsModalHeader = findChild(controlUnderTest, "accountsModalHeader")
            verify(!!accountsModalHeader)
            return accountsModalHeader
        }

        function launchAccountSelectionPopup(accountsModalHeader) {
            // Launch account selection popup
            verify(!accountsModalHeader.control.popup.opened)
            mouseClick(accountsModalHeader, Qt.LeftButton)
            waitForRendering(accountsModalHeader)
            verify(!!accountsModalHeader.control.popup.opened)
            return accountsModalHeader
        }
        // end helper functions -------------------------------------------------------------

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function test_floating_header_default_account() {
            verify(!!controlUnderTest)
            /* using a for loop set different accounts as default index and
            check if the correct values are displayed in the floating header*/
            for (let i = 0; i< swapAdaptor.nonWatchAccounts.count; i++) {
                root.swapFormData.selectedAccountIndex = i

                // Launch popup
                launchAndVerfyModal()

                const floatingHeaderBackground = findChild(controlUnderTest, "headerBackground")
                verify(!!floatingHeaderBackground)
                compare(floatingHeaderBackground.color.toString().toUpperCase(), Utils.getColorForId(swapAdaptor.nonWatchAccounts.get(i).colorId).toString().toUpperCase())

                const headerContentItemText = findChild(controlUnderTest, "headerContentItemText")
                verify(!!headerContentItemText)
                compare(headerContentItemText.text, swapAdaptor.nonWatchAccounts.get(i).name)

                const headerContentItemEmoji = findChild(controlUnderTest, "headerContentItemEmoji")
                verify(!!headerContentItemEmoji)
                compare(headerContentItemEmoji.emojiId, SQUtils.Emoji.iconId(swapAdaptor.nonWatchAccounts.get(i).emoji))
            }
            closeAndVerfyModal()
        }

        function test_floating_header_doesnt_contain_watch_accounts() {
            // main input list from store should contian watch accounts
            let hasWatchAccount = false
            for(let i =0; i< swapStore.accounts.count; i++) {
                if(swapStore.accounts.get(i).walletType === Constants.watchWalletType) {
                    hasWatchAccount = true
                    break
                }
            }
            verify(!!hasWatchAccount)

            // launch modal and get the account selection header
            launchAndVerfyModal()
            const accountsModalHeader = getAndVerifyAccountsModalHeader()

            // header model should not contain watch accounts
            let floatingHeaderHasWatchAccount = false
            for(let i =0; i< accountsModalHeader.model.count; i++) {
                if(accountsModalHeader.model.get(i).walletType === Constants.watchWalletType) {
                    floatingHeaderHasWatchAccount = true
                    break
                }
            }
            verify(!floatingHeaderHasWatchAccount)

            closeAndVerfyModal()
        }

        function test_floating_header_list_items() {
            // Launch popup and account selection modal
            launchAndVerfyModal()
            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            launchAccountSelectionPopup(accountsModalHeader)

            const comboBoxList = findChild(controlUnderTest, "accountSelectorList")
            verify(!!comboBoxList)

            for(let i =0; i< comboBoxList.model.count; i++) {
                let delegateUnderTest = comboBoxList.itemAtIndex(i)
                // check if the items are organized as per the position role
                if(!!delegateUnderTest && !!comboBoxList.itemAtIndex(i+1)) {
                    verify(comboBoxList.itemAtIndex(i+1).modelData.position > delegateUnderTest.modelData.position)
                }
                compare(delegateUnderTest.title, swapAdaptor.nonWatchAccounts.get(i).name)
                compare(delegateUnderTest.subTitle, SQUtils.Utils.elideText(swapAdaptor.nonWatchAccounts.get(i).address, 6, 4))
                compare(delegateUnderTest.asset.color.toString().toUpperCase(), swapAdaptor.nonWatchAccounts.get(i).color.toString().toUpperCase())
                compare(delegateUnderTest.asset.emoji, swapAdaptor.nonWatchAccounts.get(i).emoji)

                const walletAccountCurrencyBalance = findChild(delegateUnderTest, "walletAccountCurrencyBalance")
                verify(!!walletAccountCurrencyBalance)
                verify(walletAccountCurrencyBalance.text, LocaleUtils.currencyAmountToLocaleString(swapAdaptor.nonWatchAccounts.get(i).currencyBalance))

                // check if selected item in combo box is highlighted with the right color
                if(comboBoxList.currentIndex === i) {
                    verify(delegateUnderTest.color, Theme.palette.statusListItem.highlightColor)
                }
                else {
                    verify(delegateUnderTest.color, Theme.palette.transparent)
                }

                // TODO: always null not sure why
                // const walletAccountTypeIcon = findChild(delegateUnderTest, "walletAccountTypeIcon")
                // verify(!!walletAccountTypeIcon)
                // compare(walletAccountTypeIcon.icon, swapAdaptor.nonWatchAccounts.get(i).walletType === Constants.watchWalletType ? "show" : delegateUnderTest.modelData.migratedToKeycard ? "keycard": "")

                // Hover over the item and check hovered state
                mouseMove(delegateUnderTest, delegateUnderTest.width/2, delegateUnderTest.height/2)
                verify(delegateUnderTest.sensor.containsMouse)
                compare(delegateUnderTest.subTitle, WalletUtils.colorizedChainPrefix(root.swapAdaptor.getNetworkShortNames(swapAdaptor.nonWatchAccounts.get(i).preferredSharingChainIds)))
                verify(delegateUnderTest.color, Theme.palette.baseColor2)

            }
            controlUnderTest.close()
        }

        function test_floating_header_after_setting_fromAsset() {
            // Launch popup
            launchAndVerfyModal()

            // launch account selection dropdown
            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            launchAccountSelectionPopup(accountsModalHeader)

            const comboBoxList = findChild(accountsModalHeader, "accountSelectorList")
            verify(!!comboBoxList)

            // before setting network chainId and fromTokensKey the header should not have balances
            for(let i =0; i< comboBoxList.model.count; i++) {
                let delegateUnderTest = comboBoxList.itemAtIndex(i)
                verify(!delegateUnderTest.modelData.fromToken)
                verify(!delegateUnderTest.modelData.accountBalance)
            }

            // close account selection dropdown
            accountsModalHeader.control.popup.close()

            // set network chainId and fromTokensKey and verify balances in account selection dropdown
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.__filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.fromTokensKey = root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel.get(0).key
            compare(controlUnderTest.swapInputParamsForm.selectedNetworkChainId, root.swapFormData.selectedNetworkChainId)
            compare(controlUnderTest.swapInputParamsForm.fromTokensKey, root.swapFormData.fromTokensKey)

            // launch account selection dropdown
            launchAccountSelectionPopup(accountsModalHeader)
            verify(!!comboBoxList)

            for(let i =0; i< comboBoxList.model.count; i++) {
                let delegateUnderTest = comboBoxList.itemAtIndex(i)
                verify(!!delegateUnderTest.modelData.fromToken)
                verify(!!delegateUnderTest.modelData.accountBalance)
                compare(delegateUnderTest.inlineTagModel, 1)

                const inlineTagDelegate_0 = findChild(delegateUnderTest, "inlineTagDelegate_0")
                verify(!!inlineTagDelegate_0)

                compare(inlineTagDelegate_0.asset.name, Style.svg("tiny/%1".arg(delegateUnderTest.modelData.accountBalance.iconUrl)))
                compare(inlineTagDelegate_0.asset.color.toString().toUpperCase(), delegateUnderTest.modelData.accountBalance.chainColor.toString().toUpperCase())
                compare(inlineTagDelegate_0.titleText.color, delegateUnderTest.modelData.accountBalance.balance === "0" ? Theme.palette.baseColor1 : Theme.palette.directColor1)

                let bigIntBalance = SQUtils.AmountsArithmetic.toNumber(delegateUnderTest.modelData.accountBalance.balance, delegateUnderTest.modelData.fromToken.decimals)
                compare(inlineTagDelegate_0.title, root.swapAdaptor.formatCurrencyAmount(bigIntBalance, delegateUnderTest.modelData.fromToken.symbol))
            }

            closeAndVerfyModal()
        }

        function test_floating_header_selection() {
            // Launch popup
            launchAndVerfyModal()

            for(let i =0; i< swapAdaptor.nonWatchAccounts.count; i++) {

                // launch account selection dropdown
                const accountsModalHeader = getAndVerifyAccountsModalHeader()
                launchAccountSelectionPopup(accountsModalHeader)

                const comboBoxList = findChild(accountsModalHeader, "accountSelectorList")
                verify(!!comboBoxList)

                let delegateUnderTest = comboBoxList.itemAtIndex(i)

                mouseClick(delegateUnderTest, Qt.LeftButton)
                waitForRendering(delegateUnderTest)
                verify(accountsModalHeader.control.popup.closed)

                // The input params form's slected Index should be updated  as per this selection
                compare(root.swapFormData.selectedAccountIndex, i)

                // The comboBox item should  reflect chosen account
                const floatingHeaderBackground = findChild(accountsModalHeader, "headerBackground")
                verify(!!floatingHeaderBackground)
                compare(floatingHeaderBackground.color.toString().toUpperCase(), swapAdaptor.nonWatchAccounts.get(i).color.toString().toUpperCase())

                const headerContentItemText = findChild(accountsModalHeader, "headerContentItemText")
                verify(!!headerContentItemText)
                compare(headerContentItemText.text, swapAdaptor.nonWatchAccounts.get(i).name)

                const headerContentItemEmoji = findChild(accountsModalHeader, "headerContentItemEmoji")
                verify(!!headerContentItemEmoji)
                compare(headerContentItemEmoji.emojiId, SQUtils.Emoji.iconId(swapAdaptor.nonWatchAccounts.get(i).emoji))
            }
            closeAndVerfyModal()
        }
    }
}
