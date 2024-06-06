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

    readonly property var dummySwapTransactionRoutes: SwapTransactionRoutes {}

    readonly property var swapStore: SwapStore {
        signal suggestedRoutesReady(var txRoutes)
        readonly property var accounts: WalletAccountsModel {}
        readonly property var flatNetworks: NetworksModel.flatNetworks
        readonly property bool areTestNetworksEnabled: true
        function getWei2Eth(wei, decimals) {
            return wei/(10**decimals)
        }
        function fetchSuggestedRoutes(accountFrom, accountTo, amount, tokenFrom, tokenTo,
                                    disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts) {}
    }

    readonly property var swapAdaptor: SwapModalAdaptor {
        currencyStore: CurrenciesStore {}
        walletAssetsStore: WalletAssetsStore {
            id: thisWalletAssetStore
            walletTokensStore: TokensStore {
                plainTokensBySymbolModel: TokensBySymbolModel {}
                getDisplayAssetsBelowBalanceThresholdDisplayAmount: () => 0
            }
            readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
            assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
        }
        swapStore: root.swapStore
        swapFormData: root.swapFormData
        swapOutputData: SwapOutputData{}
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

        readonly property SignalSpy formValuesChanged: SignalSpy {
            target: root.swapFormData
            signalName: "formValuesChanged"
        }

        // helper functions -------------------------------------------------------------

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function launchAndVerfyModal() {
            formValuesChanged.clear()
            verify(!!controlUnderTest)
            controlUnderTest.open()
            verify(!!controlUnderTest.opened)
        }

        function closeAndVerfyModal() {
            verify(!!controlUnderTest)
            controlUnderTest.close()
            verify(!controlUnderTest.opened)
            formValuesChanged.clear()
        }

        function getAndVerifyAccountsModalHeader() {
            const accountsModalHeader = findChild(controlUnderTest, "accountsModalHeader")
            verify(!!accountsModalHeader)
            return accountsModalHeader
        }

        function launchAccountSelectionPopup(accountsModalHeader) {
            // Launch account selection popup
            verify(!accountsModalHeader.control.popup.opened)
            mouseClick(accountsModalHeader)
            waitForRendering(accountsModalHeader)
            verify(!!accountsModalHeader.control.popup.opened)
            return accountsModalHeader
        }

        function verifyLoadingAndNoErrorsState() {
            // verify loading state was set and no errors currently
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "0")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, "0")
            compare(root.swapAdaptor.swapOutputData.totalFees, 0)
            compare(root.swapAdaptor.swapOutputData.bestRoutes, [])
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, false)
        }
        // end helper functions -------------------------------------------------------------

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
            }

            // close account selection dropdown
            accountsModalHeader.control.popup.close()

            // set network chainId and fromTokensKey and verify balances in account selection dropdown
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
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

                mouseClick(delegateUnderTest)
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

        function test_network_default_and_selection() {
            // Launch popup
            launchAndVerfyModal()

            // get network comboBox
            const networkComboBox = findChild(controlUnderTest, "networkFilter")
            verify(!!networkComboBox)

            // check default value of network comboBox, should be mainnet
            compare(root.swapFormData.selectedNetworkChainId, -1)
            compare(root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId, 11155111 /*Sepolia Mainnet*/)

            // lets ensure that the selected one is correctly set
            for (let i=0; i<networkComboBox.control.popup.contentItem.count; i++) {
                // launch network selection popup
                verify(!networkComboBox.control.popup.opened)
                mouseClick(networkComboBox)
                verify(networkComboBox.control.popup.opened)

                let delegateUnderTest = networkComboBox.control.popup.contentItem.itemAtIndex(i)
                verify(!!delegateUnderTest)

                // if you try selecting an item already selected it doesnt do anything
                if(networkComboBox.control.popup.contentItem.currentIndex === i) {
                    mouseClick(networkComboBox)
                } else {
                    // select item
                    mouseClick(delegateUnderTest)

                    // verify values set
                    verify(!networkComboBox.control.popup.opened)
                    compare(root.swapFormData.selectedNetworkChainId, networkComboBox.control.popup.contentItem.model.get(i).chainId)

                    const networkComboIcon = findChild(networkComboBox.control.contentItem, "contentItemIcon")
                    verify(!!networkComboIcon)
                    verify(networkComboIcon.asset.name.includes(root.swapAdaptor.filteredFlatNetworksModel.get(i).iconUrl))
                }
            }
            networkComboBox.control.popup.close()
            closeAndVerfyModal()
        }

        function test_network_and_account_header_items() {
            root.swapFormData.fromTokensKey = root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel.get(0).key

            // Launch popup
            launchAndVerfyModal()

            // get network comboBox
            const networkComboBox = findChild(controlUnderTest, "networkFilter")
            verify(!!networkComboBox)

            for (let i=0; i<networkComboBox.control.popup.contentItem.count; i++) {
                // launch network selection popup
                verify(!networkComboBox.control.popup.opened)
                mouseClick(networkComboBox)
                verify(networkComboBox.control.popup.opened)

                let delegateUnderTest = networkComboBox.control.popup.contentItem.itemAtIndex(i)
                verify(!!delegateUnderTest)

                let networkModelItem = networkComboBox.control.popup.contentItem.model.get(i)

                // if you try selecting an item already selected it doesnt do anything
                if(networkComboBox.control.popup.contentItem.currentIndex === i) {
                    mouseClick(networkComboBox)
                    root.swapFormData.selectedNetworkChainId = networkModelItem.chainId
                } else {
                    // select item
                    mouseClick(delegateUnderTest)
                }

                // verify values in accouns modal header dropdown
                const accountsModalHeader = getAndVerifyAccountsModalHeader()
                launchAccountSelectionPopup(accountsModalHeader)

                const comboBoxList = findChild(accountsModalHeader, "accountSelectorList")
                verify(!!comboBoxList)

                for(let j =0; j< comboBoxList.model.count; j++) {
                    let accountDelegateUnderTest = comboBoxList.itemAtIndex(j)
                    verify(!!accountDelegateUnderTest)
                    const inlineTagDelegate_0 = findChild(accountDelegateUnderTest, "inlineTagDelegate_0")
                    verify(!!inlineTagDelegate_0)

                    compare(inlineTagDelegate_0.asset.name, Style.svg("tiny/%1".arg(networkModelItem.iconUrl)))
                    compare(inlineTagDelegate_0.asset.color.toString().toUpperCase(), networkModelItem.chainColor.toString().toUpperCase())

                    let balancesModel = SQUtils.ModelUtils.getByKey(root.swapAdaptor.walletAssetsStore.baseGroupedAccountAssetModel, "tokensKey", root.swapFormData.fromTokensKey).balances
                    verify(!!balancesModel)
                    let filteredBalances = SQUtils.ModelUtils.modelToArray(balancesModel).filter(balances => balances.chainId === root.swapFormData.selectedNetworkChainId).filter(balances => balances.account === accountDelegateUnderTest.modelData.address)
                    verify(!!filteredBalances)
                    let accountBalance = filteredBalances.length > 0 ? filteredBalances[0]: { balance: "0", iconUrl: networkModelItem.iconUrl, chainColor: networkModelItem.chainColor}
                    verify(!!accountBalance)
                    let fromToken = SQUtils.ModelUtils.getByKey(root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel, "key", root.swapFormData.fromTokensKey)
                    verify(!!fromToken)
                    let bigIntBalance = SQUtils.AmountsArithmetic.toNumber(accountBalance.balance, fromToken.decimals)
                    compare(inlineTagDelegate_0.title, root.swapAdaptor.formatCurrencyAmount(bigIntBalance, fromToken.symbol))
                }
                // close account selection dropdown
                accountsModalHeader.control.popup.close()
            }
            root.swapFormData.selectedNetworkChainId = -1
            networkComboBox.control.popup.close()
            closeAndVerfyModal()
        }

        function test_edit_slippage() {
            // by default the max slippage button should show no values and the edit button shouldnt be visible

            // Launch popup
            launchAndVerfyModal()

            // test default values for the various footer items for slippage
            const maxSlippageText = findChild(controlUnderTest, "maxSlippageText")
            verify(!!maxSlippageText)
            compare(maxSlippageText.text, qsTr("Max slippage:"))

            const maxSlippageValue = findChild(controlUnderTest, "maxSlippageValue")
            verify(!!maxSlippageValue)

            const editSlippageButton = findChild(controlUnderTest, "editSlippageButton")
            verify(!!editSlippageButton)

            const editSlippagePanel = findChild(controlUnderTest, "editSlippagePanel")
            verify(!!editSlippagePanel)
            verify(!editSlippagePanel.visible)

            // set swap proposal to ready and check state of the edit slippage buttons and max slippage values
            root.swapAdaptor.validSwapProposalReceived = true
            compare(maxSlippageValue.text, "%1%".arg(0.5))
            verify(editSlippageButton.visible)

            // clicking on editSlippageButton should show the edit slippage panel
            mouseClick(editSlippageButton)
            verify(!editSlippageButton.visible)
            verify(editSlippagePanel.visible)

            const slippageSelector = findChild(editSlippagePanel, "slippageSelector")
            verify(!!slippageSelector)

            verify(slippageSelector.valid)
            compare(slippageSelector.value, 0.5)

            const buttonsRepeater = findChild(slippageSelector, "buttonsRepeater")
            verify(!!buttonsRepeater)
            waitForRendering(buttonsRepeater)

            for(let i =0; i< buttonsRepeater.count; i++) {
                let buttonUnderTest = buttonsRepeater.itemAt(i)
                verify(!!buttonUnderTest)

                // the mouseClick(buttonUnderTest) doesnt seem to work
                buttonUnderTest.clicked()

                verify(slippageSelector.valid)
                compare(slippageSelector.value, buttonUnderTest.value)

                compare(maxSlippageValue.text, "%1%".arg(buttonUnderTest.value))
            }

            const signButton = findChild(controlUnderTest, "signButton")
            verify(!!signButton)
            verify(signButton.enabled)
        }

        function test_modal_swap_proposal_setup() {
            // by default the max slippage button should show no values and the edit button shouldnt be visible

            root.swapAdaptor.reset()

            // Launch popup
            launchAndVerfyModal()

            const maxFeesText = findChild(controlUnderTest, "maxFeesText")
            verify(!!maxFeesText)

            const maxFeesValue = findChild(controlUnderTest, "maxFeesValue")
            verify(!!maxFeesValue)

            const signButton = findChild(controlUnderTest, "signButton")
            verify(!!signButton)

            const errorTag = findChild(controlUnderTest, "errorTag")
            verify(!!errorTag)

            // Check max fees values and sign button state when nothing is set
            compare(maxFeesText.text, qsTr("Max fees:"))
            compare(maxFeesValue.text, "--")
            verify(!signButton.enabled)
            verify(!errorTag.visible)

            // set input values in the form correctly
            root.swapFormData.fromTokensKey = root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel.get(0).key
            compare(formValuesChanged.count, 1)
            root.swapFormData.toTokenKey = root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel.get(1).key
            compare(formValuesChanged.count, 2)
            root.swapFormData.fromTokenAmount = 10
            compare(formValuesChanged.count, 3)
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            compare(formValuesChanged.count, 4)

            // wait for fetchSuggestedRoutes function to be called
            wait(1000)

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState()

            // emit event that no routes were found
            root.swapStore.suggestedRoutesReady(root.dummySwapTransactionRoutes.txNoRoutes)

            // verify loading state was removed and that error was displayed
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "0")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, "0")
            compare(root.swapAdaptor.swapOutputData.totalFees, 0)
            compare(root.swapAdaptor.swapOutputData.bestRoutes, [])
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, true)
            verify(errorTag.visible)
            verify(errorTag.text, qsTr("An error has occured, please try again"))
            verify(!signButton.enabled)
            compare(signButton.text, qsTr("Swap"))

            // edit some params to retry swap
            root.swapFormData.fromTokenAmount = 11
            compare(formValuesChanged.count, 5)

            // wait for fetchSuggestedRoutes function to be called
            wait(1000)

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState()

            // emit event with route that needs no approval
            let txRoutes = root.dummySwapTransactionRoutes.txHasRouteNoApproval
            root.swapStore.suggestedRoutesReady(txRoutes)

            // verify loading state removed and data ius displayed as expected on the Modal
            verify(root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "0")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, root.swapStore.getWei2Eth(txRoutes.amountToReceive, root.swapAdaptor.toToken.decimals).toString())

            // calculation needed for total fees
            let gasTimeEstimate = txRoutes.gasTimeEstimate
            let totalTokenFeesInFiat = gasTimeEstimate.totalTokenFees * root.swapAdaptor.fromToken.marketDetails.currencyPrice.amount
            let totalFees = root.swapAdaptor.currencyStore.getFiatValue(gasTimeEstimate.totalFeesInEth, Constants.ethToken) + totalTokenFeesInFiat

            compare(root.swapAdaptor.swapOutputData.totalFees, totalFees)
            compare(root.swapAdaptor.swapOutputData.bestRoutes, txRoutes.suggestedRoutes)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, false)
            verify(!errorTag.visible)
            verify(signButton.enabled)
            compare(signButton.text, qsTr("Swap"))

            // edit some params to retry swap
            root.swapFormData.fromTokenAmount = 1
            compare(formValuesChanged.count, 6)

            // wait for fetchSuggestedRoutes function to be called
            wait(1000)

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState()

            // emit event with route that needs no approval
            let txRoutes2 = root.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded
            root.swapStore.suggestedRoutesReady(txRoutes2)

            // verify loading state removed and data ius displayed as expected on the Modal
            verify(root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "0")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, root.swapStore.getWei2Eth(txRoutes2.amountToReceive, root.swapAdaptor.toToken.decimals).toString())

            // calculation needed for total fees
            gasTimeEstimate = txRoutes2.gasTimeEstimate
            totalTokenFeesInFiat = gasTimeEstimate.totalTokenFees * root.swapAdaptor.fromToken.marketDetails.currencyPrice.amount
            totalFees = root.swapAdaptor.currencyStore.getFiatValue(gasTimeEstimate.totalFeesInEth, Constants.ethToken) + totalTokenFeesInFiat

            compare(root.swapAdaptor.swapOutputData.totalFees, totalFees)
            compare(root.swapAdaptor.swapOutputData.bestRoutes, txRoutes2.suggestedRoutes)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, true)
            compare(root.swapAdaptor.swapOutputData.hasError, false)
            verify(!errorTag.visible)
            verify(signButton.enabled)
            compare(signButton.text, qsTr("Approve %1").arg(root.swapAdaptor.fromToken.symbol))
        }
    }
}
