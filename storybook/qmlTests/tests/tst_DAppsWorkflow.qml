import QtQuick 2.15

import QtTest 1.15
import "helpers/wallet_connect.js" as Testing

import StatusQ 0.1 // See #10218
import StatusQ.Core.Utils 0.1

import QtQuick.Controls 2.15

import Storybook 1.0

import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0
import AppLayouts.Profile.stores 1.0
import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

import shared.stores 1.0

import utils 1.0

Item {
    id: root

    width: 600
    height: 400

    Component {
        id: sdkComponent

        WalletConnectSDKBase {
            property bool sdkReady: true

            property var getActiveSessionsCallbacks: []
            getActiveSessions: function(callback) {
                getActiveSessionsCallbacks.push({callback})
            }

            property int pairCalled: 0
            pair: function() {
                pairCalled++
            }

            property var buildApprovedNamespacesCalls: []
            buildApprovedNamespaces: function(params, supportedNamespaces) {
                buildApprovedNamespacesCalls.push({params, supportedNamespaces})
            }

            property var approveSessionCalls: []
            approveSession: function(sessionProposalJson, approvedNamespaces) {
                approveSessionCalls.push({sessionProposalJson, approvedNamespaces})
            }

            property var acceptSessionRequestCalls: []
            acceptSessionRequest: function(topic, id, signature) {
                acceptSessionRequestCalls.push({topic, id, signature})
            }

            property var rejectSessionRequestCalls: []
            rejectSessionRequest: function(topic, id, error) {
                rejectSessionRequestCalls.push({topic, id, error})
            }
        }
    }

    Component {
        id: serviceComponent

        WalletConnectService {
            property var onApproveSessionResultTriggers: []
            onApproveSessionResult: function(session, error) {
                onApproveSessionResultTriggers.push({session, error})
            }

            property var onDisplayToastMessageTriggers: []
            onDisplayToastMessage: function(message, error) {
                onDisplayToastMessageTriggers.push({message, error})
            }

            property var onPairingValidatedTriggers: []
            onPairingValidated: function(validationState) {
                onPairingValidatedTriggers.push({validationState})
            }
        }
    }

    Component {
        id: dappsStoreComponent

        DAppsStore {
            property string dappsListReceivedJsonStr: '[]'

            signal dappsListReceived(string dappsJson)
            signal userAuthenticated(string topic, string id, string password, string pin)
            signal userAuthenticationFailed(string topic, string id)

            // By default, return no dapps in store
            function getDapps() {
                dappsListReceived(dappsListReceivedJsonStr)
                return true
            }

            property var addWalletConnectSessionCalls: []
            function addWalletConnectSession(sessionJson) {
                addWalletConnectSessionCalls.push({sessionJson})
                return true
            }

            property var authenticateUserCalls: []
            function authenticateUser(topic, id, address) {
                authenticateUserCalls.push({topic, id, address})
            }

            property var signMessageCalls: []
            function signMessage(topic, id, address, password, message) {
                signMessageCalls.push({topic, id, address, password, message})
            }
            property var safeSignTypedDataCalls: []
            function safeSignTypedData(topic, id, address, password, message, chainId, legacy) {
                safeSignTypedDataCalls.push({topic, id, address, password, message, chainId, legacy})
            }

            property var updateWalletConnectSessionsCalls: []
            function updateWalletConnectSessions(activeTopicsJson) {
                updateWalletConnectSessionsCalls.push({activeTopicsJson})
            }

            function getEstimatedTime(chainId, maxFeePerGas) {
                return Constants.TransactionEstimatedTime.LessThanThreeMins
            }

            property var mockedSuggestedFees: ({
                gasPrice: 2.0,
                baseFee: 5.0,
                maxPriorityFeePerGas: 2.0,
                maxFeePerGasL: 1.0,
                maxFeePerGasM: 1.1,
                maxFeePerGasH: 1.2,
                l1GasFee: 0.0,
                eip1559Enabled: true
            })

            function getSuggestedFees() {
                return mockedSuggestedFees
            }

            function hexToDec(hex) {
                if (hex.length > "0xfffffffffffff".length) {
                    console.warn(`Beware of possible loss of precision converting ${hex}`)
                }
                return parseInt(hex, 16).toString()
            }
        }
    }

    Component {
        id: walletStoreComponent

        QtObject {
            readonly property ListModel filteredFlatModel: ListModel {
                ListElement {
                    chainId: 1
                    layer: 1
                }
                ListElement {
                    chainId: 2
                    chainName: "Test Chain"
                    iconUrl: "network/Network=Ethereum"
                    layer: 2
                }
                // Used by tst_balanceCheck
                ListElement {
                    chainId: 11155111
                    layer: 1
                }
                // Used by tst_balanceCheck
                ListElement {
                    chainId: 421613
                    layer: 2
                }
            }

            readonly property ListModel nonWatchAccounts: ListModel {
                ListElement {
                    address: "0x1"
                    keycardAccount: false
                }
                ListElement {
                    address: "0x2"
                    name: "helloworld"
                    emoji: "😋"
                    color: "#2A4AF5"
                    keycardAccount: false
                }
                ListElement {
                    address: "0x3a"
                    keycardAccount: false
                }
                // Account from GroupedAccountsAssetsModel
                ListElement {
                    address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                    keycardAccount: false
                }
            }
            function getNetworkShortNames(chainIds) {
                 return "eth:oeth:arb"
            }

            readonly property var currencyStore: CurrenciesStore {}
            readonly property var walletAssetsStore: assetsStoreMock
        }
    }

    WalletStore.WalletAssetsStore {
        id: assetsStoreMock
        // Silence warnings
        assetsWithFilteredBalances: ListModel {}

        readonly property var groupedAccountAssetsModel: groupedAccountsAssetsModel
    }

    Component {
        id: dappsRequestHandlerComponent

        DAppsRequestHandler {
            currenciesStore: CurrenciesStore {}
            assetsStore: assetsStoreMock

            property var maxFeesUpdatedCalls: []
            onMaxFeesUpdated: function(fiatMaxFees, ethMaxFees, haveEnoughFunds, haveEnoughForFees, symbol, feesInfo) {
                maxFeesUpdatedCalls.push({fiatMaxFees, ethMaxFees, haveEnoughFunds, haveEnoughForFees, symbol, feesInfo})
            }
        }
    }

    TestCase {
        id: requestHandlerTest
        name: "DAppsRequestHandler"
        // Ensure mocked GroupedAccountsAssetsModel is properly initialized
        when: windowShown

        property DAppsRequestHandler handler: null

        SignalSpy {
            id: displayToastMessageSpy
            target: requestHandlerTest.handler
            signalName: "onDisplayToastMessage"
        }

        function init() {
            let walletStore = createTemporaryObject(walletStoreComponent, root)
            verify(!!walletStore)
            let sdk = createTemporaryObject(sdkComponent, root, { projectId: "12ab" })
            verify(!!sdk)
            let store = createTemporaryObject(dappsStoreComponent, root)
            verify(!!store)
            handler = createTemporaryObject(dappsRequestHandlerComponent, root, {
                sdk: sdk,
                store: store,
                accountsModel: walletStore.nonWatchAccounts,
                networksModel: walletStore.filteredFlatModel
            })
            verify(!!handler)
        }

        function cleanup() {
            displayToastMessageSpy.clear()
        }

        function test_TestAuthentication() {
            let td = mockSessionRequestEvent(this, handler.sdk, handler.accountsModel, handler.networksModel)
            handler.authenticate(td.request)
            compare(handler.store.authenticateUserCalls.length, 1, "expected a call to store.authenticateUser")

            let store = handler.store
            store.userAuthenticated(td.topic, td.request.id, "hello world", "")
            compare(store.signMessageCalls.length, 1, "expected a call to store.signMessage")
            compare(store.signMessageCalls[0].message, td.request.data)
        }

        function test_onSessionRequestEventDifferentCaseForAddress() {
            const sdk = handler.sdk

            const testAddressUpper = "0x3A"
            const chainId = 2
            const method = "personal_sign"
            const message = "hello world"
            const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${testAddressUpper}"`]
            const topic = "b536a"
            const session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            // Expect to have calls to getActiveSessions from service initialization
            const prevRequests = sdk.getActiveSessionsCallbacks.length
            sdk.sessionRequestEvent(session)

            compare(sdk.getActiveSessionsCallbacks.length, 1, "expected DAppsRequestHandler call sdk.getActiveSessions")
        }

        // Tests that the request is ignored if not in the current profile (don't have the PK for the address)
        function test_onSessionRequestEventMissingAddress() {
            const sdk = handler.sdk

            const testAddressUpper = "0xY"
            const chainId = 2
            const method = "personal_sign"
            const message = "hello world"
            const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${testAddressUpper}"`]
            const topic = "b536a"
            const session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            // Expect to have calls to getActiveSessions from service initialization
            const prevRequests = sdk.getActiveSessionsCallbacks.length
            sdk.sessionRequestEvent(session)

            compare(sdk.getActiveSessionsCallbacks.length, 0, "expected DAppsRequestHandler don't call sdk.getActiveSessions")
            compare(sdk.rejectSessionRequestCalls.length, 0, "expected no call to service.rejectSessionRequest")
        }

        function test_balanceCheck_data() {
            return [{
                tag: "have_enough_funds",
                chainId: 11155111,

                expect: {
                    haveEnoughForFees: true,
                }
            },
            {
                tag: "doest_have_enough_funds",
                chainId: 11155111,
                // Override the suggestedFees to a higher value
                maxFeePerGasM: 1000000.0, /*GWEI*/

                expect: {
                    haveEnoughForFees: false,
                }
            },
            {
                tag: "check_l2_doesnt_have_enough_funds_on_l1",
                chainId: 421613,
                // Override the l1 additional fees
                l1GasFee: 1000000000.0,

                expect: {
                    haveEnoughForFees: false,
                }
            },
            {
                tag: "check_l2_doesnt_have_enough_funds_on_l2",
                chainId: 421613,
                // Override the l2 to a higher value
                maxFeePerGasM: 1000000.0, /*GWEI*/
                // Override the l1 additional fees
                l1GasFee: 10.0,

                expect: {
                    haveEnoughForFees: false,
                }
            }]
        }

        function test_balanceCheck(data) {
            let sdk = handler.sdk

            // Override the suggestedFees
            if (!!data.maxFeePerGasM) {
                handler.store.mockedSuggestedFees.maxFeePerGasM = data.maxFeePerGasM
            }
            if (!!data.l1GasFee) {
                handler.store.mockedSuggestedFees.l1GasFee = data.l1GasFee
            }

            let testAddress = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
            let chainId = data.chainId
            let method = "eth_sendTransaction"
            let message = "hello world"
            let params = [`{
                    "data": "0x",
                    "from": "${testAddress}",
                    "to": "0x2",
                    "value": "0x12345"
                }`]
            let topic = "b536a"
            let session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            sdk.sessionRequestEvent(session)

            compare(sdk.getActiveSessionsCallbacks.length, 1, "expected DAppsRequestHandler call sdk.getActiveSessions")
            let callback = sdk.getActiveSessionsCallbacks[0].callback
            callback({"b536a": JSON.parse(Testing.formatApproveSessionResponse([chainId, 7], [testAddress]))})
            compare(handler.maxFeesUpdatedCalls.length, 1, "expected a call to handler.onMaxFeesUpdated")

            let args = handler.maxFeesUpdatedCalls[0]
            verify(args.ethMaxFees > 0, "expected ethMaxFees to be set")
            // storybook's CurrenciesStore mock up getFiatValue returns the balance
            compare(args.fiatMaxFees.toString(), args.ethMaxFees.toString(), "expected fiatMaxFees to be set")
            verify(args.haveEnoughFunds, "expected haveEnoughFunds to be set")
            compare(args.haveEnoughForFees, data.expect.haveEnoughForFees, "expected haveEnoughForFees to be set")
            verify(!!args.feesInfo, "expected feesInfo to be set")
        }
    }

    TestCase {
        id: walletConnectServiceTest
        name: "WalletConnectService"

        property WalletConnectService service: null

        SignalSpy {
            id: connectDAppSpy
            target: walletConnectServiceTest.service
            signalName: "connectDApp"

            property var argPos: {
                "dappChains": 0,
                "sessionProposalJson": 1,
                "availableNamespaces": 0
            }
        }

        readonly property SignalSpy sessionRequestSpy: SignalSpy {
            target: walletConnectServiceTest.service
            signalName: "sessionRequest"

            property var argPos: {
                "request": 0
            }
        }

        function init() {
            let walletStore = createTemporaryObject(walletStoreComponent, root)
            verify(!!walletStore)
            let sdk = createTemporaryObject(sdkComponent, root, { projectId: "12ab" })
            verify(!!sdk)
            let store = createTemporaryObject(dappsStoreComponent, root)
            verify(!!store)
            service = createTemporaryObject(serviceComponent, root, {wcSDK: sdk, store: store, walletRootStore: walletStore})
            verify(!!service)
        }

        function cleanup() {
            connectDAppSpy.clear()
            sessionRequestSpy.clear()
        }

        function testSetupPair(sessionProposalPayload) {
            let sdk = service.wcSDK
            let walletStore = service.walletRootStore
            let store = service.store

            service.pair("wc:12ab@1?bridge=https%3A%2F%2Fbridge.walletconnect.org&key=12ab")
            compare(sdk.pairCalled, 1, "expected a call to sdk.pair")

            sdk.sessionProposal(JSON.parse(sessionProposalPayload))
            compare(sdk.buildApprovedNamespacesCalls.length, 1, "expected a call to sdk.buildApprovedNamespaces")
            var args = sdk.buildApprovedNamespacesCalls[0]
            verify(!!args.supportedNamespaces, "expected supportedNamespaces to be set")

            // All calls to SDK are expected as events to be made by the wallet connect SDK
            let chainsForApproval = args.supportedNamespaces.eip155.chains
            let networksArray = ModelUtils.modelToArray(walletStore.filteredFlatModel).map(entry => entry.chainId)
            verify(networksArray.every(chainId => chainsForApproval.some(eip155Chain => eip155Chain === `eip155:${chainId}`)),
                "expect all the networks to be present")
            // We test here all accounts for one chain only, we have separate tests to validate that all accounts are present
            let allAccountsForApproval = args.supportedNamespaces.eip155.accounts
            let accountsArray = ModelUtils.modelToArray(walletStore.nonWatchAccounts).map(entry => entry.address)
            verify(accountsArray.every(address => allAccountsForApproval.some(eip155Address => eip155Address === `eip155:${networksArray[0]}:${address}`)),
                "expect at least all accounts for the first chain to be present"
            )

            return {sdk, walletStore, store, networksArray, accountsArray}
        }

        function test_TestPairing() {
            const {sdk, walletStore, store, networksArray, accountsArray} = testSetupPair(Testing.formatSessionProposal())

            let allApprovedNamespaces = JSON.parse(Testing.formatBuildApprovedNamespacesResult(networksArray, accountsArray))
            sdk.buildApprovedNamespacesResult(allApprovedNamespaces, "")
            compare(connectDAppSpy.count, 1, "expected a call to service.connectDApp")
            let connectArgs = connectDAppSpy.signalArguments[0]
            compare(connectArgs[connectDAppSpy.argPos.dappChains], networksArray, "expected all provided networks (walletStore.filteredFlatModel) for the dappChains")
            verify(!!connectArgs[connectDAppSpy.argPos.sessionProposalJson], "expected sessionProposalJson to be set")
            verify(!!connectArgs[connectDAppSpy.argPos.availableNamespaces], "expected availableNamespaces to be set")

            let selectedAccount = walletStore.nonWatchAccounts.get(1)
            service.approvePairSession(connectArgs[connectDAppSpy.argPos.sessionProposalJson], connectArgs[connectDAppSpy.argPos.dappChains], selectedAccount)
            compare(sdk.buildApprovedNamespacesCalls.length, 2, "expected a call to sdk.buildApprovedNamespaces")
            const approvedArgs = sdk.buildApprovedNamespacesCalls[1]
            verify(!!approvedArgs.supportedNamespaces, "expected supportedNamespaces to be set")
            // We test here that only one account for all chains is provided
            let accountsForApproval = approvedArgs.supportedNamespaces.eip155.accounts
            compare(accountsForApproval.length, networksArray.length, "expect only one account per chain")
            compare(accountsForApproval[0], `eip155:${networksArray[0]}:${selectedAccount.address}`)
            compare(accountsForApproval[1], `eip155:${networksArray[1]}:${selectedAccount.address}`)

            let approvedNamespaces = JSON.parse(Testing.formatBuildApprovedNamespacesResult(networksArray, [selectedAccount.address]))
            sdk.buildApprovedNamespacesResult(approvedNamespaces, "")

            compare(sdk.approveSessionCalls.length, 1, "expected a call to sdk.approveSession")
            verify(!!sdk.approveSessionCalls[0].sessionProposalJson, "expected sessionProposalJson to be set")
            verify(!!sdk.approveSessionCalls[0].approvedNamespaces, "expected approvedNamespaces to be set")

            let finalApprovedNamespaces = JSON.parse(Testing.formatApproveSessionResponse(networksArray, [selectedAccount.address]))
            sdk.approveSessionResult(finalApprovedNamespaces, "")
            verify(store.addWalletConnectSessionCalls.length === 1)
            verify(store.addWalletConnectSessionCalls[0].sessionJson, "expected sessionJson to be set")

            verify(service.onApproveSessionResultTriggers.length === 1)
            verify(service.onApproveSessionResultTriggers[0].session, "expected session to be set")

            compare(service.onDisplayToastMessageTriggers.length, 1, "expected a success message to be displayed")
            verify(!service.onDisplayToastMessageTriggers[0].error, "expected no error")
            verify(service.onDisplayToastMessageTriggers[0].message, "expected message to be set")
        }

        function test_TestPairingUnsupportedNetworks() {
            const {sdk, walletStore, store} = testSetupPair(Testing.formatSessionProposal())

            let allApprovedNamespaces = JSON.parse(Testing.formatBuildApprovedNamespacesResult([], []))
            sdk.buildApprovedNamespacesResult(allApprovedNamespaces, "")
            compare(connectDAppSpy.count, 0, "expected not to have calls to service.connectDApp")
            compare(service.onPairingValidatedTriggers.length, 1, "expected a call to service.onPairingValidated")
            compare(service.onPairingValidatedTriggers[0].validationState, Pairing.errors.unsupportedNetwork, "expected unsupportedNetwork state error")
        }

        function test_SessionRequestMainFlow() {
            // All calls to SDK are expected as events to be made by the wallet connect SDK
            const sdk = service.wcSDK
            const walletStore = service.walletRootStore
            const store = service.store

            const testAddress = "0x3a"
            const chainId = 2
            const  method = "personal_sign"
            const message = "hello world"
            const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${testAddress}"`]
            const topic = "b536a"
            const session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            // Expect to have calls to getActiveSessions from service initialization
            const prevRequests = sdk.getActiveSessionsCallbacks.length
            sdk.sessionRequestEvent(session)

            compare(sdk.getActiveSessionsCallbacks.length, prevRequests + 1, "expected DAppsRequestHandler call sdk.getActiveSessions")
            const callback = sdk.getActiveSessionsCallbacks[prevRequests].callback
            callback({"b536a": JSON.parse(Testing.formatApproveSessionResponse([chainId, 7], [testAddress]))})

            compare(sessionRequestSpy.count, 1, "expected service.sessionRequest trigger")
            const request = sessionRequestSpy.signalArguments[0][sessionRequestSpy.argPos.request]
            compare(request.topic, topic, "expected topic to be set")
            compare(request.method, method, "expected method to be set")
            compare(request.event, session, "expected event to be the one sent by the sdk")
            compare(request.dappName, Testing.dappName, "expected dappName to be set")
            compare(request.dappUrl, Testing.dappUrl, "expected dappUrl to be set")
            compare(request.dappIcon, Testing.dappFirstIcon, "expected dappIcon to be set")
            verify(!!request.account, "expected account to be set")
            compare(request.account.address, testAddress, "expected look up of the right account")
            verify(!!request.network, "expected network to be set")
            compare(request.network.chainId, chainId, "expected look up of the right network")
            verify(!!request.data, "expected data to be set")
            compare(request.data.message, message, "expected message to be set")
        }



        // TODO #14757: add tests with multiple session requests coming in; validate that authentication is serialized and in order
        // function tst_SessionRequestQueueMultiple() {
        // }
    }

    Component {
        id: dappsListProviderComponent
        DAppsListProvider {
        }
    }

    TestCase {
        name: "DAppsListProvider"

        property DAppsListProvider provider: null

        readonly property var dappsListReceivedJsonStr: '[{"url":"https://tst1.com","name":"name1","iconUrl":"https://tst1.com/u/1"},{"url":"https://tst2.com","name":"name2","iconUrl":"https://tst2.com/u/2"}]'

        function init() {
            // Simulate the SDK not being ready
            let sdk = createTemporaryObject(sdkComponent, root, {projectId: "12ab", sdkReady: false})
            verify(!!sdk)
            let store = createTemporaryObject(dappsStoreComponent, root, {
                dappsListReceivedJsonStr: dappsListReceivedJsonStr
            })
            verify(!!store)
            const walletStore = createTemporaryObject(walletStoreComponent, root)
            verify(!!walletStore)
            provider = createTemporaryObject(dappsListProviderComponent, root, {sdk: sdk, store: store, supportedAccountsModel: walletStore.nonWatchAccounts})
            verify(!!provider)
        }

        function cleanup() {
        }

        // Implemented as a regression to metamask not having icons which failed dapps list
        function test_TestUpdateDapps() {
            provider.updateDapps()

            // Validate that persistance fallback is working
            compare(provider.dappsModel.count, 2, "expected dappsModel have the right number of elements")
            let persistanceList = JSON.parse(dappsListReceivedJsonStr)
            compare(provider.dappsModel.get(0).url, persistanceList[0].url, "expected url to be set")
            compare(provider.dappsModel.get(0).iconUrl, persistanceList[0].iconUrl, "expected iconUrl to be set")
            compare(provider.dappsModel.get(1).name, persistanceList[1].name, "expected name to be set")

            // Validate that SDK's `getActiveSessions` is not called if not ready
            let sdk = provider.sdk
            compare(sdk.getActiveSessionsCallbacks.length, 0, "expected no calls to sdk.getActiveSessions yet")
            sdk.sdkReady = true
            compare(sdk.getActiveSessionsCallbacks.length, 1, "expected a call to sdk.getActiveSessions when SDK becomes ready")
            let callback = sdk.getActiveSessionsCallbacks[0].callback
            const address = ModelUtils.get(provider.supportedAccountsModel, 0, "address")
            let session = JSON.parse(Testing.formatApproveSessionResponse([1, 2], [address], {dappMetadataJsonString: Testing.noIconsDappMetadataJsonString}))
            callback({"b536a": session, "b537b": session})
            compare(provider.dappsModel.count, 1, "expected dappsModel have the SDK's reported dapp, 2 sessions of the same dApp per 2 wallet account, meaning 1 dApp model entry")
            compare(provider.dappsModel.get(0).iconUrl, "", "expected iconUrl to be missing")
            let updateCalls = provider.store.updateWalletConnectSessionsCalls
            compare(updateCalls.length, 1, "expected a call to store.updateWalletConnectSessions")
            verify(updateCalls[0].activeTopicsJson.includes("b536a"))
            verify(updateCalls[0].activeTopicsJson.includes("b537b"))
        }
    }

    TestCase {
        name: "ServiceHelpers"

        function test_extractChainsAndAccountsFromApprovedNamespaces() {
            const res = DAppsHelpers.extractChainsAndAccountsFromApprovedNamespaces(JSON.parse(`{
                "eip155": {
                    "accounts": [
                        "eip155:1:0x1",
                        "eip155:1:0x2",
                        "eip155:2:0x1",
                        "eip155:2:0x2"
                    ],
                    "chains": [
                        "eip155:1",
                        "eip155:2"
                    ],
                    "events": [
                        "accountsChanged",
                        "chainChanged"
                    ],
                    "methods": [
                        "eth_sendTransaction",
                        "personal_sign"
                    ]
                }
            }`))
            verify(res.chains.length === 2)
            verify(res.accounts.length === 2)
            verify(res.chains[0] === 1)
            verify(res.chains[1] === 2)
            verify(res.accounts[0] === "0x1")
            verify(res.accounts[1] === "0x2")
        }

        readonly property ListModel chainsModel: ListModel {
            ListElement { chainId: 1 }
            ListElement { chainId: 2 }
        }

        readonly property ListModel accountsModel: ListModel {
            ListElement { address: "0x1" }
            ListElement { address: "0x2" }
        }

        function test_buildSupportedNamespacesFromModels() {
            const methods = ["eth_sendTransaction", "personal_sign"]
            const resStr = DAppsHelpers.buildSupportedNamespacesFromModels(chainsModel, accountsModel, methods)
            const jsonObj = JSON.parse(resStr)
            verify(jsonObj.hasOwnProperty("eip155"))
            const eip155 = jsonObj.eip155

            verify(eip155.hasOwnProperty("chains"))
            const chains = eip155.chains
            verify(chains.length === 2)
            verify(chains[0] === "eip155:1")
            verify(chains[1] === "eip155:2")

            verify(eip155.hasOwnProperty("accounts"))
            const accounts = eip155.accounts
            verify(accounts.length === 4)
            for (let chainI = 0; chainI < chainsModel.count; chainI++) {
                for (let accountI = 0; accountI < chainsModel.count; accountI++) {
                    var found = false
                    for (const entry of accounts) {
                        if(entry === `eip155:${chainsModel.get(chainI).chainId}:${accountsModel.get(accountI).address}`) {
                            found = true
                            break
                        }
                    }
                    verify(found, `found ${accountsModel.get(accountI).address} for chain ${chainsModel.get(chainI).chainId}`)
                }
            }

            verify(eip155.hasOwnProperty("methods"))
            verify(eip155.methods.length > 0)
            verify(eip155.hasOwnProperty("events"))
            compare(eip155.events.length, 2)
        }

        function test_getAccountsInSession() {
            const account1 = accountsModel.get(0)
            const account2 = accountsModel.get(1)
            const chainIds = [chainsModel.get(0).chainId, chainsModel.get(1).chainId]

            const oneAccountSession = JSON.parse(Testing.formatApproveSessionResponse(chainIds, [account2.address]))
            const twoAccountsSession = JSON.parse(Testing.formatApproveSessionResponse(chainIds, ['0x03acc', account1.address]))
            const duplicateAccountsSession = JSON.parse(Testing.formatApproveSessionResponse(chainIds, ['0x83acb', '0x83acb']))

            const res = DAppsHelpers.getAccountsInSession(oneAccountSession)
            compare(res.length, 1, "expected the only account to be returned")
            compare(res[0], account2.address, "expected the only account to be the one in the session")

            const res2 = DAppsHelpers.getAccountsInSession(twoAccountsSession)
            compare(res2.length, 2, "expected the two accounts to be returned")
            compare(res2[0], '0x03acc', "expected the first account to be the one in the session")
            compare(res2[1], account1.address, "expected the second account to be the one in the session")

            const res3 = DAppsHelpers.getAccountsInSession(duplicateAccountsSession)
            compare(res3.length, 1, "expected the only account to be returned")
            compare(res3[0], '0x83acb', "expected the duplicated account")
        }
    }

    Component {
        id: componentUnderTest
        DAppsWorkflow {
            loginType: Constants.LoginType.Password
        }
    }

    // TODO #15151: this TestCase if placed before ServiceHelpers was not run with `when: windowShown`. Check if related to the CI crash
    TestCase {
        id: dappsWorkflowTest

        name: "DAppsWorkflow"
        when: windowShown

        property DAppsWorkflow controlUnderTest: null

        SignalSpy {
            id: dappsListReadySpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "dappsListReady"
        }

        SignalSpy {
            id: pairWCReadySpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "pairWCReady"
        }

        function init() {
            let walletStore = createTemporaryObject(walletStoreComponent, root)
            verify(!!walletStore)
            let sdk = createTemporaryObject(sdkComponent, root, { projectId: "12ab" })
            verify(!!sdk)
            let store = createTemporaryObject(dappsStoreComponent, root)
            verify(!!store)
            let service = createTemporaryObject(serviceComponent, root, {wcSDK: sdk, store: store, walletRootStore: walletStore})
            verify(!!service)
            controlUnderTest = createTemporaryObject(componentUnderTest, root, {wcService: service})
            verify(!!controlUnderTest)
        }

        function cleanup() {
            dappsListReadySpy.clear()
            pairWCReadySpy.clear()
        }

        function test_OpenAndCloseDappList() {
            waitForRendering(controlUnderTest)

            compare(dappsListReadySpy.count, 0, "expected NO dappsListReady signal to be emitted")
            mouseClick(controlUnderTest)
            waitForRendering(controlUnderTest)
            compare(dappsListReadySpy.count, 1, "expected dappsListReady signal to be emitted")

            let popup = findChild(controlUnderTest, "dappsListPopup")
            verify(!!popup)
            verify(popup.opened)

            popup.close()
            waitForRendering(controlUnderTest)

            verify(!popup.opened)
        }

        function test_OpenPairModal() {
            waitForRendering(controlUnderTest)

            mouseClick(controlUnderTest)
            waitForRendering(controlUnderTest)

            let popup = findChild(controlUnderTest, "dappsListPopup")
            verify(!!popup)
            verify(popup.opened)

            let connectButton = findChild(popup, "connectDappButton")
            verify(!!connectButton)

            verify(pairWCReadySpy.count === 0, "expected NO pairWCReady signal to be emitted")
            mouseClick(connectButton)
            waitForRendering(controlUnderTest)
            verify(pairWCReadySpy.count === 1, "expected pairWCReady signal to be emitted")

            let pairWCModal = findChild(controlUnderTest, "pairWCModal")
            verify(!!pairWCModal)
        }

        Component {
            id: sessionRequestComponent

            SessionRequestResolved {
            }
        }

        function test_OpenDappRequestModal() {
            waitForRendering(controlUnderTest)

            let service = controlUnderTest.wcService
            let td = mockSessionRequestEvent(this, service.wcSDK, service.walletRootStore.nonWatchAccounts, service.walletRootStore.filteredFlatModel)

            waitForRendering(controlUnderTest)
            let popup = findChild(controlUnderTest, "dappsRequestModal")
            verify(!!popup)
            verify(popup.opened)
            verify(popup.visible)

            compare(popup.dappName, td.session.peer.metadata.name)
            compare(popup.accountName, td.account.name)
            compare(popup.accountAddress, td.account.address)
            compare(popup.networkName, td.network.chainName)

            popup.close()
            waitForRendering(controlUnderTest)
            verify(!popup.opened)
            verify(!popup.visible)
        }

        function showRequestModal() {
            waitForRendering(controlUnderTest)

            let service = controlUnderTest.wcService
            let td = mockSessionRequestEvent(this, service.wcSDK, service.walletRootStore.nonWatchAccounts, service.walletRootStore.filteredFlatModel)

            waitForRendering(controlUnderTest)
            td.popup = findChild(controlUnderTest, "dappsRequestModal")
            verify(td.popup.opened)
            return td
        }

        function test_RejectDappRequestModal() {
            let td = showRequestModal()

            let rejectButton = findChild(td.popup, "rejectButton")

            mouseClick(rejectButton)
            compare(td.sdk.rejectSessionRequestCalls.length, 1, "expected a call to service.rejectSessionRequest")
            compare(td.sdk.acceptSessionRequestCalls.length, 0, "expected no call to service.acceptSessionRequest")
            let store = controlUnderTest.wcService.store
            compare(store.authenticateUserCalls.length, 0, "expected no call to store.authenticateUser for rejection")
            let args = td.sdk.rejectSessionRequestCalls[0]
            compare(args.topic, td.topic, "expected topic to be set")
            compare(args.id, td.request.id, "expected id to be set")
            compare(args.error, false, "expected no error; it was user rejected")

            waitForRendering(controlUnderTest)
            verify(!td.popup.opened)
            verify(!td.popup.visible)
        }

        function test_AcceptDappRequestModal() {
            let td = showRequestModal()

            let signButton = findChild(td.popup, "signButton")

            mouseClick(signButton)
            let store = controlUnderTest.wcService.store
            compare(store.authenticateUserCalls.length, 1, "expected a call to store.authenticateUser")
            compare(td.sdk.rejectSessionRequestCalls.length, 0, "regression, expected no call to service.rejectSessionRequest")

            waitForRendering(controlUnderTest)
            verify(!td.popup.opened)
            verify(!td.popup.visible)
        }
    }

    function mockSessionRequestEvent(tc, sdk, accountsModel, networksModel) {
        const account = accountsModel.get(1)
        const network = networksModel.get(1)
        const method = "personal_sign"
        const message = "hello world"
        const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${account.address}"`]
        const topic = "b536a"
        const requestEvent = JSON.parse(Testing.formatSessionRequest(network.chainId, method, params, topic))
        const request = tc.createTemporaryObject(sessionRequestComponent, root, {
              event: requestEvent,
              topic,
              id: requestEvent.id,
              method: Constants.personal_sign,
              account,
              network,
              data: message,
              preparedData: message
        })
        // Expect to have calls to getActiveSessions from service initialization
        const prevRequests = sdk.getActiveSessionsCallbacks.length
        sdk.sessionRequestEvent(requestEvent)
        // Service might trigger a sessionRequest event following the getActiveSessions call
        const callback = sdk.getActiveSessionsCallbacks[prevRequests].callback
        const session = JSON.parse(Testing.formatApproveSessionResponse([network.chainId, 7], [account.address]))
        callback({"b536a": session})

        return {sdk, session, account, network, topic, request}
    }
}
