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
        }
    }

    Component {
        id: walletStoreComponent

        QtObject {
            readonly property ListModel filteredFlatModel: ListModel {
                ListElement { chainId: 1 }
                ListElement {
                    chainId: 2
                    chainName: "Test Chain"
                    iconUrl: "network/Network=Ethereum"
                }
            }

            readonly property ListModel nonWatchAccounts: ListModel {
                ListElement {address: "0x1"}
                ListElement {
                    address: "0x2"
                    name: "helloworld"
                    emoji: "😋"
                    color: "#2A4AF5"
                }
                ListElement { address: "0x3a" }
            }
            function getNetworkShortNames(chainIds) {
                 return "eth:oeth:arb"
             }
        }
    }

    Component {
        id: dappsRequestHandlerComponent

        DAppsRequestHandler {
        }
    }

    TestCase {
        id: requestHandlerTest
        name: "DAppsRequestHandler"

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
            store.userAuthenticated(td.topic, td.request.id, "password", "")
            compare(store.signMessageCalls.length, 1, "expected a call to store.signMessage")
            compare(store.signMessageCalls[0].message, td.request.data)
        }

        function test_onSessionRequestEventDifferentCaseForAddress() {
            let sdk = handler.sdk

            let testAddressUpper = "0x3A"
            let chainId = 2
            let  method = "personal_sign"
            let message = "hello world"
            let params = [Helpers.strToHex(message), testAddressUpper]
            let topic = "b536a"
            let session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            // Expect to have calls to getActiveSessions from service initialization
            let prevRequests = sdk.getActiveSessionsCallbacks.length
            sdk.sessionRequestEvent(session)

            compare(sdk.getActiveSessionsCallbacks.length, 1, "expected DAppsRequestHandler call sdk.getActiveSessions")
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

        SignalSpy {
            id: sessionRequestSpy
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

        function test_TestPairing() {
            // All calls to SDK are expected as events to be made by the wallet connect SDK
            let sdk = service.wcSDK
            let walletStore = service.walletRootStore
            let store = service.store

            service.pair("wc:12ab@1?bridge=https%3A%2F%2Fbridge.walletconnect.org&key=12ab")
            compare(sdk.pairCalled, 1, "expected a call to sdk.pair")

            sdk.sessionProposal(JSON.parse(Testing.formatSessionProposal()))
            compare(sdk.buildApprovedNamespacesCalls.length, 1, "expected a call to sdk.buildApprovedNamespaces")
            var args = sdk.buildApprovedNamespacesCalls[0]
            verify(!!args.supportedNamespaces, "expected supportedNamespaces to be set")
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
            args = sdk.buildApprovedNamespacesCalls[1]
            verify(!!args.supportedNamespaces, "expected supportedNamespaces to be set")
            // We test here that only one account for all chains is provided
            let accountsForApproval = args.supportedNamespaces.eip155.accounts
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

        function test_SessionRequestMainFlow() {
            // All calls to SDK are expected as events to be made by the wallet connect SDK
            let sdk = service.wcSDK
            let walletStore = service.walletRootStore
            let store = service.store

            let testAddress = "0x3a"
            let chainId = 2
            let  method = "personal_sign"
            let message = "hello world"
            let params = [Helpers.strToHex(message), testAddress]
            let topic = "b536a"
            let session = JSON.parse(Testing.formatSessionRequest(chainId, method, params, topic))
            // Expect to have calls to getActiveSessions from service initialization
            let prevRequests = sdk.getActiveSessionsCallbacks.length
            sdk.sessionRequestEvent(session)

            compare(sdk.getActiveSessionsCallbacks.length, prevRequests + 1, "expected DAppsRequestHandler call sdk.getActiveSessions")
            let callback = sdk.getActiveSessionsCallbacks[prevRequests].callback
            callback({"b536a": JSON.parse(Testing.formatApproveSessionResponse([chainId, 7], [testAddress]))})

            compare(sessionRequestSpy.count, 1, "expected service.sessionRequest trigger")
            let request = sessionRequestSpy.signalArguments[0][sessionRequestSpy.argPos.request]
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
            provider = createTemporaryObject(dappsListProviderComponent, root, {sdk: sdk, store: store})
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
            let session = JSON.parse(Testing.formatApproveSessionResponse([1, 2], ["0x1"], {dappMetadataJsonString: Testing.noIconsDappMetadataJsonString}))
            callback({"b536a": session, "b537b": session})
            compare(provider.dappsModel.count, 1, "expected dappsModel have the SDK's reported dapps")
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
            let res = Helpers.extractChainsAndAccountsFromApprovedNamespaces(JSON.parse(`{
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
            let methods = ["eth_sendTransaction", "personal_sign"]
            let resStr = Helpers.buildSupportedNamespacesFromModels(chainsModel, accountsModel, methods)
            let jsonObj = JSON.parse(resStr)
            verify(jsonObj.hasOwnProperty("eip155"))
            let eip155 = jsonObj.eip155

            verify(eip155.hasOwnProperty("chains"))
            let chains = eip155.chains
            verify(chains.length === 2)
            verify(chains[0] === "eip155:1")
            verify(chains[1] === "eip155:2")

            verify(eip155.hasOwnProperty("accounts"))
            let accounts = eip155.accounts
            verify(accounts.length === 4)
            for (let chainI = 0; chainI < chainsModel.count; chainI++) {
                for (let accountI = 0; accountI < chainsModel.count; accountI++) {
                    var found = false
                    for (let entry of accounts) {
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
            verify(eip155.events.length > 0)
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

    function mockSessionRequestEvent(tc, sdk, accountsModel, networksMdodel) {
        let account = accountsModel.get(1)
        let network = networksMdodel.get(1)
        let method = "personal_sign"
        let message = "hello world"
        let params = [Helpers.strToHex(message), account.address]
        let topic = "b536a"
        let requestEvent = JSON.parse(Testing.formatSessionRequest(network.chainId, method, params, topic))
        let request = tc.createTemporaryObject(sessionRequestComponent, root, {
            event: requestEvent,
            topic,
            id: requestEvent.id,
            method: Constants.personal_sign,
            account,
            network,
            data: message
        })
        // Expect to have calls to getActiveSessions from service initialization
        let prevRequests = sdk.getActiveSessionsCallbacks.length
        sdk.sessionRequestEvent(requestEvent)
        // Service might trigger a sessionRequest event following the getActiveSessions call
        let callback = sdk.getActiveSessionsCallbacks[prevRequests].callback
        let session = JSON.parse(Testing.formatApproveSessionResponse([network.chainId, 7], [account.address]))
        callback({"b536a": session})

        return {sdk, session, account, network, topic, request}
    }
}
