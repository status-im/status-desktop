import QtQuick 2.15
import QtTest 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import QtQuick.Controls 2.15

import Models 1.0
import Storybook 1.0

import utils 1.0
import shared.stores 1.0
import AppLayouts.Wallet.popups.swap 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.adaptors 1.0

Item {
    id: root
    width: 800
    height: 600

    readonly property var dummySwapTransactionRoutes: SwapTransactionRoutes {}

    readonly property var swapStore: SwapStore {
        signal suggestedRoutesReady(var txRoutes, string errCode, string errDescription)
        signal transactionSent(var chainId,var txHash, var uuid, var error)
        signal transactionSendingComplete(var txHash,  var status)

        readonly property var accounts: WalletAccountsModel {}
        readonly property var flatNetworks: NetworksModel.flatNetworks
        readonly property bool areTestNetworksEnabled: true
        function getWei2Eth(wei, decimals) {
            return wei/(10**decimals)
        }
        function fetchSuggestedRoutes(uuid, accountFrom, accountTo, amount, tokenFrom, tokenTo,
                                      disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts) {
                    swapStore.fetchSuggestedRoutesCalled()
        }
        function authenticateAndTransfer(uuid, accountFrom, accountTo, tokenFrom,
                                         tokenTo, sendType, tokenName, tokenIsOwnerToken, paths) {}
        function stopUpdatesForSuggestedRoute() {}
        // local signals for testing function calls
        signal fetchSuggestedRoutesCalled()
    }

    readonly property SwapModalAdaptor swapAdaptor: SwapModalAdaptor {
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

    property SwapInputParamsForm swapFormData: SwapInputParamsForm {}

    Component {
        id: componentUnderTest
        SwapModal {
            swapInputParamsForm: root.swapFormData
            swapAdaptor: root.swapAdaptor
            loginType: Constants.LoginType.Password
        }
    }

    SignalSpy {
        id: formValuesChanged
        target: root.swapFormData
        signalName: "formValuesChanged"
    }

    SignalSpy {
        id: fetchSuggestedRoutesCalled
        target: root.swapStore
        signalName: "fetchSuggestedRoutesCalled"
    }

    TestCase {
        name: "SwapModal"
        when: windowShown

        property SwapModal controlUnderTest: null

        // helper functions -------------------------------------------------------------

        function init() {
            swapAdaptor.swapFormData = root.swapFormData
            controlUnderTest = createTemporaryObject(componentUnderTest, root, { swapInputParamsForm: root.swapFormData})
        }

        function cleanup() {
            root.swapAdaptor.reset()
            root.swapFormData.resetFormData()
            formValuesChanged.clear()
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
            root.swapAdaptor.reset()
            root.swapFormData.resetFormData()
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
            waitForRendering(accountsModalHeader, 200)
            verify(!!accountsModalHeader.control.popup.opened)
            mouseMove(accountsModalHeader)
            return accountsModalHeader
        }

        function verifyLoadingAndNoErrorsState(payPanel, receivePanel) {
            // verify loading state was set and no errors currently
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.rawPaths, [])
            compare(root.swapAdaptor.swapOutputData.hasError, false)

            // verfy input and output panels
            verify(!payPanel.mainInputLoading)
            verify(payPanel.bottomTextLoading)
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
            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model
            /* using a for loop set different accounts as default index and
            check if the correct values are displayed in the floating header*/
            for (let i = 0; i< walletAccounts.count; i++) {
                const accountToTest = walletAccounts.get(i)
                root.swapFormData.selectedAccountAddress = accountToTest.address

                // Launch popup
                launchAndVerfyModal()

                const floatingHeaderBackground = findChild(controlUnderTest, "headerBackground")
                verify(!!floatingHeaderBackground)
                compare(floatingHeaderBackground.color.toString().toUpperCase(), Utils.getColorForId(accountToTest.colorId).toString().toUpperCase())

                const headerContentItemText = findChild(controlUnderTest, "textContent")
                verify(!!headerContentItemText)
                compare(headerContentItemText.text, accountToTest.name)

                const headerContentItemEmoji = findChild(controlUnderTest, "assetContent")
                verify(!!headerContentItemEmoji)
                compare(headerContentItemEmoji.asset.emoji, accountToTest.emoji)
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
            let walletAccounts = accountsModalHeader.model

            const comboBoxList = findChild(controlUnderTest, "accountSelectorList")
            verify(!!comboBoxList)
            waitForRendering(comboBoxList)

            for(let i =0; i< comboBoxList.model.count; i++) {
                let delegateUnderTest = comboBoxList.itemAtIndex(i)
                let accountToBeTested = walletAccounts.get(i)
                let elidedAddress = SQUtils.Utils.elideAndFormatWalletAddress(accountToBeTested.address)
                compare(delegateUnderTest.title, accountToBeTested.name)
                compare(delegateUnderTest.subTitle, elidedAddress)
                compare(delegateUnderTest.asset.color.toString().toUpperCase(), accountToBeTested.color.toString().toUpperCase())
                compare(delegateUnderTest.asset.emoji, accountToBeTested.emoji)

                const walletAccountCurrencyBalance = findChild(delegateUnderTest, "walletAccountCurrencyBalance")
                verify(!!walletAccountCurrencyBalance)
                verify(walletAccountCurrencyBalance.text, LocaleUtils.currencyAmountToLocaleString(accountToBeTested.currencyBalance))

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
                // compare(walletAccountTypeIcon.icon, accountToBeTested.walletType === Constants.watchWalletType ? "show" : delegateUnderTest.model.migratedToKeycard ? "keycard": "")

                // Hover over the item and check hovered state
                mouseMove(delegateUnderTest, delegateUnderTest.width/2, delegateUnderTest.height/2)
                verify(delegateUnderTest.sensor.containsMouse)
                compare(delegateUnderTest.title, accountToBeTested.name)
                compare(delegateUnderTest.subTitle,  Utils.richColorText(elidedAddress, Theme.palette.directColor1))
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
                verify(!!delegateUnderTest.model.accountBalance)
                compare(delegateUnderTest.inlineTagModel, 1)

                const inlineTagDelegate_0 = findChild(delegateUnderTest, "inlineTagDelegate_0")
                verify(!!inlineTagDelegate_0)

                const balance = delegateUnderTest.model.accountBalance.balance

                compare(inlineTagDelegate_0.asset.name, Theme.svg("tiny/%1".arg(delegateUnderTest.model.accountBalance.iconUrl)))
                compare(inlineTagDelegate_0.asset.color.toString().toUpperCase(), delegateUnderTest.model.accountBalance.chainColor.toString().toUpperCase())
                compare(inlineTagDelegate_0.titleText.color, balance === "0" ? Theme.palette.baseColor1 : Theme.palette.directColor1)

                let bigIntBalance = SQUtils.AmountsArithmetic.toNumber(balance, controlUnderTest.swapAdaptor.fromToken.decimals)
                compare(inlineTagDelegate_0.title, balance === "0" ? "0 %1".arg(controlUnderTest.swapAdaptor.fromToken.symbol)
                                                                   : root.swapAdaptor.currencyStore.formatCurrencyAmount(bigIntBalance, controlUnderTest.swapAdaptor.fromToken.symbol))
            }

            closeAndVerfyModal()
        }

        function test_floating_header_selection() {
            // Launch popup
            launchAndVerfyModal()

            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            verify(amountToSendInput.cursorVisible)

            for(let i =0; i< walletAccounts.count; i++) {
                // launch account selection dropdown
                const accountsModalHeader = getAndVerifyAccountsModalHeader()
                launchAccountSelectionPopup(accountsModalHeader)

                const comboBoxList = findChild(accountsModalHeader, "accountSelectorList")
                verify(!!comboBoxList)

                let delegateUnderTest = comboBoxList.itemAtIndex(i)

                mouseClick(delegateUnderTest)
                waitForRendering(delegateUnderTest, 200)
                verify(accountsModalHeader.control.popup.closed)

                // The input params form's slected Index should be updated  as per this selection
                compare(root.swapFormData.selectedAccountAddress, walletAccounts.get(i).address)

                // The comboBox item should  reflect chosen account
                const floatingHeaderBackground = findChild(accountsModalHeader, "headerBackground")
                verify(!!floatingHeaderBackground)
                compare(floatingHeaderBackground.color.toString().toUpperCase(), walletAccounts.get(i).color.toString().toUpperCase())

                const headerContentItemText = findChild(accountsModalHeader, "textContent")
                verify(!!headerContentItemText)
                compare(headerContentItemText.text, walletAccounts.get(i).name)

                const headerContentItemEmoji = findChild(accountsModalHeader, "assetContent")
                verify(!!headerContentItemEmoji)
                compare(headerContentItemEmoji.asset.emoji, walletAccounts.get(i).emoji)

                waitForRendering(amountToSendInput, 200)

                verify(amountToSendInput.cursorVisible)
            }
            closeAndVerfyModal()
        }

        function test_network_default_and_selection() {
            // Launch popup
            launchAndVerfyModal()

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            verify(amountToSendInput.cursorVisible)

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

                    verify(amountToSendInput.cursorVisible)
                }
            }
            networkComboBox.control.popup.close()
            closeAndVerfyModal()
        }

        function test_network_and_account_header_items() {
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

                root.swapFormData.fromTokensKey = root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel.get(0).key

                // verify values in accouns modal header dropdown
                const accountsModalHeader = getAndVerifyAccountsModalHeader()
                launchAccountSelectionPopup(accountsModalHeader)

                const comboBoxList = findChild(accountsModalHeader, "accountSelectorList")
                verify(!!comboBoxList)

                for(let j =0; j< comboBoxList.model.count; j++) {
                    let accountDelegateUnderTest = comboBoxList.itemAtIndex(j)
                    verify(!!accountDelegateUnderTest)
                    waitForItemPolished(accountDelegateUnderTest)
                    const inlineTagDelegate_0 = findChild(accountDelegateUnderTest, "inlineTagDelegate_0")
                    verify(!!inlineTagDelegate_0)

                    compare(inlineTagDelegate_0.asset.name, Theme.svg("tiny/%1".arg(networkModelItem.iconUrl)))
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
                    compare(inlineTagDelegate_0.title, bigIntBalance === 0 ? "0 %1".arg(fromToken.symbol)
                                                                           : root.swapAdaptor.currencyStore.formatCurrencyAmount(bigIntBalance, fromToken.symbol))
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
            root.swapAdaptor.reset()

            // Launch popup
            launchAndVerfyModal()

            waitForItemPolished(controlUnderTest.contentItem)

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
            verify(!signButton.interactive)
            verify(!errorTag.visible)

            // set input values in the form correctly
            root.swapFormData.fromTokensKey = root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel.get(0).key
            formValuesChanged.wait()
            root.swapFormData.toTokenKey = root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel.get(1).key
            root.swapFormData.fromTokenAmount = "0.001"
            waitForRendering(receivePanel)
            formValuesChanged.wait()
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            formValuesChanged.wait()
            root.swapFormData.selectedAccountAddress = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            formValuesChanged.wait()

            // wait for fetchSuggestedRoutes function to be called
            fetchSuggestedRoutesCalled.wait()

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event that no routes were found with unknown error
            const txRoutes = root.dummySwapTransactionRoutes.txNoRoutes
            txRoutes.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txRoutes, "NO_ROUTES", "No routes found")

            // verify loading state was removed and that error was displayed
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.totalFees, 0)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, true)
            verify(errorTag.visible)
            verify(errorTag.text, qsTr("An error has occured, please try again"))
            verify(!signButton.interactive)
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
            waitForRendering(receivePanel)
            formValuesChanged.wait()

            // wait for fetchSuggestedRoutes function to be called
            fetchSuggestedRoutesCalled.wait()

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event that no routes were found due to not enough token balance
            txRoutes.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txRoutes, Constants.routerErrorCodes.router.errNotEnoughTokenBalance, "errNotEnoughTokenBalance")

            // verify loading state was removed and that error was displayed
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.totalFees, 0)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, true)
            verify(errorTag.visible)
            verify(errorTag.text, qsTr("Insufficient funds for swap"))
            verify(!signButton.interactive)
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
            root.swapFormData.fromTokenAmount = "0.00012"
            waitForRendering(receivePanel)
            formValuesChanged.wait()

            // wait for fetchSuggestedRoutes function to be called
            fetchSuggestedRoutesCalled.wait()

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event that no routes were found due to not enough eth balance
            txRoutes.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txRoutes, Constants.routerErrorCodes.router.errNotEnoughNativeBalance, "errNotEnoughNativeBalance")

            // verify loading state was removed and that error was displayed
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.totalFees, 0)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, true)
            verify(errorTag.visible)
            verify(errorTag.text, qsTr("Not enough ETH to pay gas fees"))
            verify(!signButton.interactive)
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
            root.swapFormData.fromTokenAmount = "0.00013"
            waitForRendering(receivePanel)
            formValuesChanged.wait()

            // wait for fetchSuggestedRoutes function to be called
            fetchSuggestedRoutesCalled.wait()

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event that no routes were found due to price timeout
            txRoutes.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txRoutes, Constants.routerErrorCodes.processor.errPriceTimeout, "errPriceTimeout")

            // verify loading state was removed and that error was displayed
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.totalFees, 0)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, true)
            verify(errorTag.visible)
            verify(errorTag.text, qsTr("Fetching the price took longer than expected. Please, try again later."))
            verify(!signButton.interactive)
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
            root.swapFormData.fromTokenAmount = "0.00014"
            waitForRendering(receivePanel)
            formValuesChanged.wait()

            // wait for fetchSuggestedRoutes function to be called
            fetchSuggestedRoutesCalled.wait()

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event that no routes were found due to not enough liquidity
            txRoutes.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txRoutes, Constants.routerErrorCodes.processor.errNotEnoughLiquidity, "errNotEnoughLiquidity")

            // verify loading state was removed and that error was displayed
            verify(!root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.totalFees, 0)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, true)
            verify(errorTag.visible)
            verify(errorTag.text, qsTr("Not enough liquidity. Lower token amount or try again later."))
            verify(!signButton.interactive)
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
            root.swapFormData.fromTokenAmount = "0.00015"
            waitForRendering(receivePanel)
            formValuesChanged.wait()
            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event with route that needs no approval
            const txHasRouteNoApproval = root.dummySwapTransactionRoutes.txHasRouteNoApproval
            txHasRouteNoApproval.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txHasRouteNoApproval, "", "")

            // verify loading state removed and data is displayed as expected on the Modal
            verify(root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount,
                    SQUtils.AmountsArithmetic.div(
                        SQUtils.AmountsArithmetic.fromString(txHasRouteNoApproval.amountToReceive),
                        SQUtils.AmountsArithmetic.fromNumber(1, root.swapAdaptor.toToken.decimals)
                        ).toString())

            // calculation needed for total fees
            let gasTimeEstimate = txHasRouteNoApproval.gasTimeEstimate
            let totalTokenFeesInFiat = gasTimeEstimate.totalTokenFees * root.swapAdaptor.fromToken.marketDetails.currencyPrice.amount
            let totalFees = root.swapAdaptor.currencyStore.getFiatValue(gasTimeEstimate.totalFeesInEth, Constants.ethToken) + totalTokenFeesInFiat

            compare(root.swapAdaptor.swapOutputData.totalFees, totalFees)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, false)
            compare(root.swapAdaptor.swapOutputData.hasError, false)
            verify(!errorTag.visible)
            verify(signButton.enabled)
            compare(signButton.text, qsTr("Swap"))

            // verfy input and output panels
            waitForRendering(receivePanel)
            verify(payPanel.valueValid)
            verify(!payPanel.mainInputLoading)
            verify(!payPanel.bottomTextLoading)
            verify(!receivePanel.mainInputLoading)
            verify(!receivePanel.bottomTextLoading)
            verify(!receivePanel.interactive)
            compare(receivePanel.selectedHoldingId, root.swapFormData.toTokenKey)
            compare(receivePanel.value, root.swapStore.getWei2Eth(txHasRouteNoApproval.amountToReceive, root.swapAdaptor.toToken.decimals))
            compare(receivePanel.rawValue,
                    SQUtils.AmountsArithmetic.times(
                        SQUtils.AmountsArithmetic.fromString(root.swapAdaptor.swapOutputData.toTokenAmount),
                        SQUtils.AmountsArithmetic.fromNumber(1, root.swapAdaptor.toToken.decimals)
                        ).toFixed())

            // edit some params to retry swap
            root.swapFormData.fromTokenAmount = "0.012"
            waitForRendering(receivePanel)
            formValuesChanged.wait()

            // wait for fetchSuggestedRoutes function to be called
            fetchSuggestedRoutesCalled.wait()

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event with route that needs no approval
            let txRoutes2 = root.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded
            txRoutes2.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txRoutes2, "", "")

            // verify loading state removed and data ius displayed as expected on the Modal
            verify(root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, SQUtils.AmountsArithmetic.div(
                        SQUtils.AmountsArithmetic.fromString(txRoutes2.amountToReceive),
                        SQUtils.AmountsArithmetic.fromNumber(1, root.swapAdaptor.toToken.decimals)).toString())

            // calculation needed for total fees
            gasTimeEstimate = txRoutes2.gasTimeEstimate
            totalTokenFeesInFiat = gasTimeEstimate.totalTokenFees * root.swapAdaptor.fromToken.marketDetails.currencyPrice.amount
            totalFees = root.swapAdaptor.currencyStore.getFiatValue(gasTimeEstimate.totalFeesInEth, Constants.ethToken) + totalTokenFeesInFiat

            compare(root.swapAdaptor.swapOutputData.totalFees, totalFees)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, true)
            compare(root.swapAdaptor.swapOutputData.hasError, false)
            verify(!errorTag.visible)
            verify(signButton.enabled)
            compare(signButton.text, qsTr("Approve %1").arg(root.swapAdaptor.fromToken.symbol))

            // verfy input and output panels
            waitForRendering(receivePanel)
            verify(payPanel.valueValid)
            verify(!payPanel.mainInputLoading)
            verify(!payPanel.bottomTextLoading)
            verify(!receivePanel.mainInputLoading)
            verify(!receivePanel.bottomTextLoading)
            verify(!receivePanel.interactive)
            compare(receivePanel.selectedHoldingId, root.swapFormData.toTokenKey)
            compare(receivePanel.value, root.swapStore.getWei2Eth(txRoutes2.amountToReceive, root.swapAdaptor.toToken.decimals))
            compare(receivePanel.rawValue,
                    SQUtils.AmountsArithmetic.times(
                        SQUtils.AmountsArithmetic.fromString(root.swapAdaptor.swapOutputData.toTokenAmount),
                        SQUtils.AmountsArithmetic.fromNumber(1, root.swapAdaptor.toToken.decimals)
                        ).toFixed())
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
            const tokenSelectorContentItemText = findChild(payPanel, "tokenSelectorContentItemText")
            verify(!!tokenSelectorContentItemText)

            waitForRendering(controlUnderTest.contentItem)

            // check default states for the from input selector
            compare(amountToSendInput.caption, qsTr("Pay"))
            verify(amountToSendInput.interactive)
            compare(amountToSendInput.text, "")
            verify(amountToSendInput.cursorVisible)
            compare(amountToSendInput.placeholderText, LocaleUtils.numberToLocaleString(0))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(0, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.currentTokensKey, Constants.swap.usdtTokenKey)
            compare(tokenSelectorContentItemText.text, Constants.swap.usdtTokenKey)
            verify(maxTagButton.visible)
            compare(payPanel.selectedHoldingId, Constants.swap.usdtTokenKey)
            compare(payPanel.value, 0)
            compare(payPanel.rawValue, "0")
            verify(!payPanel.valueValid)

            closeAndVerfyModal()
        }

        function test_modal_pay_input_presetValues() {
            // try setting value before popup is launched and check values
            let valueToExchange = 0.001
            let valueToExchangeString = valueToExchange.toString()

            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model

            root.swapFormData.selectedAccountAddress = walletAccounts.get(0).address
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.fromTokenAmount = valueToExchangeString

            // Launch popup
            launchAndVerfyModal()

            waitForItemPolished(controlUnderTest.contentItem)

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            waitForRendering(payPanel)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!bottomItemText)
            const holdingSelector = findChild(payPanel, "holdingSelector")
            verify(!!holdingSelector)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const tokenSelectorContentItemText = findChild(payPanel, "tokenSelectorContentItemText")
            verify(!!tokenSelectorContentItemText)
            const tokenSelectorIcon = findChild(payPanel, "tokenSelectorIcon")
            verify(!!tokenSelectorIcon)
            const payTokenModel = findChild(payPanel, "TokenSelectorViewAdaptor_outputAssetsModel")
            verify(!!payTokenModel)

            const expectedToken = SQUtils.ModelUtils.getByKey(payTokenModel, "tokensKey", "ETH")

            compare(amountToSendInput.caption, qsTr("Pay"))
            verify(amountToSendInput.interactive)
            tryCompare(amountToSendInput, "text", valueToExchangeString)
            compare(amountToSendInput.placeholderText, LocaleUtils.numberToLocaleString(0))
            tryCompare(amountToSendInput, "cursorVisible", true)
            tryCompare(bottomItemText, "text", root.swapAdaptor.currencyStore.formatCurrencyAmount(valueToExchange * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.currentTokensKey, expectedToken.tokensKey)
            tryCompare(tokenSelectorContentItemText, "text", expectedToken.symbol)
            compare(tokenSelectorIcon.image.source, Constants.tokenIcon(expectedToken.symbol))
            verify(tokenSelectorIcon.visible)
            verify(maxTagButton.visible)
            compare(maxTagButton.text, qsTr("Max. %1").arg(!expectedToken.currentBalance ? "0"
                                                                                              : root.swapAdaptor.currencyStore.formatCurrencyAmount(WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol), expectedToken.symbol, {noSymbol: true, roundingMode: LocaleUtils.RoundingMode.Down})))
            compare(payPanel.selectedHoldingId, expectedToken.symbol)
            compare(payPanel.value, valueToExchange)
            compare(payPanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(valueToExchangeString, expectedToken.decimals).toString())
            tryCompare(payPanel, "valueValid", expectedToken.currentBalance > 0)

            closeAndVerfyModal()
        }

        function test_modal_pay_input_wrong_value_1() {
            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model

            let invalidValues = ["ABC", "0.0.010201", "12PASA", "100,9.01"]
            for (let i =0; i<invalidValues.length; i++) {
                let invalidValue = invalidValues[i]
                // try setting value before popup is launched and check values
                root.swapFormData.selectedAccountAddress = walletAccounts.get(0).address
                root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
                root.swapFormData.fromTokensKey = invalidValue
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

                waitForRendering(payPanel)

                compare(amountToSendInput.caption, qsTr("Pay"))
                verify(amountToSendInput.interactive)
                compare(amountToSendInput.placeholderText, LocaleUtils.numberToLocaleString(0))
                verify(amountToSendInput.cursorVisible)
                compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(0, root.swapAdaptor.currencyStore.currentCurrency))
                compare(holdingSelector.currentTokensKey, "")
                const tokenSelectorContentItemText = findChild(payPanel, "tokenSelectorContentItemText")
                verify(!!tokenSelectorContentItemText)
                compare(tokenSelectorContentItemText.text, "Select asset")
                verify(!maxTagButton.visible)
                compare(payPanel.selectedHoldingId, "")
                compare(payPanel.value, 0)
                compare(payPanel.rawValue, SQUtils.AmountsArithmetic.fromNumber("0", 0).toString())
                verify(!payPanel.valueValid)

                closeAndVerfyModal()
            }
        }

        function test_modal_pay_input_wrong_value_2() {
            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model

            // try setting value before popup is launched and check values
            let valueToExchange = 100
            let valueToExchangeString = valueToExchange.toString()
            root.swapFormData.selectedAccountAddress = walletAccounts.get(0).address
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.fromTokenAmount = valueToExchangeString

            // Launch popup
            launchAndVerfyModal()

            waitForItemPolished(controlUnderTest.contentItem)

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            waitForRendering(payPanel)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!bottomItemText)
            const holdingSelector = findChild(payPanel, "holdingSelector")
            verify(!!holdingSelector)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const tokenSelectorContentItemText = findChild(payPanel, "tokenSelectorContentItemText")
            verify(!!tokenSelectorContentItemText)
            const tokenSelectorIcon = findChild(payPanel, "tokenSelectorIcon")
            verify(!!tokenSelectorIcon)
            const payTokenModel = findChild(payPanel, "TokenSelectorViewAdaptor_outputAssetsModel")
            verify(!!payTokenModel)
            const expectedToken = SQUtils.ModelUtils.getByKey(payTokenModel, "tokensKey", "ETH")

            compare(amountToSendInput.caption, qsTr("Pay"))
            verify(amountToSendInput.interactive)
            compare(amountToSendInput.text, valueToExchangeString)
            compare(amountToSendInput.placeholderText, LocaleUtils.numberToLocaleString(0))
            tryCompare(amountToSendInput, "cursorVisible", true)
            tryCompare(bottomItemText, "text", root.swapAdaptor.currencyStore.formatCurrencyAmount(valueToExchange * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.currentTokensKey, expectedToken.tokensKey)
            compare(tokenSelectorContentItemText.text, expectedToken.symbol)
            compare(tokenSelectorIcon.image.source, Constants.tokenIcon(expectedToken.symbol))
            verify(tokenSelectorIcon.visible)
            verify(maxTagButton.visible)
            compare(maxTagButton.text, qsTr("Max. %1").arg(!expectedToken.currentBalance ? "0"
                                                                                              : root.swapAdaptor.currencyStore.formatCurrencyAmount(WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol), expectedToken.symbol, {noSymbol: true, roundingMode: LocaleUtils.RoundingMode.Down})))
            compare(payPanel.selectedHoldingId, expectedToken.symbol)
            compare(payPanel.value, valueToExchange)
            compare(payPanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(valueToExchangeString, expectedToken.decimals).toString())
            verify(!payPanel.valueValid)

            closeAndVerfyModal()
        }

        function test_modal_receive_input_default() {
            // Launch popup
            launchAndVerfyModal()

            const receivePanel = findChild(controlUnderTest, "receivePanel")
            verify(!!receivePanel)
            waitForRendering(receivePanel)
            const amountToSendInput = findChild(receivePanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(receivePanel, "bottomItemText")
            verify(!!bottomItemText)
            const holdingSelector = findChild(receivePanel, "holdingSelector")
            verify(!!holdingSelector)
            const maxTagButton = findChild(receivePanel, "maxTagButton")
            verify(!!maxTagButton)
            const tokenSelectorContentItemText = findChild(receivePanel, "tokenSelectorContentItemText")
            verify(!!tokenSelectorContentItemText)

            // check default states for the from input selector
            compare(amountToSendInput.caption, qsTr("Receive"))
            compare(amountToSendInput.text, "")
            // TODO: this should be come interactive under https://github.com/status-im/status-desktop/issues/15095
            verify(!amountToSendInput.interactive)
            verify(!amountToSendInput.cursorVisible)
            compare(amountToSendInput.placeholderText, LocaleUtils.numberToLocaleString(0))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(0, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.currentTokensKey, Constants.swap.wethTokenKey)
            compare(tokenSelectorContentItemText.text, Constants.swap.wethTokenKey)
            verify(!maxTagButton.visible)
            compare(receivePanel.selectedHoldingId, Constants.swap.wethTokenKey)
            compare(receivePanel.value, 0)
            compare(receivePanel.rawValue, "0")
            verify(!receivePanel.valueValid)

            closeAndVerfyModal()
        }

        function test_modal_receive_input_presetValues() {
            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model

            let valueToReceive = 0.001
            let valueToReceiveString = valueToReceive.toString()
            // try setting value before popup is launched and check values
            root.swapFormData.selectedAccountAddress = walletAccounts.get(0).address
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.toTokenKey = "STT"
            root.swapFormData.toTokenAmount = valueToReceiveString

            // Launch popup
            launchAndVerfyModal()

            waitForItemPolished(controlUnderTest.contentItem)

            const receivePanel = findChild(controlUnderTest, "receivePanel")
            verify(!!receivePanel)
            waitForRendering(receivePanel)
            const amountToSendInput = findChild(receivePanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(receivePanel, "bottomItemText")
            verify(!!bottomItemText)
            const holdingSelector = findChild(receivePanel, "holdingSelector")
            verify(!!holdingSelector)
            const maxTagButton = findChild(receivePanel, "maxTagButton")
            verify(!!maxTagButton)
            const tokenSelectorContentItemText = findChild(receivePanel, "tokenSelectorContentItemText")
            verify(!!tokenSelectorContentItemText)
            const tokenSelectorIcon = findChild(receivePanel, "tokenSelectorIcon")
            verify(!!tokenSelectorIcon)
            const payTokenModel = findChild(receivePanel, "TokenSelectorViewAdaptor_outputAssetsModel")
            verify(!!payTokenModel)

            let expectedToken = SQUtils.ModelUtils.getByKey(payTokenModel, "tokensKey", "STT")

            compare(amountToSendInput.caption, qsTr("Receive"))
            // TODO: this should be come interactive under https://github.com/status-im/status-desktop/issues/15095
            verify(!amountToSendInput.interactive)
            verify(!amountToSendInput.cursorVisible)
            compare(amountToSendInput.text, valueToReceive.toLocaleString(Qt.locale(), 'f', -128))
            compare(amountToSendInput.placeholderText, LocaleUtils.numberToLocaleString(0))
            tryCompare(bottomItemText, "text", root.swapAdaptor.currencyStore.formatCurrencyAmount(valueToReceive * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))
            compare(holdingSelector.currentTokensKey, expectedToken.tokensKey)
            compare(tokenSelectorContentItemText.text, expectedToken.symbol)
            compare(tokenSelectorIcon.image.source, Constants.tokenIcon(expectedToken.symbol))
            verify(tokenSelectorIcon.visible)
            verify(!maxTagButton.visible)
            compare(receivePanel.selectedHoldingId, expectedToken.symbol)
            compare(receivePanel.value, valueToReceive)
            compare(receivePanel.rawValue, SQUtils.AmountsArithmetic.fromNumber(valueToReceiveString, expectedToken.decimals).toString())
            verify(receivePanel.valueValid)

            closeAndVerfyModal()
        }

        function test_modal_max_button_click_with_preset_pay_value() {
            // try setting value before popup is launched and check values
            let valueToExchange = 0.2
            let valueToExchangeString = valueToExchange.toString()
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            // The default is the first account. Setting the second account to test switching accounts
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.fromTokenAmount = valueToExchangeString
            root.swapFormData.toTokenKey = "STT"

            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model

            formValuesChanged.wait()

            // Launch popup
            launchAndVerfyModal()
            // The default is the first account. Setting the second account to test switching accounts
            root.swapFormData.selectedAccountAddress = walletAccounts.get(1).address

            waitForItemPolished(controlUnderTest.contentItem)

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!bottomItemText)
            const payTokenModel = findChild(payPanel, "TokenSelectorViewAdaptor_outputAssetsModel")
            verify(!!payTokenModel)

            let expectedToken =  SQUtils.ModelUtils.getByKey(payTokenModel, "tokensKey", "ETH")

            // check states for the pay input selector
            verify(maxTagButton.visible)
            // FIXME: maxTagButton should be enabled after #15709 is resolved
                verify(maxTagButton.enabled);
            let maxPossibleValue = WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol)
            let truncmaxPossibleValue = Math.trunc(maxPossibleValue*100)/100
            compare(maxTagButton.text, qsTr("Max. %1").arg(truncmaxPossibleValue === 0 ? Qt.locale().zeroDigit
                                                                                       : root.swapAdaptor.currencyStore.formatCurrencyAmount(truncmaxPossibleValue, expectedToken.symbol, {noSymbol: true, roundingMode: LocaleUtils.RoundingMode.Down})))
            waitForItemPolished(amountToSendInput)
            verify(amountToSendInput.interactive)
            tryCompare(amountToSendInput, "cursorVisible", true)
            tryCompare(amountToSendInput, "text", valueToExchange.toLocaleString(Qt.locale(), 'f', -128))
            compare(amountToSendInput.placeholderText, LocaleUtils.numberToLocaleString(0))
            tryCompare(bottomItemText, "text", root.swapAdaptor.currencyStore.formatCurrencyAmount(valueToExchange * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))

            if (maxTagButton.enabled) {
                // click on max button
                mouseClick(maxTagButton)
                waitForItemPolished(payPanel)

                verify(amountToSendInput.interactive)
                verify(amountToSendInput.cursorVisible)
                tryCompare(amountToSendInput, "text", maxPossibleValue === 0 ? "" : maxPossibleValue.toLocaleString(Qt.locale(), 'f', -128))
                tryCompare(bottomItemText, "text", root.swapAdaptor.currencyStore.formatCurrencyAmount(maxPossibleValue * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))
            }

            // After a valid route is returned, the max value should be calculated based on the fees returned
            // emit event with route that needs no approval
            let txRoutes = root.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded
            txRoutes.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txRoutes, "", "")

            let bestPath = SQUtils.ModelUtils.get(txRoutes.suggestedRoutes, 0, "route")
            const totalMaxFees = Math.ceil(bestPath.gasFees.maxFeePerGasM) * bestPath.gasAmount
            const totalMaxFeesInEth = SQUtils.AmountsArithmetic.div(
                                        SQUtils.AmountsArithmetic.fromString(totalMaxFees),
                                        SQUtils.AmountsArithmetic.fromNumber(1, 9))
            const amountToReserve = SQUtils.AmountsArithmetic.times(totalMaxFeesInEth, SQUtils.AmountsArithmetic.fromExponent(18)).toString()

            compare(root.swapAdaptor.swapOutputData.maxFeesToReserveRaw, amountToReserve)
            maxPossibleValue = WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol, amountToReserve)
            truncmaxPossibleValue = Math.trunc(maxPossibleValue*100)/100
            compare(maxTagButton.text,
                    qsTr("Max. %1").arg(
                        truncmaxPossibleValue === 0 ? Qt.locale().zeroDigit
                                                    : root.swapAdaptor.currencyStore.formatCurrencyAmount(truncmaxPossibleValue, expectedToken.symbol, {noSymbol: true, roundingMode: LocaleUtils.RoundingMode.Down})))


            closeAndVerfyModal()
        }

        function test_modal_max_button_click_with_no_preset_pay_value() {
            // Launch popup
            launchAndVerfyModal()

            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model

            // The default is the first account. Setting the second account to test switching accounts
            root.swapFormData.selectedAccountAddress = walletAccounts.get(1).address
            formValuesChanged.clear()
            
            // try setting value before popup is launched and check values
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.selectedAccountAddress = walletAccounts.get(0).address
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.toTokenKey = "STT"

            formValuesChanged.wait()

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const amountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!amountToSendInput)
            const bottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!bottomItemText)
            const payPanelAssetsModel = findChild(payPanel, "TokenSelectorViewAdaptor_outputAssetsModel")
            verify(!!payPanelAssetsModel)

            waitForRendering(payPanel, 200)

            let expectedToken =  SQUtils.ModelUtils.getByKey(payPanelAssetsModel, "tokensKey", "ETH")

            // check states for the pay input selector
            verify(maxTagButton.visible)
            let maxPossibleValue = WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol)
            compare(maxTagButton.text, qsTr("Max. %1").arg(maxPossibleValue === 0 ? "0"
                                                                                  : root.swapAdaptor.currencyStore.formatCurrencyAmount(maxPossibleValue, expectedToken.symbol, {noSymbol: true, roundingMode: LocaleUtils.RoundingMode.Down})))
            verify(amountToSendInput.interactive)
            verify(amountToSendInput.cursorVisible)
            compare(amountToSendInput.text, "")
            compare(amountToSendInput.placeholderText, LocaleUtils.numberToLocaleString(0))
            compare(bottomItemText.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(0, root.swapAdaptor.currencyStore.currentCurrency))

            // click on max button
            maxTagButton.clicked()
            waitForItemPolished(payPanel)

            formValuesChanged.wait()

            verify(amountToSendInput.interactive)
            verify(amountToSendInput.cursorVisible)
            compare(amountToSendInput.text, maxPossibleValue > 0 ? maxPossibleValue.toLocaleString(Qt.locale(), 'f', -128) : "")
            tryCompare(bottomItemText, "text", root.swapAdaptor.currencyStore.formatCurrencyAmount(maxPossibleValue * expectedToken.marketDetails.currencyPrice.amount, root.swapAdaptor.currencyStore.currentCurrency))

            closeAndVerfyModal()
        }

        function test_modal_pay_input_switching_accounts() {

            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model

            // test with pay value being set and not set
            let payValuesToTestWith = ["", "0.2"]

            for (let index = 0; index < payValuesToTestWith.length; index++) {
                let valueToExchangeString = payValuesToTestWith[index]
                let valueToExchange = Number(valueToExchangeString)

                // Asset chosen but no pay value set state -------------------------------------------------------------------------------
                root.swapFormData.fromTokenAmount = valueToExchangeString
                root.swapFormData.selectedAccountAddress = walletAccounts.get(0).address
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

                for (let i=0; i< walletAccounts.count; i++) {
                    root.swapFormData.selectedAccountAddress = walletAccounts.get(i).address

                    waitForRendering(payPanel)

                    const payTokenModel = findChild(payPanel, "TokenSelectorViewAdaptor_outputAssetsModel")
                    verify(!!payTokenModel)

                    let expectedToken = SQUtils.ModelUtils.getByKey(payTokenModel, "tokensKey", "ETH")

                    // check states for the pay input selector
                    tryCompare(maxTagButton, "visible", true)
                    let maxPossibleValue = WalletUtils.calculateMaxSafeSendAmount(expectedToken.currentBalance, expectedToken.symbol)
                    tryCompare(maxTagButton, "text", qsTr("Max. %1").arg(maxPossibleValue === 0 ? Qt.locale().zeroDigit :
                    root.swapAdaptor.currencyStore.formatCurrencyAmount(maxPossibleValue, expectedToken.symbol, {noSymbol: true, roundingMode: LocaleUtils.RoundingMode.Down})))
                    compare(payPanel.selectedHoldingId, expectedToken.symbol)
                    tryCompare(payPanel, "valueValid", !!valueToExchangeString && valueToExchange <= maxPossibleValue)

                    tryCompare(payPanel, "value", valueToExchange)
                    compare(payPanel.rawValue, !!valueToExchangeString ? SQUtils.AmountsArithmetic.fromNumber(valueToExchangeString, expectedToken.decimals).toString(): "0")

                    // check if tag is visible in case amount entered to exchange is greater than max balance to send
                    let amountEnteredGreaterThanMaxBalance = valueToExchange > maxPossibleValue
                    let errortext = amountEnteredGreaterThanMaxBalance ? qsTr("Insufficient funds for swap"): qsTr("An error has occured, please try again")
                    compare(errorTag.visible, amountEnteredGreaterThanMaxBalance)
                    compare(errorTag.text, root.swapAdaptor.errorMessage)
                    compare(errorTag.buttonText, root.swapAdaptor.isTokenBalanceInsufficient ? qsTr("Add assets") : qsTr("Add ETH"))
                    compare(errorTag.buttonVisible, amountEnteredGreaterThanMaxBalance)
                }

                closeAndVerfyModal()
            }
        }

        function test_modal_exchange_button_enabled_state_data() {
            return [
                        {fromToken: "", fromTokenAmount: "", toToken: "", toTokenAmount: ""},
                        {fromToken: "", fromTokenAmount: "", toToken: "STT", toTokenAmount: ""},
                        {fromToken: "ETH", fromTokenAmount: "", toToken: "", toTokenAmount: ""},
                        {fromToken: "ETH", fromTokenAmount: "", toToken: "STT", toTokenAmount: ""},
                        {fromToken: "ETH", fromTokenAmount: "100", toToken: "STT", toTokenAmount: ""},
                        {fromToken: "ETH", fromTokenAmount: "", toToken: "STT", toTokenAmount: "50"},
                        {fromToken: "ETH", fromTokenAmount: "100", toToken: "STT", toTokenAmount: "50"},
                        {fromToken: "", fromTokenAmount: "", toToken: "", toTokenAmount: "50"},
                        {fromToken: "", fromTokenAmount: "100", toToken: "", toTokenAmount: ""}
                    ]
        }

        function test_modal_exchange_button_enabled_state(data) {
            const swapExchangeButton = findChild(controlUnderTest, "swapExchangeButton")
            verify(!!swapExchangeButton)

            root.swapFormData.fromTokensKey = data.fromToken
            root.swapFormData.fromTokenAmount = data.fromTokenAmount
            root.swapFormData.toTokenKey = data.toToken
            root.swapFormData.toTokenAmount = data.toTokenAmount

            tryCompare(swapExchangeButton, "enabled", !!data.fromToken || !!data.toToken)
        }

        function test_modal_exchange_button_default_state_data() {
            return [
                        {fromToken: "", fromTokenAmount: "", toToken: "", toTokenAmount: ""},
                        {fromToken: "", fromTokenAmount: "", toToken: "STT", toTokenAmount: ""},
                        {fromToken: "ETH", fromTokenAmount: "", toToken: "", toTokenAmount: ""},
                        {fromToken: "ETH", fromTokenAmount: "", toToken: "STT", toTokenAmount: ""},
                        {fromToken: "ETH", fromTokenAmount: "100", toToken: "STT", toTokenAmount: ""},
                        {fromToken: "ETH", fromTokenAmount: "", toToken: "STT", toTokenAmount: "50"},
                        {fromToken: "ETH", fromTokenAmount: "100", toToken: "STT", toTokenAmount: "50"},
                        {fromToken: "", fromTokenAmount: "", toToken: "", toTokenAmount: "50"},
                        {fromToken: "", fromTokenAmount: "100", toToken: "", toTokenAmount: ""}
                    ]
        }

        function test_modal_exchange_button_default_state(data) {
            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const receivePanel = findChild(controlUnderTest, "receivePanel")
            verify(!!receivePanel)
            const swapExchangeButton = findChild(controlUnderTest, "swapExchangeButton")
            verify(!!swapExchangeButton)

            const payAmountToSendInput = findChild(payPanel, "amountToSendInput")
            verify(!!payAmountToSendInput)
            const payBottomItemText = findChild(payPanel, "bottomItemText")
            verify(!!payBottomItemText)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)

            const receiveAmountToSendInput = findChild(receivePanel, "amountToSendInput")
            verify(!!receiveAmountToSendInput)
            const receiveBottomItemText = findChild(receivePanel, "bottomItemText")
            verify(!!receiveBottomItemText)

            const accountsModalHeader = getAndVerifyAccountsModalHeader()
            let walletAccounts = accountsModalHeader.model

            root.swapAdaptor.reset()

            // set network and address by default same
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            root.swapFormData.selectedAccountAddress = walletAccounts.get(0).address
            root.swapFormData.fromTokensKey = data.fromToken
            root.swapFormData.fromTokenAmount = data.fromTokenAmount
            root.swapFormData.toTokenKey = data.toToken
            root.swapFormData.toTokenAmount = data.toTokenAmount

            let expectedFromTokenIcon = !!root.swapAdaptor.fromToken && !!root.swapAdaptor.fromToken.symbol ?
                    Constants.tokenIcon(root.swapAdaptor.fromToken.symbol): ""
            let expectedToTokenIcon = !!root.swapAdaptor.toToken && !!root.swapAdaptor.toToken.symbol ?
                    Constants.tokenIcon(root.swapAdaptor.toToken.symbol): ""

            // Launch popup
            launchAndVerfyModal()
            waitForRendering(payPanel)
            waitForRendering(receivePanel)
            waitForRendering(payAmountToSendInput)

            let paytokenSelectorContentItemText = findChild(payPanel, "tokenSelectorContentItemText")
            verify(!!paytokenSelectorContentItemText)
            let paytokenSelectorIcon = findChild(payPanel, "tokenSelectorIcon")
            compare(!!data.fromToken , !!paytokenSelectorIcon)
            let receivetokenSelectorContentItemText = findChild(receivePanel, "tokenSelectorContentItemText")
            verify(!!receivetokenSelectorContentItemText)
            let receivetokenSelectorIcon = findChild(receivePanel, "tokenSelectorIcon")
            compare(!!data.toToken, !!receivetokenSelectorIcon)

            // verify pay values
            compare(payPanel.tokenKey, data.fromToken)
            compare(payPanel.tokenAmount, data.fromTokenAmount)
            verify(payAmountToSendInput.cursorVisible)
            compare(paytokenSelectorContentItemText.text, !!root.swapFormData.fromTokensKey ? root.swapFormData.fromTokensKey : qsTr("Select asset"))
            compare(!!data.fromToken , !!paytokenSelectorIcon)
            if(!!paytokenSelectorIcon) {
                compare(paytokenSelectorIcon.image.source, expectedFromTokenIcon)
            }
            verify(!!data.fromToken ? maxTagButton.visible: !maxTagButton.visible)

            // verify receive values
            compare(receivePanel.tokenKey, data.toToken)
            compare(receivePanel.tokenAmount, data.toTokenAmount)
            verify(!receiveAmountToSendInput.cursorVisible)
            compare(receivetokenSelectorContentItemText.text, !!root.swapFormData.toTokenKey ? root.swapFormData.toTokenKey : qsTr("Select asset"))
            if(!!receivetokenSelectorIcon) {
                compare(receivetokenSelectorIcon.image.source, expectedToTokenIcon)
            }

            // click exchange button
            swapExchangeButton.clicked()
            waitForRendering(payPanel)
            waitForRendering(receivePanel)

            // verify form values
            compare(root.swapFormData.fromTokensKey, data.toToken)
            compare(root.swapFormData.fromTokenAmount, data.toTokenAmount)
            compare(root.swapFormData.toTokenKey, data.fromToken)
            compare(root.swapFormData.toTokenAmount, data.fromTokenAmount)

            paytokenSelectorContentItemText = findChild(payPanel, "tokenSelectorContentItemText")
            verify(!!paytokenSelectorContentItemText)
            paytokenSelectorIcon = findChild(payPanel, "tokenSelectorIcon")
            compare(!!root.swapFormData.fromTokensKey , !!paytokenSelectorIcon)
            receivetokenSelectorContentItemText = findChild(receivePanel, "tokenSelectorContentItemText")
            verify(!!receivetokenSelectorContentItemText)
            receivetokenSelectorIcon = findChild(receivePanel, "tokenSelectorIcon")
            compare(!!root.swapFormData.toTokenKey, !!receivetokenSelectorIcon)

            // verify pay values
            compare(payPanel.tokenKey, data.toToken)
            compare(payPanel.tokenAmount, data.toTokenAmount)
            verify(payAmountToSendInput.cursorVisible)
            compare(paytokenSelectorContentItemText.text, !!data.toToken ? data.toToken : qsTr("Select asset"))
            if(!!paytokenSelectorIcon) {
                compare(paytokenSelectorIcon.image.source, expectedToTokenIcon)
            }
            verify(!!data.toToken ? maxTagButton.visible: !maxTagButton.visible)
            compare(maxTagButton.text, qsTr("Max. %1").arg(Qt.locale().zeroDigit))
            compare(maxTagButton.type, (payAmountToSendInput.valid || !payAmountToSendInput.text) && maxTagButton.value > 0 ? StatusBaseButton.Type.Normal : StatusBaseButton.Type.Danger)

            // verify receive values
            compare(receivePanel.tokenKey, data.fromToken)
            compare(receivePanel.tokenAmount, data.fromTokenAmount)
            verify(!receiveAmountToSendInput.cursorVisible)
            compare(receivetokenSelectorContentItemText.text, !!data.fromToken ? data.fromToken : qsTr("Select asset"))
            if(!!receivetokenSelectorIcon) {
                compare(receivetokenSelectorIcon.image.source, expectedFromTokenIcon)
            }

            closeAndVerfyModal()
        }

        function test_approval_flow_button_states() {
            root.swapAdaptor.reset()

            // Launch popup
            launchAndVerfyModal()

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
            compare(maxFeesValue.text, "--")
            verify(!signButton.interactive)
            verify(!errorTag.visible)

            // set input values in the form correctly
            root.swapFormData.fromTokensKey = root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel.get(0).key
            formValuesChanged.wait()
            root.swapFormData.toTokenKey = root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel.get(1).key
            root.swapFormData.fromTokenAmount = "0.001"
            formValuesChanged.wait()
            root.swapFormData.selectedNetworkChainId = root.swapAdaptor.filteredFlatNetworksModel.get(0).chainId
            formValuesChanged.wait()
            root.swapFormData.selectedAccountAddress = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            formValuesChanged.wait()

            // wait for fetchSuggestedRoutes function to be called
            fetchSuggestedRoutesCalled.wait()

            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit event with route that needs no approval
            let txRoutes = root.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded
            txRoutes.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txRoutes, "", "")

            // calculation needed for total fees
            let gasTimeEstimate = txRoutes.gasTimeEstimate
            let totalTokenFeesInFiat = gasTimeEstimate.totalTokenFees * root.swapAdaptor.fromToken.marketDetails.currencyPrice.amount
            let totalFees = root.swapAdaptor.currencyStore.getFiatValue(gasTimeEstimate.totalFeesInEth, Constants.ethToken) + totalTokenFeesInFiat
            let bestPath = SQUtils.ModelUtils.get(txRoutes.suggestedRoutes, 0, "route")

            // verify loading state removed and data is displayed as expected on the Modal
            verify(root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)
            compare(root.swapAdaptor.swapOutputData.fromTokenAmount, "")
            compare(root.swapAdaptor.swapOutputData.toTokenAmount, SQUtils.AmountsArithmetic.div(
                        SQUtils.AmountsArithmetic.fromString(txRoutes.amountToReceive),
                        SQUtils.AmountsArithmetic.fromNumber(1, root.swapAdaptor.toToken.decimals)).toString())
            compare(root.swapAdaptor.swapOutputData.totalFees, totalFees)
            compare(root.swapAdaptor.swapOutputData.hasError, false)
            compare(root.swapAdaptor.swapOutputData.estimatedTime, bestPath.estimatedTime)
            compare(root.swapAdaptor.swapOutputData.txProviderName, bestPath.bridgeName)
            compare(root.swapAdaptor.swapOutputData.approvalNeeded, true)
            compare(root.swapAdaptor.swapOutputData.approvalGasFees, bestPath.approvalGasFees.toString())
            compare(root.swapAdaptor.swapOutputData.approvalAmountRequired, bestPath.approvalAmountRequired)
            compare(root.swapAdaptor.swapOutputData.approvalContractAddress, bestPath.approvalContractAddress)

            verify(!errorTag.visible)
            verify(signButton.enabled)
            verify(!signButton.loadingWithText)
            compare(signButton.text, qsTr("Approve %1").arg(root.swapAdaptor.fromToken.symbol))
            // TODO: note that there is a loss of precision as the approvalGasFees is currently passes as float from the backend and not string.
            compare(maxFeesValue.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(
                        root.swapAdaptor.swapOutputData.totalFees,
                        root.swapAdaptor.currencyStore.currentCurrency))

            // simulate user click on approve button and approval failed
            root.swapStore.transactionSent(root.swapAdaptor.uuid, root.swapFormData.selectedNetworkChainId, true, "0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", "")

            verify(root.swapAdaptor.approvalPending)
            verify(!root.swapAdaptor.approvalSuccessful)
            verify(!errorTag.visible)
            verify(!signButton.interactive)
            verify(signButton.loadingWithText)
            compare(signButton.text, qsTr("Approving %1").arg(root.swapAdaptor.fromToken.symbol))
            // TODO: note that there is a loss of precision as the approvalGasFees is currently passes as float from the backend and not string.
            compare(maxFeesValue.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(
                        root.swapAdaptor.swapOutputData.totalFees,
                        root.swapAdaptor.currencyStore.currentCurrency))

            // simulate approval tx was unsuccessful
            root.swapStore.transactionSendingComplete("0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", "Failed")

            verify(!root.swapAdaptor.approvalPending)
            verify(!root.swapAdaptor.approvalSuccessful)
            verify(!errorTag.visible)
            verify(signButton.enabled)
            verify(!signButton.loadingWithText)
            compare(signButton.text, qsTr("Approve %1").arg(root.swapAdaptor.fromToken.symbol))
            // TODO: note that there is a loss of precision as the approvalGasFees is currently passes as float from the backend and not string.
            compare(maxFeesValue.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(
                        root.swapAdaptor.swapOutputData.totalFees,
                        root.swapAdaptor.currencyStore.currentCurrency))

            // simulate user click on approve button and successful approval tx made
            signButton.clicked()
            root.swapStore.transactionSent(root.swapAdaptor.uuid, root.swapFormData.selectedNetworkChainId, true, "0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", "")

            verify(root.swapAdaptor.approvalPending)
            verify(!root.swapAdaptor.approvalSuccessful)
            verify(!errorTag.visible)
            verify(!signButton.interactive)
            verify(signButton.loadingWithText)
            compare(signButton.text, qsTr("Approving %1").arg(root.swapAdaptor.fromToken.symbol))
            // TODO: note that there is a loss of precision as the approvalGasFees is currently passes as float from the backend and not string.
            compare(maxFeesValue.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(
                        root.swapAdaptor.swapOutputData.totalFees,
                        root.swapAdaptor.currencyStore.currentCurrency))

            root.swapStore.transactionSendingComplete("0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", "Success")

            // simulate approval tx was successful
            signButton.clicked()

            root.swapStore.transactionSendingComplete("0x877ffe47fc29340312611d4e833ab189fe4f4152b01cc9a05bb4125b81b2a89a", "Success")

            verify(!root.swapAdaptor.approvalPending)
            verify(root.swapAdaptor.approvalSuccessful)
            verify(!errorTag.visible)
            verify(signButton.interactive)
            verify(!signButton.loadingWithText)
            compare(signButton.text, qsTr("Swap"))
            compare(maxFeesValue.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(
                        root.swapAdaptor.swapOutputData.totalFees,
                        root.swapAdaptor.currencyStore.currentCurrency))

            let txHasRouteNoApproval = root.dummySwapTransactionRoutes.txHasRouteNoApproval
            txHasRouteNoApproval.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txHasRouteNoApproval, "", "")

            verify(!root.swapAdaptor.approvalPending)
            verify(root.swapAdaptor.approvalSuccessful)
            verify(!errorTag.visible)
            verify(signButton.enabled)
            verify(!signButton.loadingWithText)
            compare(signButton.text, qsTr("Swap"))
            compare(maxFeesValue.text, root.swapAdaptor.currencyStore.formatCurrencyAmount(
                        root.swapAdaptor.swapOutputData.totalFees,
                        root.swapAdaptor.currencyStore.currentCurrency))
            closeAndVerfyModal()
        }

        function test_modal_switching_networks_payPanel_data() {
            return [
                        {key: "ETH"},
                        {key: "aave"}
                    ]
        }

        function test_modal_switching_networks_payPanel(data) {
            // try setting value before popup is launched and check values
            let valueToExchange = 1
            let valueToExchangeString = valueToExchange.toString()
            root.swapFormData.selectedAccountAddress = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            root.swapFormData.fromTokensKey = data.key
            root.swapFormData.fromTokenAmount = valueToExchangeString

            // Launch popup
            launchAndVerfyModal()

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)
            const maxTagButton = findChild(payPanel, "maxTagButton")
            verify(!!maxTagButton)
            const networkComboBox = findChild(controlUnderTest, "networkFilter")
            verify(!!networkComboBox)
            const errorTag = findChild(controlUnderTest, "errorTag")
            verify(!!errorTag)

            for (let i=0; i<networkComboBox.control.popup.contentItem.count; i++) {
                // launch network selection popup
                verify(!networkComboBox.control.popup.opened)
                mouseClick(networkComboBox)
                verify(networkComboBox.control.popup.opened)

                let delegateUnderTest = networkComboBox.control.popup.contentItem.itemAtIndex(i)
                verify(!!delegateUnderTest)
                mouseClick(delegateUnderTest)

                waitForRendering(payPanel)

                const tokenSelectorContentItemText = findChild(payPanel, "tokenSelectorContentItemText")
                verify(!!tokenSelectorContentItemText)

                let fromTokenExistsOnNetwork = false
                let expectedToken = SQUtils.ModelUtils.getByKey(root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel, "key", root.swapFormData.fromTokensKey)
                if(!!expectedToken) {
                    fromTokenExistsOnNetwork = !!SQUtils.ModelUtils.getByKey(expectedToken.addressPerChain, "chainId",networkComboBox.selection[0], "address")
                }

                if (!fromTokenExistsOnNetwork) {
                    verify(!maxTagButton.visible)
                    compare(payPanel.selectedHoldingId, "")
                    verify(!payPanel.valueValid)
                    tryCompare(payPanel, "rawValue", "0")
                    verify(!errorTag.visible)
                    compare(tokenSelectorContentItemText.text, qsTr("Select asset"))
                } else {
                    // check states for the pay input selector
                    verify(maxTagButton.visible)
                    const payAssetsModel = findChild(payPanel, "TokenSelectorViewAdaptor_outputAssetsModel")
                    verify(!!payAssetsModel)
                    let balancesModel = SQUtils.ModelUtils.getByKey(payAssetsModel, "tokensKey", root.swapFormData.fromTokensKey, "balances")
                    let balanceEntry = SQUtils.ModelUtils.getFirstModelEntryIf(balancesModel, (balance) => {
                                                                                   return balance.account.toLowerCase() === root.swapFormData.selectedAccountAddress.toLowerCase() &&
                                                                                   balance.chainId === root.swapFormData.selectedNetworkChainId
                                                                               })
                    let balance =  SQUtils.AmountsArithmetic.toNumber(
                            SQUtils.AmountsArithmetic.fromString(balanceEntry.balance),
                            expectedToken.decimals)

                    let maxPossibleValue = WalletUtils.calculateMaxSafeSendAmount(balance, expectedToken.symbol)

                    compare(maxTagButton.text, qsTr("Max. %1").arg(
                                maxPossibleValue === 0 ? "0" :
                                                         root.swapAdaptor.currencyStore.formatCurrencyAmount(maxPossibleValue, expectedToken.symbol, {noSymbol: true, roundingMode: LocaleUtils.RoundingMode.Down})))
                    compare(payPanel.selectedHoldingId.toLowerCase(), expectedToken.symbol.toLowerCase())
                    compare(payPanel.valueValid, valueToExchange <= maxPossibleValue)
                    tryCompare(payPanel, "rawValue", SQUtils.AmountsArithmetic.fromNumber(valueToExchangeString, expectedToken.decimals).toString())
                    compare(errorTag.visible, valueToExchange > maxPossibleValue)
                    if(errorTag.visible)
                        compare(errorTag.text, qsTr("Insufficient funds for swap"))
                    compare(tokenSelectorContentItemText.text, expectedToken.symbol)
                }
            }

            closeAndVerfyModal()
        }

        function test_modal_switching_networks_receivePanel_data() {
                return [
                            {key: "aave"},
                            {key: "STT"}
                        ]
        }

        function test_modal_switching_networks_receivePanel(data) {
            // try setting value before popup is launched and check values
            let valueToExchange = 1
            let valueToExchangeString = valueToExchange.toString()
            root.swapFormData.selectedAccountAddress = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.fromTokenAmount = valueToExchangeString
            root.swapFormData.toTokenKey = data.key

            // Launch popup
            launchAndVerfyModal()

            const receivePanel = findChild(controlUnderTest, "receivePanel")
            verify(!!receivePanel)
            const networkComboBox = findChild(controlUnderTest, "networkFilter")
            verify(!!networkComboBox)

            for (let i=0; i<networkComboBox.control.popup.contentItem.count; i++) {
                // launch network selection popup
                verify(!networkComboBox.control.popup.opened)
                mouseClick(networkComboBox)
                verify(networkComboBox.control.popup.opened)

                let delegateUnderTest = networkComboBox.control.popup.contentItem.itemAtIndex(i)
                verify(!!delegateUnderTest)
                mouseClick(delegateUnderTest)

                waitForRendering(receivePanel)

                const tokenSelectorContentItemText = findChild(receivePanel, "tokenSelectorContentItemText")
                verify(!!tokenSelectorContentItemText)

                let fromTokenExistsOnNetwork = false
                let expectedToken = SQUtils.ModelUtils.getByKey(root.swapAdaptor.walletAssetsStore.walletTokensStore.plainTokensBySymbolModel, "key", root.swapFormData.toTokenKey)
                if(!!expectedToken) {
                    fromTokenExistsOnNetwork = !!SQUtils.ModelUtils.getByKey(expectedToken.addressPerChain, "chainId", networkComboBox.selection[0], "address")
                }

                if (!fromTokenExistsOnNetwork) {
                    compare(receivePanel.selectedHoldingId, "")
                    compare(tokenSelectorContentItemText.text, qsTr("Select asset"))
                } else {
                    compare(receivePanel.selectedHoldingId.toLowerCase(), expectedToken.symbol.toLowerCase())
                    compare(tokenSelectorContentItemText.text, expectedToken.symbol)
                }
            }

            closeAndVerfyModal()
        }

        function test_auto_refresh() {
            // Asset chosen but no pay value set state -------------------------------------------------------------------------------
            root.swapFormData.fromTokenAmount = "0.0001"
            root.swapFormData.selectedAccountAddress = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            root.swapFormData.selectedNetworkChainId = 11155111
            root.swapFormData.fromTokensKey = "ETH"
            // for testing making it 1.2 seconds so as to not make tests running too long
            root.swapFormData.autoRefreshTime = 1200

            // Launch popup
            launchAndVerfyModal()

            // check if fetchSuggestedRoutes called
            fetchSuggestedRoutesCalled.wait()

            // emit routes ready
            let txHasRouteNoApproval = root.dummySwapTransactionRoutes.txHasRouteNoApproval
            txHasRouteNoApproval.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txHasRouteNoApproval, "", "")
        }

        function test_deleteing_input_characters_data() {
            return [
                        {input: "0.001", locale: Qt.locale("en_US")},
                        {input: "1.00015", locale: Qt.locale("en_US")},
                        {input: "0.001", locale: Qt.locale("pl_PL")},
                        {input: "1.90015", locale: Qt.locale("pl_PL")},
                        {input: "100.000000000000151001", locale: Qt.locale("en_US")},
                        {input: "1.020000000000015101", locale: Qt.locale("en_US")}
                    ]
        }

        function test_deleteing_input_characters(data) {
            root.swapFormData.selectedAccountAddress = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            root.swapFormData.selectedNetworkChainId = 11155111
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.fromTokenAmount = data.input

            const amountToSendInput = findChild(controlUnderTest, "amountToSendInput")
            verify(!!amountToSendInput)
            const amountToSend_textField = findChild(controlUnderTest, "amountToSend_textField")
            verify(!!amountToSend_textField)

            amountToSendInput.locale = data.locale

            // Launch popup
            launchAndVerfyModal()
            mouseClick(amountToSendInput)
            waitForRendering(amountToSendInput)
            amountToSend_textField.cursorPosition = amountToSendInput.text.length

            let amountToTestInLocale = data.input.replace('.', amountToSendInput.locale.decimalPoint)
            for(let i =0; i< data.input.length; i++) {
                keyClick(Qt.Key_Backspace)
                let expectedAmount = amountToTestInLocale.substring(0, data.input.length - (i+1))
                tryCompare(amountToSendInput, "text", expectedAmount)
            }
        }

        function test_no_auto_refresh_when_proposalLoading_or_approvalPending() {
            fetchSuggestedRoutesCalled.clear()
            root.swapFormData.fromTokenAmount = "0.0001"
            root.swapFormData.selectedAccountAddress = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            root.swapFormData.selectedNetworkChainId = 11155111
            root.swapFormData.fromTokensKey = "ETH"
            // for testing making it 1.2 seconds so as to not make tests running too long
            root.swapFormData.autoRefreshTime = 1200

            // Launch popup
//            launchAndVerfyModal()

//            // check if fetchSuggestedRoutes called
//            tryCompare(fetchSuggestedRoutesCalled, "count", 1)

            // no new calls to fetch new proposal should be made as the proposal is still loading
//            wait(root.swapFormData.autoRefreshTime*2)
//            compare(fetchSuggestedRoutesCalled.count, 1)

//            // emit routes ready
//            let txHasRouteApproval = root.dummySwapTransactionRoutes.txHasRoutesApprovalNeeded
//            txHasRouteApproval.uuid = root.swapAdaptor.uuid
//            root.swapStore.suggestedRoutesReady(txHasRouteApproval, "", "")

//            // now refresh can occur as no propsal or signing is pending
//            tryCompare(fetchSuggestedRoutesCalled, "count", 2)

//            // emit routes ready
//            txHasRouteApproval.uuid = root.swapAdaptor.uuid
//            root.swapStore.suggestedRoutesReady(txHasRouteApproval, "", "")

//            verify(root.swapAdaptor.swapOutputData.approvalNeeded)
//            verify(!root.swapAdaptor.approvalPending)

//            // sign approval and check that auto refresh doesnt occur
//            root.swapAdaptor.sendApproveTx()

//            // no new calls to fetch new proposal should be made as the approval is pending
//            verify(root.swapAdaptor.swapOutputData.approvalNeeded)
//            verify(root.swapAdaptor.approvalPending)
//            wait(root.swapFormData.autoRefreshTime*2)
//            compare(fetchSuggestedRoutesCalled.count, 2)
        }

        function test_uuid_change() {
            root.swapFormData.fromTokenAmount = "0.0001"
            root.swapFormData.selectedAccountAddress = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            root.swapFormData.selectedNetworkChainId = 11155111
            root.swapFormData.fromTokensKey = "ETH"
            root.swapFormData.toTokenKey = "STT"

            // Launch popup
            launchAndVerfyModal()

            const payPanel = findChild(controlUnderTest, "payPanel")
            verify(!!payPanel)

            const receivePanel = findChild(controlUnderTest, "receivePanel")
            verify(!!receivePanel)

            waitForItemPolished(controlUnderTest.contentItem)

            // check if fetchSuggestedRoutes called
            fetchSuggestedRoutesCalled.wait()

            // emit routes ready
            let txHasRouteNoApproval = root.dummySwapTransactionRoutes.txHasRouteNoApproval
            txHasRouteNoApproval.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txHasRouteNoApproval, "", "")

            let lastUuid = root.swapAdaptor.uuid

            // edit some params to retry swap
            root.swapFormData.fromTokenAmount = "0.00011"
            waitForRendering(receivePanel)
            formValuesChanged.wait()
            // verify loading state was set and no errors currently
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // uuid changed
            verify(root.swapAdaptor.uuid !== lastUuid)

            // emit event with route that needs no approval for previous uuid
            txHasRouteNoApproval.uuid = lastUuid
            root.swapStore.suggestedRoutesReady(txHasRouteNoApproval, "", "")

            // route with old uuid should have been ignored
            verifyLoadingAndNoErrorsState(payPanel, receivePanel)

            // emit routes ready
            txHasRouteNoApproval.uuid = root.swapAdaptor.uuid
            root.swapStore.suggestedRoutesReady(txHasRouteNoApproval, "", "")

            // verify loading state removed and data is displayed as expected on the Modal
            verify(root.swapAdaptor.validSwapProposalReceived)
            verify(!root.swapAdaptor.swapProposalLoading)

            closeAndVerfyModal()
        }
    }
}
