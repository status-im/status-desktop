import QtQuick 2.15
import QtQml.Models 2.15

import QtTest 1.15

import AppLayouts.Wallet.controls 1.0

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        DappsComboBox {
            anchors.centerIn: parent
            model: ListModel {}
        }
    }

    SignalSpy {
        id: dappsListReadySpy
        target: controlUnderTest
        signalName: "dappsListReady"
    }

    property DappsComboBox controlUnderTest: null

    TestCase {
        name: "DappsComboBox"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            dappsListReadySpy.clear()
        }

        function test_basicGeometry() {
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
        }

        function test_showStatusIndicator() {
            const indicator = findChild(controlUnderTest, "dappBadge")
            compare(indicator.visible, false)

            controlUnderTest.model.append({name: "Test dApp 1", url: "https://dapp.test/1", iconUrl: "https://se-sdk-dapp.vercel.app/assets/eip155:1.png"})
            compare(indicator.visible, true)

            controlUnderTest.model.clear()
            compare(indicator.visible, false)
        }

        function test_dappIcon() {
            const icon = findChild(controlUnderTest, "dappIcon")
            compare(icon.icon, "dapp")
            compare(icon.width, 16)
            compare(icon.height, 16)
            compare(icon.status, Image.Ready)
        }

        function test_openingPopup() {
            mouseClick(controlUnderTest)
            const popup = findChild(controlUnderTest, "dappsListPopup")
            compare(popup.visible, true)
            compare(popup.x, controlUnderTest.width - popup.width)
            compare(popup.y, controlUnderTest.height + 4)
            compare(popup.width, 312)
            verify(popup.height > 0)
            compare(dappsListReadySpy.count, 1)

            const background = findChild(controlUnderTest, "dappsBackground")
            compare(background.active, true)

            mouseClick(controlUnderTest)
            compare(popup.visible, false)
            compare(background.active, false)
        }

        function test_hoverState() {
            const background = findChild(controlUnderTest, "dappsBackground")
            compare(background.active, false)

            mouseMove(controlUnderTest, controlUnderTest.width/2, controlUnderTest.height/2)
            compare(background.active, true)
            compare(controlUnderTest.hovered, true)
            const dappTooltip = findChild(controlUnderTest, "dappTooltip")
            wait(dappTooltip.delay + 50)
            compare(dappTooltip.visible, true)
            compare(dappTooltip.text, "dApp connections")
            verify(dappTooltip.width > 0)
            verify(dappTooltip.height > 0)
            verify(dappTooltip.y > controlUnderTest.height)

            mouseMove(root)
            compare(background.active, false)
            compare(dappTooltip.visible, false)
        }

        function test_connectorsEnabledOrDisabled() {
            mouseClick(controlUnderTest)
            const dappListPopup = findChild(controlUnderTest, "dappsListPopup")
            verify(!!dappListPopup)

            dappListPopup.connectDapp()
            waitForRendering(controlUnderTest)
            waitForItemPolished(controlUnderTest)

            const connectorButton = findChild(controlUnderTest, "btnStatusConnector")
            const wcButton = findChild(controlUnderTest, "btnWalletConnect")
            verify(!!connectorButton)
            verify(!!wcButton)

            compare(controlUnderTest.walletConnectEnabled, true)
            compare(controlUnderTest.connectorEnabled, true)

            controlUnderTest.walletConnectEnabled = false
            compare(wcButton.enabled, false)

            controlUnderTest.walletConnectEnabled = true
            compare(wcButton.enabled, true)

            controlUnderTest.connectorEnabled = false
            compare(connectorButton.enabled, false)

            controlUnderTest.connectorEnabled = true
            compare(connectorButton.enabled, true)
        }
    }
}
