import QtQuick 2.15
import QtTest 1.15

import shared.popups.walletconnect 1.0

import Models 1.0

Item {
    id: root
    width: 600
    height: 800

    Component {
        id: accountsModelComponent
        WalletAccountsModel {}
    }

    Component {
        id: componentUnderTest
        ConnectDAppModal {
            id: controlUnderTest
            modal: false
            anchors.centerIn: parent
            accounts: WalletAccountsModel {}
            flatNetworks: NetworksModel.flatNetworks
        }
    }

    TestCase {
        id: testConnectDappModal
        name: "ConnectDappModalTest"
        when: windowShown

        SignalSpy {
            id: connectSignalSpy
            target: testConnectDappModal.dappModal
            signalName: "connect"
        }

        SignalSpy {
            id: declineSignalSpy
            target: testConnectDappModal.dappModal
            signalName: "decline"
        }

        SignalSpy {
            id: disconnectSignalSpy
            target: testConnectDappModal.dappModal
            signalName: "disconnect"
        }

        property ConnectDAppModal dappModal: null

        function cleanup() {
            connectSignalSpy.clear()
            declineSignalSpy.clear()
            disconnectSignalSpy.clear()
        }

        function test_initialState() {
            dappModal = createTemporaryObject(componentUnderTest, root, {visible: true})

            verify(dappModal.visible, "ConnectDAppModal should be visible")
            verify(dappModal.accounts, "ConnectDAppModal should have accounts")
            verify(dappModal.flatNetworks, "ConnectDAppModal should have networks")

            compare(dappModal.width, 480)
            compare(dappModal.height, 633)
            compare(dappModal.dAppName, "")
            compare(dappModal.dAppUrl, "")
            compare(dappModal.dAppIconUrl, "")
            compare(dappModal.connectionStatus, dappModal.notConnectedStatus)
        }

        function test_notConnectedState() {
            dappModal = createTemporaryObject(componentUnderTest, root, {visible: true, dAppChains: [1, 11155111]})

            compare(dappModal.connectionStatus, dappModal.notConnectedStatus)

            // Reject button should be enabled
            const rejectButton = findChild(dappModal, "rejectButton")
            verify(rejectButton, "Reject button should be present")
            compare(rejectButton.text, "Reject")
            compare(rejectButton.enabled, true)
            mouseClick(rejectButton)
            compare(declineSignalSpy.count, 1)
            
            // Connect button should be enabled
            const connectButton = findChild(dappModal, "primaryActionButton")
            verify(connectButton, "Connect button should be present")
            compare(connectButton.text, "Connect")
            compare(connectButton.enabled, true)
            mouseClick(connectButton)
            compare(connectSignalSpy.count, 1)

            // Disconnect button should be disabled
            const disconnectButton = findChild(dappModal, "disconnectButton")
            verify(disconnectButton, "Disconnect button should be present")
            compare(disconnectButton.text, "Disconnect")
            compare(disconnectButton.visible, false)
            mouseClick(disconnectButton)
            compare(disconnectSignalSpy.count, 0)

            // Account selector should be enabled and user should be able to select an account
            const accountSelector = findChild(dappModal, "accountSelector")
            verify(accountSelector, "Account selector should be present")
            compare(accountSelector.enabled, true)
            compare(accountSelector.currentIndex, 0)
            mouseClick(accountSelector)
            compare(accountSelector.popup.visible, true)

            waitForItemPolished(accountSelector.popup.contentItem)

            const accountsList = findChild(accountSelector, "accountSelectorList")
            verify(accountsList, "Accounts list should be present")
            mouseClick(accountsList.itemAtIndex(1))
            compare(accountSelector.currentIndex, 1)

            // Chain selector is enabled, all common chains preselected
            const chainSelector = findChild(dappModal, "networkFilter")
            verify(chainSelector, "Chain selector should be present")
            compare(chainSelector.enabled, true)
            compare(chainSelector.selection.length, 2)
            compare(chainSelector.selection[0], 1)
            compare(chainSelector.selection[1], 11155111)

            // User should be able to deselect a chain
            mouseClick(chainSelector)
            waitForItemPolished(chainSelector)
            const networkSelectorList = findChild(chainSelector, "networkSelectorList")
            verify(networkSelectorList, "Network selector list should be present")
            mouseClick(networkSelectorList.itemAtIndex(0))
            compare(chainSelector.selection.length, 1)
            compare(chainSelector.selection[0], 11155111)
            compare(dappModal.selectedChains.length, 1)
            compare(dappModal.selectedChains[0], 11155111)
        }

        function test_connectedState() {
            dappModal = createTemporaryObject(componentUnderTest, root, {visible: true, dAppChains: [1, 11155111]})
            dappModal.pairSuccessful()
            compare(dappModal.connectionStatus, dappModal.connectionSuccessfulStatus)

            // Reject button should not be visible
            const rejectButton = findChild(dappModal, "rejectButton")
            verify(rejectButton, "Reject button should be present")
            compare(rejectButton.visible, false)
            mouseClick(rejectButton)
            compare(declineSignalSpy.count, 0)

            // Close button should be enabled
            const closeButton = findChild(dappModal, "primaryActionButton")
            verify(closeButton, "Close button should be present")
            compare(closeButton.text, "Close")
            compare(closeButton.enabled, true)
            compare(closeButton.visible, true)
            mouseClick(closeButton)
            compare(dappModal.opened, false)
            dappModal.open()

            // Disconnect button should be enabled
            const disconnectButton = findChild(dappModal, "disconnectButton")
            verify(disconnectButton, "Disconnect button should be present")
            compare(disconnectButton.text, "Disconnect")
            compare(disconnectButton.visible, true)
            compare(disconnectButton.enabled, true)
            mouseClick(disconnectButton)
            compare(disconnectSignalSpy.count, 1)

            // Account selector should be disabled
            const accountSelector = findChild(dappModal, "accountSelector")
            verify(accountSelector, "Account selector should be present")
            compare(accountSelector.currentIndex, 0)
            mouseClick(accountSelector)
            compare(accountSelector.popup.visible, false)

            // Chain selector is disabled
            const chainSelector = findChild(dappModal, "networkFilter")
            verify(chainSelector, "Chain selector should be present")
            compare(chainSelector.selection.length, 2)
            compare(chainSelector.selection[0], 1)
            compare(chainSelector.selection[1], 11155111)

            // User should not be able to deselect a chain
            mouseClick(chainSelector)
            waitForItemPolished(chainSelector)
            const networkSelectorList = findChild(chainSelector, "networkSelectorList")
            verify(networkSelectorList, "Network selector list should be present")
            mouseClick(networkSelectorList.itemAtIndex(0))
            compare(chainSelector.selection.length, 2)

            const connectionTag = findChild(dappModal, "connectionStatusTag")
            compare(connectionTag.visible, true)
            compare(connectionTag.success, true)
        }

        function test_connectionFailedState() {
            dappModal = createTemporaryObject(componentUnderTest, root, {visible: true, dAppChains: [1, 11155111]})
            dappModal.pairFailed()
            compare(dappModal.connectionStatus, dappModal.connectionFailedStatus)

            // Reject button should not be visible
            const rejectButton = findChild(dappModal, "rejectButton")
            verify(rejectButton, "Reject button should be present")
            compare(rejectButton.visible, false)
            mouseClick(rejectButton)
            compare(declineSignalSpy.count, 0)

            // Close button should be enabled
            const closeButton = findChild(dappModal, "primaryActionButton")
            verify(closeButton, "Close button should be present")
            compare(closeButton.text, "Close")
            compare(closeButton.enabled, true)
            compare(closeButton.visible, true)
            mouseClick(closeButton)
            compare(dappModal.opened, false)
            dappModal.open()

            // Disconnect button should not be visible
            const disconnectButton = findChild(dappModal, "disconnectButton")
            verify(disconnectButton, "Disconnect button should be present")
            compare(disconnectButton.text, "Disconnect")
            compare(disconnectButton.visible, false)
            mouseClick(disconnectButton)
            compare(disconnectSignalSpy.count, 0)

            // Account selector should be disabled
            const accountSelector = findChild(dappModal, "accountSelector")
            verify(accountSelector, "Account selector should be present")
            compare(accountSelector.currentIndex, 0)
            mouseClick(accountSelector)
            compare(accountSelector.popup.visible, false)

            // Chain selector is disabled
            const chainSelector = findChild(dappModal, "networkFilter")
            verify(chainSelector, "Chain selector should be present")
            compare(chainSelector.selection.length, 2)
            compare(chainSelector.selection[0], 1)
            compare(chainSelector.selection[1], 11155111)

            // User should not be able to deselect a chain
            mouseClick(chainSelector)
            waitForItemPolished(chainSelector)
            const networkSelectorList = findChild(chainSelector, "networkSelectorList")
            verify(networkSelectorList, "Network selector list should be present")
            mouseClick(networkSelectorList.itemAtIndex(0))
            compare(chainSelector.selection.length, 2)

            const connectionTag = findChild(dappModal, "connectionStatusTag")
            compare(connectionTag.visible, true)
            compare(connectionTag.success, false)
        }

        function test_selectingAccount() {
            dappModal = createTemporaryObject(componentUnderTest, root, {visible: true, dAppChains: [1, 11155111]})

            const accountSelector = findChild(dappModal, "accountSelector")
            verify(accountSelector, "Account selector should be present")
            compare(accountSelector.currentIndex, 0)
            mouseClick(accountSelector)
            compare(accountSelector.popup.visible, true)

            waitForItemPolished(accountSelector.popup.contentItem)

            const accountsList = findChild(accountSelector, "accountSelectorList")
            verify(accountsList, "Accounts list should be present")
            compare(accountsList.count, dappModal.accounts.count)
            mouseClick(accountsList.itemAtIndex(1))
            compare(accountSelector.currentIndex, 1)
            compare(dappModal.selectedAccount.address,accountSelector.currentAccountAddress)

            const preselectedAddress = accountSelector.currentAccountAddress

            mouseClick(accountSelector)
            compare(accountSelector.popup.visible, true)

            waitForItemPolished(accountSelector.popup.contentItem)
            mouseClick(accountsList.itemAtIndex(0))
            compare(accountSelector.currentIndex, 0)
            compare(dappModal.selectedAccount.address, accountSelector.currentAccountAddress)

            // Use preselected address
            dappModal.selectedAccountAddress = preselectedAddress
            compare(accountSelector.currentIndex, 1)
        }

        function test_chainSelection() {
            dappModal = createTemporaryObject(componentUnderTest, root, {visible: true, dAppChains: [1, 11155111]})

            const chainSelector = findChild(dappModal, "networkFilter")
            verify(chainSelector, "Chain selector should be present")
            compare(chainSelector.selection.length, 2)
            compare(chainSelector.selection[0], 1)
            compare(chainSelector.selection[1], 11155111)

            mouseClick(chainSelector)
            waitForItemPolished(chainSelector)
            const networkSelectorList = findChild(chainSelector, "networkSelectorList")
            verify(networkSelectorList, "Network selector list should be present")
            compare(networkSelectorList.count, dappModal.dAppChains.length)
            mouseClick(networkSelectorList.itemAtIndex(0))
            compare(chainSelector.selection.length, 1)
            compare(chainSelector.selection[0], 11155111)
            compare(dappModal.selectedChains.length, 1)
            compare(dappModal.selectedChains[0], 11155111)

            waitForItemPolished(networkSelectorList)
            mouseClick(networkSelectorList.itemAtIndex(1))
            compare(chainSelector.selection.length, 0)
            compare(dappModal.selectedChains.length, 0)
            
            const connectButton = findChild(dappModal, "primaryActionButton")
            compare(connectButton.visible, true)
            compare(connectButton.enabled, false)
        }
    }
}