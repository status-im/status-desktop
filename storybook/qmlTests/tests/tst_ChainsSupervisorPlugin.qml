import QtQuick 2.15

import QtTest 1.15

import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.plugins 1.0

Item {
    id: root

    width: 600
    height: 400

    Component {
        id: chainsSupervisorPluginComponent
        ChainsSupervisorPlugin {
            id: chainsSupervisorPlugin
            networksModel: ListModel {
                ListElement {
                    chainId: 1
                    isOnline: true
                }
                ListElement {
                    chainId: 2
                    isOnline: true
                }
            }
            sdk: WalletConnectSDKBase {
                property bool sdkReady: true
                projectId: "projectId"

                property var getActiveSessionsCallbacks: []
                getActiveSessions: function(callback) {
                    getActiveSessionsCallbacks.push({callback})
                }

                property var emitSessionEventCalls: []
                emitSessionEvent: function(topic, event, chainId) {
                    emitSessionEventCalls.push({topic, event, chainId})
                }

                pair: function() {
                    verify(false, "pair should not be called")
                }

                buildApprovedNamespaces: function(id, params, supportedNamespaces) {
                    verify(false, "buildApprovedNamespaces should not be called")
                }

                approveSession: function(sessionProposalJson, approvedNamespaces) {
                    verif(false, "approveSession should not be called")
                }

                acceptSessionRequest: function(topic, id, signature) {
                    verify(false, "acceptSessionRequest should not be called")
                }

                rejectSessionRequest: function(topic, id, error) {
                    verify(false, "rejectSessionRequest should not be called")
                }

                populateAuthPayload: function(id, authPayload, chains, methods) {
                    verify(false, "populateAuthPayload should not be called")
                }

                formatAuthMessage: function(id, request, iss) {
                    verify(false, "formatAuthMessage should not be called")
                }

                buildAuthObject: function(id, authPayload, signature, iss) {
                    verify(false, "buildAuthObject should not be called")
                }

                acceptSessionAuthenticate: function(id, auths) {
                    verify(false, "acceptSessionAuthenticate should not be called")
                }
            }
        }
    }

    function getConfiguredSession(requiredEvents, requiredChains, requiredAccounts) {
        return {
            topic: "topic",
            namespaces: {
                eip155: {
                    events: requiredEvents,
                    chains: requiredChains,
                    accounts: requiredAccounts
                }
            }
        }
    }

    TestCase {
        id: chainsSupervisorPluginTest
        name: "ChainsSupervisorPlugin"

        property ChainsSupervisorPlugin componentUnderTest: null

        function init() {
            componentUnderTest = chainsSupervisorPluginComponent.createObject(root)
            tryVerify(() => componentUnderTest.isOnline)
            tryVerify(() => !componentUnderTest.allChainsOffline)
            tryVerify(() => !componentUnderTest.networkOffline)
            componentUnderTest.sdk.getActiveSessionsCallbacks = []
            componentUnderTest.sdk.emitSessionEventCalls = []
        }

        function test_allChainsDisabled() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            tryVerify(() => componentUnderTest.allChainsOffline)
        }

        function test_disconnectEventAllValid() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            
            compare(componentUnderTest.sdk.getActiveSessionsCallbacks.length, 1)
            // 2 chains negociated. 2 accounts
            // Expected two disconnect events
            const validSession = getConfiguredSession(["disconnect"], ["eip155:1", "eip155:2"], ["eip155:1:0x1234", "eip155:2:0x1234"])

            componentUnderTest.sdk.getActiveSessionsCallbacks[0].callback([validSession])
            compare(componentUnderTest.sdk.emitSessionEventCalls.length, 2)
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].topic, validSession.topic)
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].event.name, "disconnect")
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].chainId, "eip155:1")
            compare(componentUnderTest.sdk.emitSessionEventCalls[1].topic, validSession.topic)
            compare(componentUnderTest.sdk.emitSessionEventCalls[1].event.name, "disconnect")
            compare(componentUnderTest.sdk.emitSessionEventCalls[1].chainId, "eip155:2")
        }

        function test_disconnectEventSingleChainAccount() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            compare(componentUnderTest.sdk.getActiveSessionsCallbacks.length, 1)
            // 2 chains negociated. Account on a single chain
            // Expected a single disconnect event
            const validSession = getConfiguredSession(["disconnect"], ["eip155:1", "eip155:2"], ["eip155:1:0x1234"])

            componentUnderTest.sdk.getActiveSessionsCallbacks[0].callback([validSession])
            compare(componentUnderTest.sdk.emitSessionEventCalls.length, 1)
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].topic, validSession.topic)
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].event.name, "disconnect")
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].chainId, "eip155:1")
        }

        function test_disconnectEventNoAccount() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            compare(componentUnderTest.sdk.getActiveSessionsCallbacks.length, 1)
            // 2 chains negociated. No account
            // Expected no disconnect event
            const validSession = getConfiguredSession(["disconnect"], ["eip155:1", "eip155:2"], [])

            componentUnderTest.sdk.getActiveSessionsCallbacks[0].callback([validSession])
            compare(componentUnderTest.sdk.emitSessionEventCalls.length, 0)
        }

        function test_disconnectEventOneChainTwoAccounts() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            compare(componentUnderTest.sdk.getActiveSessionsCallbacks.length, 1)
            // 1 chain negociated. 2 accounts on a single chain
            // Expected a single disconnect event
            const validSession = getConfiguredSession(["disconnect"], ["eip155:1"], ["eip155:1:0x1234", "eip155:1:0x5678"])

            componentUnderTest.sdk.getActiveSessionsCallbacks[0].callback([validSession])
            compare(componentUnderTest.sdk.emitSessionEventCalls.length, 1)
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].topic, validSession.topic)
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].event.name, "disconnect")
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].chainId, "eip155:1")
        }

        function test_disconnectEventNoChains() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            compare(componentUnderTest.sdk.getActiveSessionsCallbacks.length, 1)
            // No chain negociated. 2 accounts
            // Expected no disconnect event
            const validSession = getConfiguredSession(["disconnect"], [], ["eip155:1:0x1234", "eip155:2:0x1234"])

            componentUnderTest.sdk.getActiveSessionsCallbacks[0].callback([validSession])
            compare(componentUnderTest.sdk.emitSessionEventCalls.length, 0)
        }

        function test_disconnectEventNoChainNoAccount() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            compare(componentUnderTest.sdk.getActiveSessionsCallbacks.length, 1)
            // No chain negociated. No account
            // Expected no disconnect event
            const validSession = getConfiguredSession(["disconnect"], [], [])

            componentUnderTest.sdk.getActiveSessionsCallbacks[0].callback([validSession])
            compare(componentUnderTest.sdk.emitSessionEventCalls.length, 0)
        }

        function test_disconnectEventNoEventNegociated() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            compare(componentUnderTest.sdk.getActiveSessionsCallbacks.length, 1)
            // 2 chains negociated. 2 accounts
            // Missing `disconnect` - Expected no disconnect event
            const validSession = getConfiguredSession([], ["eip155:1", "eip155:2"], ["eip155:1:0x1234", "eip155:2:0x1234"])

            componentUnderTest.sdk.getActiveSessionsCallbacks[0].callback([validSession])
            compare(componentUnderTest.sdk.emitSessionEventCalls.length, 0)
        }

        function test_chainBackOnline() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)
            componentUnderTest.sdk.getActiveSessionsCallbacks = []

            const validSession = getConfiguredSession(["connect"], ["eip155:1"], ["eip155:1:0x1234"])
            componentUnderTest.networksModel.setProperty(0, "isOnline", true)
            compare(componentUnderTest.sdk.getActiveSessionsCallbacks.length, 1)
            componentUnderTest.sdk.getActiveSessionsCallbacks[0].callback([validSession])

            compare(componentUnderTest.sdk.emitSessionEventCalls.length, 1)
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].topic, validSession.topic)
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].event.name, "connect")
            compare(componentUnderTest.sdk.emitSessionEventCalls[0].chainId, "eip155:1")
        }

        function test_spammingOnlineState() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)
            const validSession = getConfiguredSession(["connect"], ["eip155:1", "eip155:2"], ["eip155:1:0x1234", "eip155:2:0x1234"])
            componentUnderTest.sdk.getActiveSessionsCallbacks[0].callback([validSession])
            componentUnderTest.sdk.getActiveSessionsCallbacks = []
            
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", true)
            componentUnderTest.sdk.getActiveSessionsCallbacks = []

            for (let i = 0; i < 10; i++) {
                componentUnderTest.networksModel.setProperty(0, "isOnline", i % 2 === 0)
            }

            compare(componentUnderTest.sdk.getActiveSessionsCallbacks.length, 1)
        }
    }
}