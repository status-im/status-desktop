import QtQuick 2.15

import QtTest 1.15
import "helpers/wallet_connect.js" as Testing

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

    function mockSessionRequestEvent(tc, sdk, accountsModel, networksModel) {
        const account = accountsModel.get(1)
        const network = networksModel.get(1)
        const topic = "b536a"
        const requestId = 1717149885151715
        const request = buildSessionRequestResolved(tc, account.address, network.chainId, topic, requestId)
        // Expect to have calls to getActiveSessions from service initialization
        const prevRequests = sdk.getActiveSessionsCallbacks.length
        sdk.sessionRequestEvent(request.event)
        // Service might trigger a sessionRequest event following the getActiveSessions call
        const callback = sdk.getActiveSessionsCallbacks[prevRequests].callback
        const session = JSON.parse(Testing.formatApproveSessionResponse([network.chainId, 7], [account.address]))
        callback({"b536a": session})

        return {sdk, session, account, network, topic, request}
    }

    function buildSessionRequest(chainId, method, params, topic, requestId) {
        return JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic, requestId))
    }

    function buildSessionRequestResolved(testCase, account, network, topic, requestId) {
        const requestObj = buildSessionRequest(network, Constants.personal_sign, [`"${DAppsHelpers.strToHex("hello world")}"`, `"${account}"`], topic, requestId)
        const requestItem = testCase.createTemporaryObject(sessionRequestComponent, root, {
            event: requestObj,
            topic,
            requestId: requestObj.id,
            method: Constants.personal_sign,
            accountAddress: account,
            chainId: network,
            data: "hello world",
            preparedData: "hello world",
            expirationTimestamp: (Date.now() + 10000) / 1000,
            sourceId: Constants.DAppConnectors.WalletConnect
        })

        requestItem.resolveDappInfoFromSession({peer: {metadata: {name: "Test DApp", url: "https://test.dapp", icons: ["data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB0AAAAcCAYAAACdz7SqAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAM2SURBVHgBtVbNbtNAEJ7ZpBQ4pRGF9kQqWqkBRNwnwLlxI9y4NX2CiiOntE9QeINw49a8QdwT3NhKQCKaSj4WUVXmABRqe5hxE+PGTuyk5ZOSXe/ftzs/3y5CBiw/NEzw/cdAaCJAifgXdCA4QGAjggbEvbMf0LJt7aSth6lkHjW4akIG8GI2/1k5H7e7XW2PGRdHqWQU8jdoNytZIrnC7YNPupnUnxtuWF01SjhD77hqwPQosNlrxdt34OTb172xpELoKvrA1QW4EqCZRJyLEnpI7ZBQggThlGvXYVLI3HAeE88vfj85Pno/6FaDiqeoEUZlMA9bvc/7cxyxVa6/SeM5j2Tcdn/hnHsNly520s7KAyN0V17+7pWNGhHVhxYJTNLraosLi8e0kMBxT0FH00IW830oeT/ButBertjRQ5BPO1xUQ1IE2oQUHHZ0K6mdI1RzoSEdpqRg76O2lPgSElKDdz919JYMoxA95QDow7qUykWoxTo5z2YIXsGUsLV2CPD1cDu7MODiQKKnsVmI1jhFyQJvFrb6URxFQWJAYYIZSEF6tKZATitFQpehEm1PkCraWYCE+8Nt5ENBwX8EAd2NNaKQxu0ukVuCqwATQHwnjhphShMuiSAVKZ527E6bzYt78Q3SulxvcAm44K8ntXMqagmkJDUpzNwMZGsqBDqLuDXcLvkvqajcWWgm+ZUI6svlym5fsbITlh9tsgi0Ezs5//vkMtBocqSJOZw84ZrHPiXFJ6UwECx5A/FbqNXX2hAiefkzqCNRha1Wi8yJgddeCk4qHzkK1aMgdypfshYRbkTGm3z0Rs6LW0REgDXVEMuMI0TE5kDlgkv8+PjIKRYXfzPxEyH2EYzDzv7L4q1FHsvpg8Gkt186OlGp5uYXZMjzkYS8txwfQnj63//APmzDIF1yWJVrCDJgeZVfjTjCj0KicC3qlny0053FZ/k/PFnyy6P2yv1Kk1T/1eCGF/pEYCncGI6DCzIo/uGnRvg8CfzE5MEPoQGT4Pz5Uj3oxp+hMe0V4oOOrssOMfmWyMJo5X1cG2WZkYIvO2Tn85sGXwg5B5Q9kiKMas5DntPr6Oq4+/gvs8hkkbAzoC8AAAAASUVORK5CYII="]}}})
        return requestItem
    }

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
            buildApprovedNamespaces: function(id, params, supportedNamespaces) {
                buildApprovedNamespacesCalls.push({id, params, supportedNamespaces})
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
            onDisplayToastMessage: function(message, type) {
                onDisplayToastMessageTriggers.push({message, type})
            }

            property var onPairingValidatedTriggers: []
            onPairingValidated: function(validationState) {
                onPairingValidatedTriggers.push({validationState})
            }
            blockchainNetworksDown: []
        }
    }

    Component {
        id: dappsStoreComponent

        DAppsStore {
            property string dappsListReceivedJsonStr: '[]'

            signal dappsListReceived(string dappsJson)
            signal userAuthenticated(string topic, string id, string password, string pin)
            signal userAuthenticationFailed(string topic, string id)
            signal signingResult(string topic, string id, string data)

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
                    chainId: 421614
                    layer: 2
                }
            }

            readonly property ListModel filteredFlatModelWithOnlineStat: ListModel {
                ListElement {
                    chainId: 1
                    layer: 1
                    isOnline: true
                }
                ListElement {
                    chainId: 2
                    chainName: "Test Chain"
                    iconUrl: "network/Network=Ethereum"
                    layer: 2
                    isOnline: true
                }
                // Used by tst_balanceCheck
                ListElement {
                    chainId: 11155111
                    layer: 1
                    isOnline: true
                }
                // Used by tst_balanceCheck
                ListElement {
                    chainId: 421613
                    layer: 2
                    isOnline: true
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

            readonly property var currencyStore: CurrenciesStore {}
            readonly property var walletAssetsStore: assetsStoreMock
            readonly property string selectedAddress: "0x1"
        }
    }

    Component {
        id: sessionRequestComponent

        SessionRequestResolved {
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
                networksModel: walletStore.filteredFlatModelWithOnlineStat
            })
            verify(!!handler)
            sdk.getActiveSessionsCallbacks = []
        }

        function cleanup() {
            displayToastMessageSpy.clear()
        }

        function test_TestAuthentication() {
            let td = mockSessionRequestEvent(this, handler.sdk, handler.accountsModel, handler.networksModel)
            handler.sdk.sessionRequestEvent(td.request.event)
            let request = handler.requestsModel.findById(td.request.requestId)
            request.accept()
            compare(handler.store.authenticateUserCalls.length, 1, "expected a call to store.authenticateUser")

            let store = handler.store
            store.userAuthenticated(td.topic, td.request.requestId, "hello world", "")
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
                    fee: "0.0000231"
                }
            },
            {
                tag: "doest_have_enough_funds",
                chainId: 11155111,
                // Override the suggestedFees to a higher value
                maxFeePerGasM: 1000000.0, /*GWEI*/

                expect: {
                    haveEnoughForFees: false,
                    fee: "21"
                }
            },
            {
                tag: "check_l2_doesnt_have_enough_funds_on_l1",
                chainId: 421614,
                // Override the l1 additional fees
                l1GasFee: 1000000000.0,

                expect: {
                    haveEnoughForFees: false,
                    fee: "1.0000231"
                }
            },
            {
                tag: "check_l2_doesnt_have_enough_funds_on_l2",
                chainId: 421614,
                // Override the l2 to a higher value
                maxFeePerGasM: 1000000.0, /*GWEI*/
                // Override the l1 additional fees
                l1GasFee: 10.0,

                expect: {
                    haveEnoughForFees: false,
                    fee: "21.00000001"
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

            let request = handler.requestsModel.findById(session.id)
            verify(!!request, "expected request to be found")
            compare(request.fiatMaxFees.toFixed(), data.expect.fee, "expected ethMaxFees to be set")
            // storybook's CurrenciesStore mock up getFiatValue returns the balance
            compare(request.ethMaxFees, data.expect.fee, "expected fiatMaxFees to be set")
            verify(request.haveEnoughFunds, "expected haveEnoughFunds to be set")
            compare(request.haveEnoughFees, data.expect.haveEnoughForFees, "expected haveEnoughForFees to be set")
            verify(!!request.feesInfo, "expected feesInfo to be set")
        }

        function test_sessionRequestExpiryInTheFuture() {
            const sdk = handler.sdk
            const testAddressUpper = "0x3A"
            const chainId = 2
            const method = "personal_sign"
            const message = "hello world"
            const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${testAddressUpper}"`]
            const topic = "b536a"
            const session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))

            verify(session.params.request.expiryTimestamp > Date.now() / 1000, "expected expiryTimestamp to be in the future")

            // Expect to have calls to getActiveSessions from service initialization
            const prevRequests = sdk.getActiveSessionsCallbacks.length
            sdk.sessionRequestEvent(session)

            verify(handler.requestsModel.count === 1, "expected a request to be added")
            const request = handler.requestsModel.findRequest(topic, session.id)
            verify(!!request, "expected request to be found")
            verify(!request.isExpired(), "expected request to not be expired")
        }

        function test_sessionRequestExpiryInThePast()
        {
            const sdk = handler.sdk
            const testAddressUpper = "0x3A"
            const chainId = 2
            const method = "personal_sign"
            const message = "hello world"
            const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${testAddressUpper}"`]
            const topic = "b536a"
            const session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            session.params.request.expiryTimestamp = (Date.now() - 10000) / 1000

            verify(session.params.request.expiryTimestamp < Date.now() / 1000, "expected expiryTimestamp to be in the past")

            sdk.sessionRequestEvent(session)

            verify(handler.requestsModel.count === 1, "expected a request to be added")
            const request = handler.requestsModel.findRequest(topic, session.id)
            verify(!!request, "expected request to be found")
            verify(request.isExpired(), "expected request to be expired")
            verify(displayToastMessageSpy.count === 0, "no toast message should be displayed")
        }

        function test_wcSignalsSessionRequestExpiry()
        {
            const sdk = handler.sdk
            const testAddressUpper = "0x3A"
            const chainId = 2
            const method = "personal_sign"
            const message = "hello world"
            const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${testAddressUpper}"`]
            const topic = "b536a"
            const session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))

            verify(session.params.request.expiryTimestamp > Date.now() / 1000, "expected expiryTimestamp to be in the future")
            sdk.sessionRequestEvent(session)
            const request = handler.requestsModel.findRequest(topic, session.id)
            verify(!!request, "expected request to be found")
            verify(!request.isExpired(), "expected request to not be expired")

            sdk.sessionRequestExpired(session.id)
            verify(request.isExpired(), "expected request to be expired")
            verify(displayToastMessageSpy.count === 0, "no toast message should be displayed")
        }

        function test_acceptExpiredSessionRequest()
        {
            const sdk = handler.sdk
            const testAddressUpper = "0x3A"
            const chainId = 2
            const method = "personal_sign"
            const message = "hello world"
            const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${testAddressUpper}"`]
            const topic = "b536a"
            const session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            session.params.request.expiryTimestamp = (Date.now() - 10000) / 1000

            verify(session.params.request.expiryTimestamp < Date.now() / 1000, "expected expiryTimestamp to be in the past")

            sdk.sessionRequestEvent(session)

            verify(handler.requestsModel.count === 1, "expected a request to be added")
            const request = handler.requestsModel.findRequest(topic, session.id)
            request.resolveDappInfoFromSession({peer: {metadata: {name: "Test DApp", url: "https://test.dapp", icons:[]}}})
            verify(!!request, "expected request to be found")
            verify(request.isExpired(), "expected request to be expired")
            verify(sdk.rejectSessionRequestCalls.length === 0, "expected no call to sdk.rejectSessionRequest")

            ignoreWarning("Error: request expired")
            request.accept()
            handler.store.userAuthenticated(topic, session.id, "1234", "", message)
            verify(sdk.rejectSessionRequestCalls.length === 1, "expected a call to sdk.rejectSessionRequest")
            sdk.sessionRequestUserAnswerResult(topic, session.id, false, "")
            verify(displayToastMessageSpy.count === 1, "expected a toast message to be displayed")
            compare(displayToastMessageSpy.signalArguments[0][0], "test.dapp sign request timed out")
        }

        function test_rejectExpiredSessionRequest()
        {
            const sdk = handler.sdk
            const testAddressUpper = "0x3A"
            const chainId = 2
            const method = "personal_sign"
            const message = "hello world"
            const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${testAddressUpper}"`]
            const topic = "b536a"
            const session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            session.params.request.expiryTimestamp = (Date.now() - 10000) / 1000

            verify(session.params.request.expiryTimestamp < Date.now() / 1000, "expected expiryTimestamp to be in the past")

            sdk.sessionRequestEvent(session)

            verify(sdk.rejectSessionRequestCalls.length === 0, "expected no call to sdk.rejectSessionRequest")

            ignoreWarning("Error: request expired")
            handler.requestsModel.findRequest(topic, session.id).accept()
            handler.store.userAuthenticationFailed(topic, session.id)
            verify(sdk.rejectSessionRequestCalls.length === 1, "expected a call to sdk.rejectSessionRequest")
        }

        function test_signFailedAuthOnExpiredRequest()
        {
            const sdk = handler.sdk
            const testAddressUpper = "0x3A"
            const chainId = 2
            const method = "personal_sign"
            const message = "hello world"
            const params = [`"${DAppsHelpers.strToHex(message)}"`, `"${testAddressUpper}"`]
            const topic = "b536a"
            const session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            session.params.request.expiryTimestamp = (Date.now() - 10000) / 1000

            verify(session.params.request.expiryTimestamp < Date.now() / 1000, "expected expiryTimestamp to be in the past")

            sdk.sessionRequestEvent(session)

            verify(sdk.rejectSessionRequestCalls.length === 0, "expected no call to sdk.rejectSessionRequest")

            ignoreWarning("Error: request expired")
            handler.requestsModel.findRequest(topic, session.id).accept()
            handler.store.userAuthenticationFailed(topic, session.id)
            verify(sdk.rejectSessionRequestCalls.length === 1, "expected a call to sdk.rejectSessionRequest")
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
                "dappUrl": 1,
                "dappName": 2,
                "dappIcon": 3,
                "key": 4,
            }
        }

        readonly property SignalSpy sessionRequestSpy: SignalSpy {
            target: walletConnectServiceTest.service
            signalName: "sessionRequest"

            property var argPos: {
                "id": 0
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

            compare(sdk.buildApprovedNamespacesCalls.length, 1, "expected a call to sdk.buildApprovedNamespaces")
            let allApprovedNamespaces = JSON.parse(Testing.formatBuildApprovedNamespacesResult(networksArray, accountsArray))
            sdk.buildApprovedNamespacesResult(sdk.buildApprovedNamespacesCalls[0].id, allApprovedNamespaces, "")
            compare(connectDAppSpy.count, 1, "expected a call to service.connectDApp")
            let connectArgs = connectDAppSpy.signalArguments[0]

            compare(connectArgs[connectDAppSpy.argPos.dappChains], networksArray, "expected all provided networks (walletStore.filteredFlatModel) for the dappChains")
            compare(connectArgs[connectDAppSpy.argPos.dappUrl], Testing.dappUrl, "expected dappUrl to be set")
            compare(connectArgs[connectDAppSpy.argPos.dappName], Testing.dappName, "expected dappName to be set")
            compare(connectArgs[connectDAppSpy.argPos.dappIcon], Testing.dappFirstIcon, "expected dappIcon to be set")
            verify(!!connectArgs[connectDAppSpy.argPos.key], "expected key to be set")

            let selectedAccount = walletStore.nonWatchAccounts.get(1).address
            service.approvePairSession(connectArgs[connectDAppSpy.argPos.key], connectArgs[connectDAppSpy.argPos.dappChains], selectedAccount)
            compare(sdk.buildApprovedNamespacesCalls.length, 2, "expected a call to sdk.buildApprovedNamespaces")
            const approvedArgs = sdk.buildApprovedNamespacesCalls[1]
            verify(!!approvedArgs.supportedNamespaces, "expected supportedNamespaces to be set")
            // We test here that only one account for all chains is provided
            let accountsForApproval = approvedArgs.supportedNamespaces.eip155.accounts
            compare(accountsForApproval.length, networksArray.length, "expect only one account per chain")
            compare(accountsForApproval[0], `eip155:${networksArray[0]}:${selectedAccount}`)
            compare(accountsForApproval[1], `eip155:${networksArray[1]}:${selectedAccount}`)

            let approvedNamespaces = JSON.parse(Testing.formatBuildApprovedNamespacesResult(networksArray, [selectedAccount]))
            sdk.buildApprovedNamespacesResult(approvedArgs.id, approvedNamespaces, "")

            compare(sdk.approveSessionCalls.length, 1, "expected a call to sdk.approveSession")
            verify(!!sdk.approveSessionCalls[0].sessionProposalJson, "expected sessionProposalJson to be set")
            verify(!!sdk.approveSessionCalls[0].approvedNamespaces, "expected approvedNamespaces to be set")

            let finalApprovedNamespaces = JSON.parse(Testing.formatApproveSessionResponse(networksArray, [selectedAccount.address]))
            sdk.approveSessionResult(connectArgs[connectDAppSpy.argPos.key], finalApprovedNamespaces, "")
            verify(store.addWalletConnectSessionCalls.length === 1)
            verify(store.addWalletConnectSessionCalls[0].sessionJson, "expected sessionJson to be set")

            verify(service.onApproveSessionResultTriggers.length === 1)
            verify(service.onApproveSessionResultTriggers[0].session, "expected session to be set")

            compare(service.onDisplayToastMessageTriggers.length, 1, "expected a success message to be displayed")
            verify(service.onDisplayToastMessageTriggers[0].type !== Constants.ephemeralNotificationType.danger, "expected no error")
            verify(service.onDisplayToastMessageTriggers[0].message, "expected message to be set")
        }

        function test_TestPairingUnsupportedNetworks() {
            const {sdk, walletStore, store} = testSetupPair(Testing.formatSessionProposal())

            const approvedArgs = sdk.buildApprovedNamespacesCalls[0]
            sdk.buildApprovedNamespacesResult(approvedArgs.id, {}, "Non conforming namespaces. approve() namespaces chains don't satisfy required namespaces")
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
            const chainId = "2"
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
            const requestId = sessionRequestSpy.signalArguments[0][sessionRequestSpy.argPos.id]
            const request = service.sessionRequestsModel.findById(requestId)
            verify(!!request, "expected request to be found")
            compare(request.topic, topic, "expected topic to be set")
            compare(request.method, method, "expected method to be set")
            compare(request.event, session, "expected event to be the one sent by the sdk")
            compare(request.dappName, Testing.dappName, "expected dappName to be set")
            compare(request.dappUrl, Testing.dappUrl, "expected dappUrl to be set")
            compare(request.dappIcon, Testing.dappFirstIcon, "expected dappIcon to be set")
            verify(!!request.accountAddress, "expected account to be set")
            compare(request.accountAddress, testAddress, "expected look up of the right account")
            verify(!!request.chainId, "expected network to be set")
            compare(request.chainId, chainId, "expected look up of the right network")
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
            sdk.getActiveSessionsCallbacks = []
        }

        function cleanup() {
        }

        // Implemented as a regression to metamask not having icons which failed dapps list
        function test_TestUpdateDapps() {
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
            compare(eip155.events.length, 5)
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
            model: ListModel {}
            accountsModel: ListModel {}
            networksModel: ListModel {}
            sessionRequestsModel: SessionRequestsModel {}
            selectedAccountAddress: ""
            formatBigNumber: (number, symbol, noSymbolOption) => number + symbol
        }
    }

    // TODO #15151: this TestCase if placed before ServiceHelpers was not run with `when: windowShown`. Check if related to the CI crash
    TestCase {
        id: dappsWorkflowTest

        name: "DAppsWorkflow"
        when: windowShown

        property DAppsWorkflow controlUnderTest: null

        SignalSpy {
            id: pairWCReadySpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "pairWCReady"
        }

        SignalSpy {
            id: disconnectRequestedSpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "disconnectRequested"
        }

        SignalSpy {
            id: pairingRequestedSpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "pairingRequested"
        }

        SignalSpy {
            id: pairingValidationRequestedSpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "pairingValidationRequested"
        }

        SignalSpy {
            id: connectionAcceptedSpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "connectionAccepted"
        }

        SignalSpy {
            id: connectionDeclinedSpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "connectionDeclined"
        }

        SignalSpy {
            id: signRequestAcceptedSpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "signRequestAccepted"
        }

        SignalSpy {
            id: signRequestRejectedSpy
            target: dappsWorkflowTest.controlUnderTest
            signalName: "signRequestRejected"
        }

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)
        }

        function cleanup() {
            pairWCReadySpy.clear()
            disconnectRequestedSpy.clear()
            pairingRequestedSpy.clear()
            pairingValidationRequestedSpy.clear()
            connectionAcceptedSpy.clear()
            connectionDeclinedSpy.clear()
            signRequestAcceptedSpy.clear()
            signRequestRejectedSpy.clear()
        }

        function test_OpenAndCloseDappList() {
            waitForRendering(controlUnderTest)

            mouseClick(controlUnderTest)
            waitForRendering(controlUnderTest)
            let popup = findChild(controlUnderTest, "dappsListPopup")
            verify(!!popup)
            verify(popup.opened)

            popup.close()
            waitForRendering(controlUnderTest)
            verify(!popup.opened)
        }

        function openPairModal() {
            waitForRendering(controlUnderTest)

            mouseClick(controlUnderTest)

            let popup = findChild(controlUnderTest, "dappsListPopup")
            verify(!!popup)
            verify(popup.opened)

            let connectButton = findChild(popup, "connectDappButton")
            verify(!!connectButton)

            mouseClick(connectButton)
            const btnWalletConnect = findChild(controlUnderTest, "btnWalletConnect")
            verify(!!btnWalletConnect)
            mouseClick(btnWalletConnect)

            verify(pairWCReadySpy.count === 1, "expected pairWCReady signal to be emitted")

            let pairWCModal = findChild(controlUnderTest, "pairWCModal")
            verify(!!pairWCModal)
            return pairWCModal
        }

        function test_OpenPairModal() {
            const pairWCModal = openPairModal()
        }

        function test_uriPairingSuccess() {
            const pairWCModal = openPairModal()
            //type: test url
            keyClick("a")
            keyClick("b")
            keyClick("c")
            keyClick("d")

            compare(pairingValidationRequestedSpy.count, 4, "expected pairingValidationRequested signal to be emitted")
            controlUnderTest.pairingValidated(Pairing.errors.uriOk)
            compare(pairingRequestedSpy.count, 1, "expected pairingRequested signal to be emitted")
        }

        function test_uriPairingFail() {
            const pairWCModal = openPairModal()
            //type: test url
            keyClick("a")
            keyClick("b")
            keyClick("c")

            compare(pairingValidationRequestedSpy.count, 3, "expected pairingValidationRequested signal to be emitted")
            controlUnderTest.pairingValidated(Pairing.errors.invalidUri)
            compare(pairingRequestedSpy.count, 0, "expected pairingRequested signal to not be emitted")
        }

        function test_OpenDappRequestModal() {
            waitForRendering(controlUnderTest)
            const request = buildSessionRequestResolved(dappsWorkflowTest, "0x1", "1", "b536a")
            controlUnderTest.accountsModel.append({
                    address: request.accountAddress,
                    name: "helloworld",
                    emoji: "😋",
                    color: "#2A4AF5",
                    keycardAccount: false
            })
            controlUnderTest.networksModel.append({
                    chainId: request.chainId,
                    chainName: "Test Chain",
                    iconUrl: "network/Network=Ethereum",
                    layer: 1
            })
            controlUnderTest.sessionRequestsModel.enqueue(request)
            waitForRendering(controlUnderTest)
            let popup = findChild(controlUnderTest, "dappsRequestModal")
            verify(!!popup)
            verify(popup.opened)
            verify(popup.visible)

            compare(popup.dappName, request.dappName)
            compare(popup.accountAddress, request.accountAddress)

            popup.close()
            waitForRendering(controlUnderTest)
            verify(!popup.opened)
            verify(!popup.visible)
        }

        function showRequestModal(topic, requestId) {
            waitForRendering(controlUnderTest)
            const request = buildSessionRequestResolved(dappsWorkflowTest, "0x1", "1", topic, requestId)
            controlUnderTest.accountsModel.append({
                    address: request.accountAddress,
                    name: "helloworld",
                    emoji: "😋",
                    color: "#2A4AF5",
                    keycardAccount: false
            })
            controlUnderTest.networksModel.append({
                    chainId: request.chainId,
                    chainName: "Test Chain",
                    iconUrl: "network/Network=Ethereum",
                    layer: 1
            })
            controlUnderTest.sessionRequestsModel.enqueue(request)
            waitForRendering(controlUnderTest)
            const popup = findChild(controlUnderTest, "dappsRequestModal")
            verify(popup.opened)

            const acceptButton = findChild(popup, "signButton")
            const rejectButton = findChild(popup, "rejectButton")
            // Workaround for the buttons not being aligned yet
            // Removing this could cause the wrong button to be clicked
            tryVerify(() => acceptButton.x > rejectButton.x + rejectButton.width)
            return popup
        }

        function test_RejectDappRequestModal() {
            const topic = "abcd"
            const requestId = "12345"
            let popup = showRequestModal(topic, requestId)
            let rejectButton = findChild(popup, "rejectButton")

            verify(!!rejectButton)
            mouseClick(rejectButton)
            compare(signRequestRejectedSpy.count, 1, "expected signRequestRejected signal to be emitted")
            compare(signRequestAcceptedSpy.count, 0, "expected signRequestAccepted signal to not be emitted")
            compare(signRequestRejectedSpy.signalArguments[0][0], topic, "expected id to be set")
            compare(signRequestRejectedSpy.signalArguments[0][1], requestId, "expected requestId to be set")

            verify(!popup.opened)
            verify(!popup.visible)
        }

        function test_AcceptDappRequestModal() {
            const topic = "abcd"
            const requestId = "12345"
            let popup = showRequestModal(topic, requestId)

            let signButton = findChild(popup, "signButton")

            mouseClick(signButton)
            compare(signRequestAcceptedSpy.count, 1, "expected signRequestAccepted signal to be emitted")
            compare(signRequestRejectedSpy.count, 0, "expected signRequestRejected signal to not be emitted")
            compare(signRequestAcceptedSpy.signalArguments[0][0], topic, "expected id to be set")
            compare(signRequestAcceptedSpy.signalArguments[0][1], requestId, "expected requestId to be set")

            waitForRendering(controlUnderTest)
            verify(!popup.opened)
            verify(!popup.visible)
        }

        function test_SignRequestExpired() {
            const topic = "abcd"
            const requestId = "12345"
            let popup = showRequestModal(topic, requestId)

            const request = controlUnderTest.sessionRequestsModel.findRequest(topic, requestId)
            verify(!!request)

            const countDownPill = findChild(popup, "countdownPill")
            verify(!!countDownPill)
            tryVerify(() => countDownPill.remainingSeconds > 0)
            // Hackish -> countdownPill internals ask for a refresh before going to expired state
            const remainingSeconds = countDownPill.remainingSeconds
            tryVerify(() => countDownPill.visible)
            tryVerify(() => countDownPill.remainingSeconds !== remainingSeconds)

            request.setExpired()
            tryVerify(() => countDownPill.isExpired)
            verify(countDownPill.visible)

            const signButton = findChild(popup, "signButton")
            const rejectButton = findChild(popup, "rejectButton")
            const closeButton = findChild(popup, "closeButton")

            tryVerify(() => !signButton.visible)
            verify(!rejectButton.visible)
            verify(closeButton.visible)
        }

        function test_SignRequestDoesWithoutExpiry()
        {
            const topic = "abcd"
            const requestId = "12345"
            let popup = showRequestModal(topic, requestId)

            const request = controlUnderTest.sessionRequestsModel.findRequest(topic, requestId)
            verify(!!request)
            request.expirationTimestamp = undefined

            const countDownPill = findChild(popup, "countdownPill")
            verify(!!countDownPill)
            tryVerify(() => !countDownPill.visible)

            request.setExpired()
            tryVerify(() => countDownPill.visible)

            const signButton = findChild(popup, "signButton")
            const rejectButton = findChild(popup, "rejectButton")
            const closeButton = findChild(popup, "closeButton")

            verify(signButton.visible)
            verify(rejectButton.visible)
            verify(!closeButton.visible)
        }

        function test_SignRequestModalAfterModelRemove()
        {
            const topic = "abcd"
            const requestId = "12345"
            let popup = showRequestModal(topic, requestId)

            const request = controlUnderTest.sessionRequestsModel.findRequest(topic, requestId)
            verify(!!request)

            controlUnderTest.sessionRequestsModel.removeRequest(topic, requestId)
            verify(!controlUnderTest.sessionRequestsModel.findRequest(topic, requestId))

            waitForRendering(controlUnderTest)
            popup = findChild(controlUnderTest, "dappsRequestModal")
            verify(!popup)
        }
    }
}
