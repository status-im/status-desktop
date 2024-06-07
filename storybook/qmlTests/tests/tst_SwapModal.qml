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

    property SwapInputParamsForm swapFormData: null

    Component {
        id: swapFormDataComponent
        SwapInputParamsForm { }
    }

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
            root.swapFormData = createTemporaryObject(swapFormDataComponent, root)
            swapAdaptor.swapFormData = root.swapFormData
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { swapInputParamsForm: root.swapFormData})
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
            const accountsModalHeader = findChild(controlUnderTest, "accountSelector")
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

        function verifyLoadingAndNoErrorsState(payPanel, receivePanel) {
            // verify loading state was set and no errors currently
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.totalFees, 0)
            compare(root.swapAdaptor.swapOutputData.bestRoutes, [])
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, false)

            // verfy input and output panels
            verify(!payPanel.mainInputLoading)
            verify(!payPanel.bottomTextLoading)
            compare(payPanel.selectedHoldingId, root.swapFormData.fromTokensKey)
            compare(payPanel.value, Number(root.swapFormData.fromTokenAmount))
            compare(payPanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(root.swapFormData.fromTokenAmount, root.swapAdaptor.fromToken.decimals).toString())
            verify(payPanel.valueValid)
            verify(receivePanel.mainInputLoading)
            verify(receivePanel.bottomTextLoading)
            verify(!receivePanel.interactive)
            compare(receivePanel.selectedHoldingId, root.swapFormData.toTokenKey)
            compare(receivePanel.value, 0)
            compare(receivePanel.rawValue, "0")
        }
        // end helper functions -------------------------------------------------------------

        function test_floating_header_default_account() {
            verify(!!controlUnderTest)
            /* using a for loop set different accounts as default index and
            check if the correct values are displayed in the floating header*/
            for (let i = 0; i< swapAdaptor.nonWatchAccounts.count; i++) {
                const nonWatchAccount = swapAdaptor.nonWatchAccounts.get(i)
                root.swapFormData.selectedAccountAddress = nonWatchAccount.address

                // Launch popup
                launchAndVerfyModal()

                const floatingHeaderBackground = findChild(controlUnderTest, "headerBackground")
                verify(!!floatingHeaderBackground)
                compare(floatingHeaderBackground.color.toString().toUpperCase(), Utils.getColorForId(nonWatchAccount.colorId).toString().toUpperCase())

                const headerContentItemText = findChild(controlUnderTest, "textContent")
                verify(!!headerContentItemText)
                compare(headerContentItemText.text, nonWatchAccount.name)

                const headerContentItemEmoji = findChild(controlUnderTest, "assetContent")
                verify(!!headerContentItemEmoji)
                compare(headerContentItemEmoji.asset.emoji, nonWatchAccount.emoji)
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
            skip("Randomly failing")
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
                    verify(comboBoxList.itemAtIndex(i+1).model.position > delegateUnderTest.model.position)
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
                // compare(walletAccountTypeIcon.icon, swapAdaptor.nonWatchAccounts.get(i).walletType === Constants.watchWalletType ? "show" : delegateUnderTest.model.migratedToKeycard ? "keycard": "")

                // Hover over the item and check hovered state
                mouseMove(delegateUnderTest, delegateUnderTest.width/2, delegateUnderTest.height/2)
                verify(delegateUnderTest.sensor.containsMouse)
                compare(delegateUnderTest.title, swapAdaptor.nonWatchAccounts.get(i).name)
                compare(delegateUnderTest.subTitle, WalletUtils.colorizedChainPrefix(root.swapAdaptor.getNetworkShortNames(swapAdaptor.nonWatchAccounts.get(i).preferredSharingChainIds)), "Randomly failing locally. Add a bug if you see this failing in CI")
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
                verify(!delegateUnderTest.model.accountBalance)
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
                verify(!!delegateUnderTest.model.fromToken)
                verify(!!delegateUnderTest.model.accountBalance)
                compare(delegateUnderTest.inlineTagModel, 1)

                const inlineTagDelegate_0 = findChild(delegateUnderTest, "inlineTagDelegate_0")
                verify(!!inlineTagDelegate_0)

                compare(inlineTagDelegate_0.asset.name, Style.svg("tiny/%1".arg(delegateUnderTest.model.accountBalance.iconUrl)))
                compare(inlineTagDelegate_0.asset.color.toString().toUpperCase(), delegateUnderTest.model.accountBalance.chainColor.toString().toUpperCase())
                compare(inlineTagDelegate_0.titleText.color, delegateUnderTest.model.accountBalance.balance === "0" ? Theme.palette.baseColor1 : Theme.palette.directColor1)

                let bigIntBalance = SQUtils.AmountsArithmetic.toNumber(delegateUnderTest.model.accountBalance.balance, delegateUnderTest.model.fromToken.decimals)
                compare(inlineTagDelegate_0.title, root.swapAdaptor.formatCurrencyAmount(bigIntBalance, delegateUnderTest.model.fromToken.symbol))
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
                compare(root.swapFormData.selectedAccountAddress, swapAdaptor.nonWatchAccounts.get(i).address)

                // The comboBox item should  reflect chosen account
                const floatingHeaderBackground = findChild(accountsModalHeader, "headerBackground")
                verify(!!floatingHeaderBackground)
                compare(floatingHeaderBackground.color.toString().toUpperCase(), swapAdaptor.nonWatchAccounts.get(i).color.toString().toUpperCase())

                const headerContentItemText = findChild(accountsModalHeader, "textContent")
                verify(!!headerContentItemText)
                compare(headerContentItemText.text, swapAdaptor.nonWatchAccounts.get(i).name)

                const headerContentItemEmoji = findChild(accountsModalHeader, "assetContent")
                verify(!!headerContentItemEmoji)
                compare(headerContentItemEmoji.asset.emoji, swapAdaptor.nonWatchAccounts.get(i).emoji)
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
                    let filteredBalances = SQUtils.ModelUtils.modelToArray(balancesModel).filter(balances => balances.chainId === root.swapFormData.selectedNetworkChainId).filter(balances => balances.account === accountDelegateUnderTest.model.address)
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
            skip("Randomly failing")
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

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)

            const receivePanel = findChild(controlUnderTest, "receivePanel")
            verify(!!receivePanel)

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
            root.swapFormData.fromTokenAmount = "0.001"
            compare(formValuesChanged.count, 3)
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            compare(formValuesChanged.count, 4)
            root.swapFormData.selectedAccountAddress = root.swapAdaptor.nonWatchAccounts.get(0).address
            compare(formValuesChanged.count, 5)

            // wait for fetchSuggestedRoutes function to be called
            wait(1000)

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event that no routes were found
            root.swapStore.suggestedRoutesReady(root.dummySwapTransactionRoutes.txNoRoutes)

            // verify loading state was removed and that error was displayed
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.totalFees, 0)
            compare(root.swapAdaptor.swapOutputData.bestRoutes, [])
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, true)
            verify(errorTag.visible)
            verify(errorTag.text, qsTr("An error has occured, please try again"))
            verify(!signButton.enabled)
            compare(signButton.text, qsTr("Swap"))

            // verfy input and output panels
            verify(!payPanel.mainInputLoading)
            verify(!payPanel.bottomTextLoading)
            verify(!receivePanel.mainInputLoading)
            verify(!receivePanel.bottomTextLoading)
            verify(!receivePanel.interactive)
            compare(receivePanel.selectedHoldingId, root.swapFormData.toTokenKey)
            compare(receivePanel.value, 0)
            compare(receivePanel.rawValue, "0")

            // edit some params to retry swap
            root.swapFormData.fromTokenAmount = "0.00011"
            compare(formValuesChanged.count, 6)

            // wait for fetchSuggestedRoutes function to be called
            wait(1000)

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event with route that needs no approval
            let txRoutes = root.dummySwapTransactionRoutes.txHasRouteNoApproval
            root.swapStore.suggestedRoutesReady(txRoutes)

            // verify loading state removed and data is displayed as expected on the Modal
            verify(root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
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

            // verfy input and output panels
            waitForRendering(receivePanel)
            verify(payPanel.valueValid)
            verify(!receivePanel.mainInputLoading)
            verify(!receivePanel.bottomTextLoading)
            verify(!receivePanel.interactive)
            compare(receivePanel.selectedHoldingId, root.swapFormData.toTokenKey)
            compare(receivePanel.value, root.swapStore.getWei2Eth(txRoutes.amountToReceive, root.swapAdaptor.toToken.decimals))
            compare(receivePanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(root.swapAdaptor.swapOutputData.toTokenAmount, root.swapAdaptor.toToken.decimals).toString())

            // edit some params to retry swap
            root.swapFormData.fromTokenAmount = "0.012"
            compare(formValuesChanged.count, 7)

            // wait for fetchSuggestedRoutes function to be called
            wait(1000)

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event with route that needs no approval
            let txRoutes2 = root.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded
            root.swapStore.suggestedRoutesReady(txRoutes2)

            // verify loading state removed and data ius displayed as expected on the Modal
            verify(root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
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

            // verfy input and output panels
            waitForRendering(receivePanel)
            verify(payPanel.valueValid)
            verify(!receivePanel.mainInputLoading)
            verify(!receivePanel.bottomTextLoading)
            verify(!receivePanel.interactive)
            compare(receivePanel.selectedHoldingId, root.swapFormData.toTokenKey)
            compare(receivePanel.value, root.swapStore.getWei2Eth(txRoutes.amountToReceive, root.swapAdaptor.toToken.decimals))
            compare(receivePanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(root.swapAdaptor.swapOutputData.toTokenAmount, root.swapAdaptor.toToken.decimals).toString())
        }

        function test_modal_pay_input_default() {
            // Launch popup
            launchAndVerfyModal()

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!bottomItemText)
            const holdingSelector = findChild(payPanel, "holdingSelector")
            verify(!!holdingSelector)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const holdingSelectorsContentItemText = findChild(payPanel, "holdingSelectorsContentItemText")
            verify(!!holdingSelectorsContentItemText)
            const holdingSelectorsTokenIcon = findChild(payPanel, "holdingSelectorsTokenIcon")
            verify(!!holdingSelectorsTokenIcon)

            waitForRendering(payPanel)

            // check default states for the from input selector
            compare(amountToSendInput.caption, qsTr("Pay"))
            verify(amountToSendInput.interactive)
            compare(amountToSendInput.input.text, "")
            verify(amountToSendInput.input.input.edit.cursorVisible)
            compare(amountToSendInput.input.placeholderText, LocaleUtils.numberToLocaleString(0))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(0, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.selectedItem, undefined)
            compare(holdingSelectorsContentItemText.text, qsTr("Select asset"))
            compare(holdingSelectorsTokenIcon.image.source, "")
            verify(!holdingSelectorsTokenIcon.visible)
            verify(!maxTagButton.visible)
            compare(payPanel.selectedHoldingId, "")
            compare(payPanel.value, 0)
            compare(payPanel.rawValue, "0")
            verify(!payPanel.valueValid)

            closeAndVerfyModal()
        }

        function test_modal_pay_input_presetValues() {
            // try setting value before popup is launched and check values
            let valueToExchange = 0.001
            let valueToExchangeString = valueToExchange.toString()
            root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(0).address
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.fromTokenAmount = valueToExchangeString

            let expectedToken =  SQUtils.ModelUtils.getByKey(root.swapAdaptor.processedAssetsModel, "tokensKey", "ETH")

            // Launch popup
            launchAndVerfyModal()

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!bottomItemText)
            const holdingSelector = findChild(payPanel, "holdingSelector")
            verify(!!holdingSelector)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const holdingSelectorsContentItemText = findChild(payPanel, "holdingSelectorsContentItemText")
            verify(!!holdingSelectorsContentItemText)
            const holdingSelectorsTokenIcon = findChild(payPanel, "holdingSelectorsTokenIcon")
            verify(!!holdingSelectorsTokenIcon)

            waitForRendering(payPanel)

            compare(amountToSendInput.caption, qsTr("Pay"))
            verify(amountToSendInput.interactive)
            compare(amountToSendInput.input.text, valueToExchangeString)
            compare(amountToSendInput.input.placeholderText, LocaleUtils.numberToLocaleString(0))
            verify(amountToSendInput.input.input.edit.cursorVisible)
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(valueToExchange * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.selectedItem, expectedToken)
            compare(holdingSelectorsContentItemText.text, expectedToken.symbol)
            compare(holdingSelectorsTokenIcon.image.source, Constants.tokenIcon(expectedToken.symbol))
            verify(holdingSelectorsTokenIcon.visible)
            verify(maxTagButton.visible)
            compare(maxTagButton.text, qsTr("Max. %1").arg(root.swapAdaptor.currencyStore.formatCurrencyAmount(Math.trunc(WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol)*100)/100, expectedToken.symbol, {noSymbol: true})))
            compare(payPanel.selectedHoldingId, expectedToken.symbol)
            compare(payPanel.value, valueToExchange)
            compare(payPanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(valueToExchangeString, expectedToken.decimals).toString())
            verify(payPanel.valueValid)

            closeAndVerfyModal()
        }

        function test_modal_pay_input_wrong_value_1() {
            let invalidValues = ["ABC", "0.0.010201", "12PASA", "100,9.01"]
            for (let i =0; i<invalidValues.length; i++) {
                let invalidValue = invalidValues[i]
                // try setting value before popup is launched and check values
                root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(0).address
                root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
                root.swapFormData.fromTokensKey =
                        root.swapFormData.fromTokenAmount = invalidValue

                // Launch popup
                launchAndVerfyModal()

                const payPanel = findChild(controlUnderTest, "payPanel")
                verify(!!payPanel)
                const amountToSendInput = findChild(payPanel, "amountToSendInput")
                verify(!!amountToSendInput)
                const bottomItemText = findChild(payPanel, "bottomItemText")
                verify(!!bottomItemText)
                const holdingSelector = findChild(payPanel, "holdingSelector")
                verify(!!holdingSelector)
                const maxTagButton = findChild(payPanel, "maxTagButton")
                verify(!!maxTagButton)
                const holdingSelectorsContentItemText = findChild(payPanel, "holdingSelectorsContentItemText")
                verify(!!holdingSelectorsContentItemText)
                const holdingSelectorsTokenIcon = findChild(payPanel, "holdingSelectorsTokenIcon")
                verify(!!holdingSelectorsTokenIcon)

                waitForRendering(payPanel)

                compare(amountToSendInput.caption, qsTr("Pay"))
                verify(amountToSendInput.interactive)
                compare(amountToSendInput.input.placeholderText, LocaleUtils.numberToLocaleString(0))
                verify(amountToSendInput.input.input.edit.cursorVisible)
                compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(0, root.swapAdaptor.currencyStore.currentCurrency))
                compare(holdingSelector.selectedItem, null)
                compare(holdingSelectorsContentItemText.text, "")
                verify(!holdingSelectorsTokenIcon.visible)
                verify(!maxTagButton.visible)
                compare(payPanel.selectedHoldingId, invalidValue)
                compare(payPanel.value, 0)
                compare(payPanel.rawValue, SQUtils.AmountsArithmetic.fromNumber("0", 0).toString())
                verify(!payPanel.valueValid)

                closeAndVerfyModal()
            }
        }

        function test_modal_pay_input_wrong_value_2() {
            // try setting value before popup is launched and check values
            let valueToExchange = 100
            let valueToExchangeString = valueToExchange.toString()
            root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(0).address
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.fromTokenAmount = valueToExchangeString

            let expectedToken =  SQUtils.ModelUtils.getByKey(root.swapAdaptor.processedAssetsModel, "tokensKey", "ETH")

            // Launch popup
            launchAndVerfyModal()

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!bottomItemText)
            const holdingSelector = findChild(payPanel, "holdingSelector")
            verify(!!holdingSelector)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const holdingSelectorsContentItemText = findChild(payPanel, "holdingSelectorsContentItemText")
            verify(!!holdingSelectorsContentItemText)
            const holdingSelectorsTokenIcon = findChild(payPanel, "holdingSelectorsTokenIcon")
            verify(!!holdingSelectorsTokenIcon)

            waitForRendering(payPanel)

            compare(amountToSendInput.caption, qsTr("Pay"))
            verify(amountToSendInput.interactive)
            compare(amountToSendInput.input.text, valueToExchangeString)
            compare(amountToSendInput.input.placeholderText, LocaleUtils.numberToLocaleString(0))
            verify(amountToSendInput.input.input.edit.cursorVisible)
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(valueToExchange * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.selectedItem, expectedToken)
            compare(holdingSelectorsContentItemText.text, expectedToken.symbol)
            compare(holdingSelectorsTokenIcon.image.source, Constants.tokenIcon(expectedToken.symbol))
            verify(holdingSelectorsTokenIcon.visible)
            verify(maxTagButton.visible)
            compare(maxTagButton.text, qsTr("Max. %1").arg(root.swapAdaptor.currencyStore.formatCurrencyAmount(Math.trunc(WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol)*100)/100, expectedToken.symbol, {noSymbol: true})))
            compare(payPanel.selectedHoldingId, expectedToken.symbol)
            compare(payPanel.value, valueToExchange)
            compare(payPanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(valueToExchangeString, expectedToken.decimals).toString())
            verify(!payPanel.valueValid)

            closeAndVerfyModal()
        }

        function test_modal_pay_input_switching_networks() {
            // try setting value before popup is launched and check values
            root.swapFormData.resetFormData()
            let valueToExchange = 0.3
            let valueToExchangeString = valueToExchange.toString()
            root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(0).address
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.fromTokenAmount = valueToExchangeString

            // Launch popup
            launchAndVerfyModal()

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)

            for (let i=0; i< root.swapAdaptor.filteredFlatNetworksModel.count; i++) {
                root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(i).chainId
                waitForRendering(payPanel)
                let expectedToken =  SQUtils.ModelUtils.getByKey(root.swapAdaptor.processedAssetsModel, "tokensKey", "ETH")

                // check states for the pay input selector
                verify(maxTagButton.visible)
                let maxPossibleValue = Math.trunc(WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol)*100)/100
                compare(maxTagButton.text, qsTr("Max. %1").arg(root.swapAdaptor.currencyStore.formatCurrencyAmount(maxPossibleValue, expectedToken.symbol, {noSymbol: true})))
                compare(payPanel.selectedHoldingId, expectedToken.symbol)
                compare(payPanel.valueValid, valueToExchange <= maxPossibleValue)
                compare(payPanel.value, valueToExchange)
                compare(payPanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(valueToExchangeString, expectedToken.decimals).toString())
            }

            closeAndVerfyModal()
        }

        function test_modal_receive_input_default() {
            // Launch popup
            launchAndVerfyModal()

            const receivePanel = findChild(controlUnderTest, "receivePanel")
            verify(!!receivePanel)
            const amountToSendInput = findChild(receivePanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(receivePanel, "bottomItemText")
            verify(!!bottomItemText)
            const holdingSelector = findChild(receivePanel, "holdingSelector")
            verify(!!holdingSelector)
            const maxTagButton = findChild(receivePanel, "maxTagButton")
            verify(!!maxTagButton)
            const holdingSelectorsContentItemText = findChild(receivePanel, "holdingSelectorsContentItemText")
            verify(!!holdingSelectorsContentItemText)

            // check default states for the from input selector
            compare(amountToSendInput.caption, qsTr("Receive"))
            compare(amountToSendInput.input.text, "")
            // TODO: this should be come interactive under https://github.com/status-im/status-desktop/issues/15095
            verify(!amountToSendInput.interactive)
            verify(!amountToSendInput.input.input.edit.cursorVisible)
            compare(amountToSendInput.input.placeholderText, LocaleUtils.numberToLocaleString(0))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(0, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.selectedItem, undefined)
            compare(holdingSelectorsContentItemText.text, qsTr("Select asset"))
            verify(!maxTagButton.visible)
            compare(receivePanel.selectedHoldingId, "")
            compare(receivePanel.value, 0)
            compare(receivePanel.rawValue, "0")
            verify(!receivePanel.valueValid)

            closeAndVerfyModal()
        }

        function test_modal_receive_input_presetValues() {
            let valueToReceive = 0.001
            let valueToReceiveString = valueToReceive.toString()
            // try setting value before popup is launched and check values
            root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(0).address
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.toTokenKey = "STT"
            root.swapFormData.toTokenAmount = valueToReceiveString

            let expectedToken =  SQUtils.ModelUtils.getByKey(root.swapAdaptor.processedAssetsModel, "tokensKey", "STT")

            // Launch popup
            launchAndVerfyModal()

            const receivePanel = findChild(controlUnderTest, "receivePanel")
            verify(!!receivePanel)
            const amountToSendInput = findChild(receivePanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(receivePanel, "bottomItemText")
            verify(!!bottomItemText)
            const holdingSelector = findChild(receivePanel, "holdingSelector")
            verify(!!holdingSelector)
            const maxTagButton = findChild(receivePanel, "maxTagButton")
            verify(!!maxTagButton)
            const holdingSelectorsContentItemText = findChild(receivePanel, "holdingSelectorsContentItemText")
            verify(!!holdingSelectorsContentItemText)
            const holdingSelectorsTokenIcon = findChild(receivePanel, "holdingSelectorsTokenIcon")
            verify(!!holdingSelectorsTokenIcon)

            waitForRendering(receivePanel)

            compare(amountToSendInput.caption, qsTr("Receive"))
            // TODO: this should be come interactive under https://github.com/status-im/status-desktop/issues/15095
            verify(!amountToSendInput.interactive)
            verify(!amountToSendInput.input.input.edit.cursorVisible)
            compare(amountToSendInput.input.text, valueToReceive.toLocaleString(Qt.locale(), 'f', -128))
            compare(amountToSendInput.input.placeholderText, LocaleUtils.numberToLocaleString(0))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(valueToReceive * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.selectedItem, expectedToken)
            compare(holdingSelectorsContentItemText.text, expectedToken.symbol)
            compare(holdingSelectorsTokenIcon.image.source, Constants.tokenIcon(expectedToken.symbol))
            verify(holdingSelectorsTokenIcon.visible)
            verify(!maxTagButton.visible)
            compare(receivePanel.selectedHoldingId, expectedToken.symbol)
            compare(receivePanel.value, valueToReceive)
            compare(receivePanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(valueToReceiveString, expectedToken.decimals).toString())
            verify(receivePanel.valueValid)

            closeAndVerfyModal()
        }

        function test_modal_max_button_click_with_preset_pay_value() {
            // Launch popup
            launchAndVerfyModal()
            // The default is the first account. Setting the second account to test switching accounts
            root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(1).address
            formValuesChanged.clear()

            // try setting value before popup is launched and check values
            let valueToExchange = 0.2
            let valueToExchangeString = valueToExchange.toString()
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(0).address
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.fromTokenAmount = valueToExchangeString
            root.swapFormData.toTokenKey = "STT"

            compare(formValuesChanged.count, 5)

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!bottomItemText)

            waitForRendering(payPanel)

            let expectedToken =  SQUtils.ModelUtils.getByKey(root.swapAdaptor.processedAssetsModel, "tokensKey", "ETH")

            // check states for the pay input selector
            verify(maxTagButton.visible)
            let maxPossibleValue = WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol)
            let truncmaxPossibleValue = Math.trunc(maxPossibleValue*100)/100
            compare(maxTagButton.text, qsTr("Max. %1").arg(root.swapAdaptor.currencyStore.formatCurrencyAmount(truncmaxPossibleValue, expectedToken.symbol, {noSymbol: true})))
            verify(amountToSendInput.interactive)
            verify(amountToSendInput.input.input.edit.cursorVisible)
            compare(amountToSendInput.input.text, valueToExchange.toLocaleString(Qt.locale(), 'f', -128))
            compare(amountToSendInput.input.placeholderText, LocaleUtils.numberToLocaleString(0))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(valueToExchange * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))

            // click on max button
            maxTagButton.clicked()
            waitForRendering(payPanel)

            compare(formValuesChanged.count, 6)

            verify(amountToSendInput.interactive)
            verify(amountToSendInput.input.input.edit.cursorVisible)
            compare(amountToSendInput.input.text, maxPossibleValue.toLocaleString(Qt.locale(), 'f', -128))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(maxPossibleValue * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))

            closeAndVerfyModal()
        }

        function test_modal_max_button_click_with_no_preset_pay_value() {
            // Launch popup
            launchAndVerfyModal()
            // The default is the first account. Setting the second account to test switching accounts
            root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(1).address
            formValuesChanged.clear()
            
            // try setting value before popup is launched and check values
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(0).address
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.toTokenKey = "STT"

            compare(formValuesChanged.count, 4)

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!bottomItemText)

            waitForRendering(payPanel)

            let expectedToken =  SQUtils.ModelUtils.getByKey(root.swapAdaptor.processedAssetsModel, "tokensKey", "ETH")

            // check states for the pay input selector
            verify(maxTagButton.visible)
            let maxPossibleValue = WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol)
            let truncmaxPossibleValue = Math.trunc(maxPossibleValue*100)/100
            compare(maxTagButton.text, qsTr("Max. %1").arg(root.swapAdaptor.currencyStore.formatCurrencyAmount(truncmaxPossibleValue, expectedToken.symbol, {noSymbol: true})))
            verify(amountToSendInput.interactive)
            verify(amountToSendInput.input.input.edit.cursorVisible)
            compare(amountToSendInput.input.text, "")
            compare(amountToSendInput.input.placeholderText, LocaleUtils.numberToLocaleString(0))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(0, root.swapAdaptor.currencyStore.currentCurrency))

            // click on max button
            maxTagButton.clicked()
            waitForRendering(payPanel)

            compare(formValuesChanged.count, 5)

            verify(amountToSendInput.interactive)
            verify(amountToSendInput.input.input.edit.cursorVisible)
            compare(amountToSendInput.input.text, maxPossibleValue.toLocaleString(Qt.locale(), 'f', -128))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(maxPossibleValue * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))

            closeAndVerfyModal()
        }

        function test_modal_pay_input_switching_accounts() {
            // test with pay value being set and not set
            let payValuesToTestWith = ["", "0.2"]

            for (let index = 0; index < payValuesToTestWith.length; index ++) {
                let valueToExchangeString = payValuesToTestWith[index]
                let valueToExchange = Number(valueToExchangeString)

                // Asset chosen but no pay value set state -------------------------------------------------------------------------------
                root.swapFormData.fromTokenAmount = valueToExchangeString
                root.swapFormData.selectedAccountAddress = swapAdaptor.nonWatchAccounts.get(0).address
                root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
                root.swapFormData.fromTokensKey = "ETH"

                // Launch popup
                launchAndVerfyModal()

                const payPanel = findChild(controlUnderTest, "payPanel")
                verify(!!payPanel)
                const maxTagButton = findChild(payPanel, "maxTagButton")
                verify(!!maxTagButton)
                const amountToSendInput = findChild(payPanel, "amountToSendInput")
                verify(!!amountToSendInput)

                const errorTag = findChild(controlUnderTest, "errorTag")
                verify(!!errorTag)

                for (let i=0; i< root.swapAdaptor.nonWatchAccounts.count; i++) {
                    root.swapFormData.selectedAccountAddress = root.swapAdaptor.nonWatchAccounts.get(i).address

                    let expectedToken =  SQUtils.ModelUtils.getByKey(root.swapAdaptor.processedAssetsModel, "tokensKey", "ETH")

                    waitForRendering(payPanel)

                    // check states for the pay input selector
                    verify(maxTagButton.visible)
                    let maxPossibleValue = Math.trunc(WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol)*100)/100
                    compare(maxTagButton.text, qsTr("Max. %1").arg(maxPossibleValue === 0 ? Qt.locale().zeroDigit : root.swapAdaptor.currencyStore.formatCurrencyAmount(maxPossibleValue, expectedToken.symbol, {noSymbol: true, minDecimals: 0})))
                    compare(payPanel.selectedHoldingId, expectedToken.symbol)
                    compare(payPanel.valueValid, !!root.swapFormData.fromTokenAmount && valueToExchange <= maxPossibleValue)

                    compare(payPanel.value, valueToExchange)
                    compare(payPanel.rawValue, !!valueToExchangeString ? SQUtils.AmountsArithmetic.fromNumber(valueToExchangeString, expectedToken.decimals).toString(): "0")

                    // check if tag is visible in case amount entered to exchange is greater than max balance to send
                    let amountEnteredGreaterThanMaxBalance = valueToExchange > maxPossibleValue
                    let errortext = amountEnteredGreaterThanMaxBalance ? qsTr("Insufficient funds for swap"): qsTr("An error has occured, please try again")
                    compare(errorTag.visible, amountEnteredGreaterThanMaxBalance)
                    compare(errorTag.text, errortext)
                    compare(errorTag.buttonText, qsTr("Buy crypto"))
                    compare(errorTag.buttonVisible, amountEnteredGreaterThanMaxBalance)
                }

                closeAndVerfyModal()
            }
        }
    }
}
