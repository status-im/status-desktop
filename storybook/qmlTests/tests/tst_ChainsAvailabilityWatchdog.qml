import QtQuick 2.15

import QtTest 1.15

import AppLayouts.Wallet.helpers 1.0

Item {
    id: root

    width: 600
    height: 400

    Component {
        id: chainsAvailabilityWatchdogComponent
        ChainsAvailabilityWatchdog {
            id: chainsAvailabilityWatchdog
            readonly property SignalSpy chainOnlineChangedSpy: SignalSpy { target: chainsAvailabilityWatchdog; signalName: "chainOnlineChanged" }
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
        }
    }

    TestCase {
        id: chainsAvailabilityWatchdogTest
        name: "ChainsAvailabilityWatchdog"

        property ChainsAvailabilityWatchdog componentUnderTest: null

        function init() {
            componentUnderTest = chainsAvailabilityWatchdogComponent.createObject(root)
            componentUnderTest.chainOnlineChangedSpy.clear()
        }

        function test_initAllOnline() {
            tryVerify(() => componentUnderTest.allOnline)
            tryVerify(() => !componentUnderTest.allOffline)
        }

        function test_chainOnlineChanged() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)

            tryVerify(() => !componentUnderTest.allOnline)
            tryVerify(() => !componentUnderTest.allOffline)
            compare(componentUnderTest.chainOnlineChangedSpy.count, 1)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][0], 1)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][1], false)
        }

        function test_allOffline() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            tryVerify(() => !componentUnderTest.allOnline)
            tryVerify(() => componentUnderTest.allOffline)

            compare(componentUnderTest.chainOnlineChangedSpy.count, 2)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][0], 1)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][1], false)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[1][0], 2)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[1][1], false)
        }

        function test_emptyModel() {
            componentUnderTest.networksModel.clear()

            tryVerify(() => !componentUnderTest.allOnline)
            tryVerify(() => componentUnderTest.allOffline)
        }

        function test_modelChanges() {
            tryVerify(() => componentUnderTest.allOnline)
            tryVerify(() => !componentUnderTest.allOffline)

            componentUnderTest.networksModel.append({ chainId: 3, isOnline: false })

            compare(componentUnderTest.allOnline, false)
            compare(componentUnderTest.allOffline, false)
            compare(componentUnderTest.chainOnlineChangedSpy.count, 1)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][0], 3)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][1], false)
        }

        function test_modelChanges2() {
            tryVerify(() => componentUnderTest.allOnline)
            tryVerify(() => !componentUnderTest.allOffline)

            componentUnderTest.networksModel.append({ chainId: 3, isOnline: true })

            compare(componentUnderTest.allOnline, true)
            compare(componentUnderTest.allOffline, false)
            compare(componentUnderTest.chainOnlineChangedSpy.count, 1)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][0], 3)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][1], true)
        }

        function test_modelChangesWhileOffline() {
            componentUnderTest.networksModel.setProperty(0, "isOnline", false)
            componentUnderTest.networksModel.setProperty(1, "isOnline", false)

            tryVerify(() => !componentUnderTest.allOnline)
            tryVerify(() => componentUnderTest.allOffline)

            componentUnderTest.networksModel.append({ chainId: 3, isOnline: false })

            compare(componentUnderTest.allOnline, false)
            compare(componentUnderTest.allOffline, true)
            compare(componentUnderTest.chainOnlineChangedSpy.count, 3)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][0], 1)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[0][1], false)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[1][0], 2)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[1][1], false)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[2][0], 3)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[2][1], false)

            componentUnderTest.networksModel.setProperty(2, "isOnline", true)

            tryVerify(() => !componentUnderTest.allOnline)
            tryVerify(() => !componentUnderTest.allOffline)
            compare(componentUnderTest.chainOnlineChangedSpy.count, 4)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[3][0], 3)
            compare(componentUnderTest.chainOnlineChangedSpy.signalArguments[3][1], true)
        }
    }
}