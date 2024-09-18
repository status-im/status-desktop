import QtQuick 2.15
import QtTest 1.15

import AppLayouts.Wallet.views 1.0

import Storybook 1.0

Item {
    id: root

    width: 600
    height: 400

    Component {
        id: delegateCmp

        TokenSelectorAssetDelegate {
            id: delegate

            name: "Ether"
            symbol: "ETH"
            currencyBalanceAsString: "42.02 USD"
            iconSource: ""
            width: 250

            readonly property SignalSpy clickSpy: SignalSpy {
                target: delegate
                signalName: "clicked"
            }
        }
    }

    ListModel {
        id: balancesModel

        ListElement {
            balanceAsString: "1234.50"
            iconUrl: "network/Network=Ethereum"
        }
        ListElement {
            balanceAsString: "33.52"
            iconUrl: "network/Network=Arbitrum"
        }
    }

    TestCase {
        name: "TokenSelectorAssetDelegate"
        when: windowShown

        function test_elision() {
            const control = createTemporaryObject(delegateCmp, root)

            const nameText = TestUtils.findTextItem(control, "Ether")
            const symbolText = TestUtils.findTextItem(control, "ETH")
            const balanceText = TestUtils.findTextItem(control, "42.02 USD")

            verify(nameText)
            verify(symbolText)
            verify(balanceText)

            verify(nameText.visible)
            verify(symbolText.visible)
            verify(balanceText.visible)

            waitForRendering(control)

            verify(nameText.width > 0)
            verify(symbolText.width > 0)
            verify(balanceText.width > 0)

            verify(!nameText.truncated)
            verify(!symbolText.truncated)
            verify(!balanceText.truncated)

            control.name = "Ether ".repeat(10)

            verify(nameText.truncated)
            verify(!symbolText.truncated)
            verify(!balanceText.truncated)
        }

        function test_noBalances() {
            const control = createTemporaryObject(delegateCmp, root)

            const list = findChild(control, "balancesListView")
            compare(list.visible, false)
            compare(list.count, 0)
            compare(list.interactive, true)

            compare(control.opacity, 1)
            control.enabled = false
            verify(control.opacity < 1)

            mouseClick(control)
            compare(control.clickSpy.count, 0)

            control.enabled = true

            mouseClick(control)
            compare(control.clickSpy.count, 1)
        }

        function test_withBalances() {
            const control = createTemporaryObject(delegateCmp, root,
                                                  { balancesModel })

            const list = findChild(control, "balancesListView")
            waitForRendering(list)

            compare(list.visible, true)
            compare(list.count, 2)
            compare(list.interactive, true)

            mouseClick(control)
            compare(control.clickSpy.count, 1)

            mouseClick(list)
            compare(control.clickSpy.count, 2)

            control.balancesListInteractive = false
            compare(list.interactive, false)

            const subBalanceText1 = TestUtils.findTextItem(control, "1234.50")
            const subBalanceText2 = TestUtils.findTextItem(control, "33.52")

            verify(subBalanceText1)
            verify(subBalanceText2)

            verify(subBalanceText1.visible)
            verify(subBalanceText2.visible)
        }
    }
}
