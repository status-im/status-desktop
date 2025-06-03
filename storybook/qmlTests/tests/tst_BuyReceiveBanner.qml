import QtQuick 2.15
import QtTest 1.15

import AppLayouts.Wallet.panels 1.0

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: buyReceiveComponent
        BuyReceiveBanner {
            id: banner

            width: root.width
            height: implicitHeight

            anchors.centerIn: parent

            readonly property SignalSpy buyClickedSpy: SignalSpy { target: banner; signalName: "buyClicked" }
            readonly property SignalSpy receiveClickedSpy: SignalSpy { target: banner; signalName: "receiveClicked" }
            readonly property SignalSpy closeBuySpy: SignalSpy { target: banner; signalName: "closeBuy" }
            readonly property SignalSpy closeReceiveSpy: SignalSpy { target: banner; signalName: "closeReceive" }
        }
    }

    TestCase {
        id: buyReceiveBannerTest

        name: "BuyReceiveBannerTest"

        when: windowShown

        property BuyReceiveBanner componentUnderTest

        function init() {
            componentUnderTest = createTemporaryObject(buyReceiveComponent, root)
        }

        function test_empty() {
            verify(componentUnderTest.closeEnabled)
            verify(componentUnderTest.buyEnabled)
            verify(componentUnderTest.receiveEnabled)
            verify(componentUnderTest.anyVisibleItems)
        }

        function test_geometry() {
            compare(componentUnderTest.width, root.width)
            compare(componentUnderTest.height, 70)
        }

        function test_buyGeometry() {
            const buyCard = findChild(componentUnderTest, "buyCard")
            verify(!!buyCard)
            verify(buyCard.visible)
            verify(buyCard.opacity > 0)
            verify(buyCard.width > 0)
            verify(buyCard.height > 0)
            verify(buyCard.x >= 0)
            verify(buyCard.x <= buyCard.parent.width - buyCard.width)
            verify(buyCard.y >= 0)
            verify(buyCard.y <= buyCard.parent.height - buyCard.height)
        }

        function test_receiveGeometry() {
            const receiveCard = findChild(componentUnderTest, "receiveCard")
            verify(!!receiveCard)
            verify(receiveCard.visible)
            verify(receiveCard.opacity > 0)
            verify(receiveCard.width > 0)
            verify(receiveCard.height > 0)
            verify(receiveCard.x >= 0)
            verify(receiveCard.x <= receiveCard.parent.width - receiveCard.width)
            verify(receiveCard.y >= 0)
            verify(receiveCard.y <= receiveCard.parent.height - receiveCard.height)
        }

        function test_clickBuy() {
            const buyCard = findChild(componentUnderTest, "buyCard")
            verify(!!buyCard)

            compare(componentUnderTest.buyClickedSpy.count, 0)
            mouseClick(buyCard)
            compare(componentUnderTest.buyClickedSpy.count, 1)
        }

        function test_receiveClicked() {
            const receiveCard = findChild(componentUnderTest, "receiveCard")
            verify(!!receiveCard)

            compare(componentUnderTest.receiveClickedSpy.count, 0)
            mouseClick(receiveCard)
            compare(componentUnderTest.receiveClickedSpy.count, 1)
        }

        function test_closeBuy() {
            const buyCard = findChild(componentUnderTest, "buyCard")
            verify(!!buyCard)
            const closeButton = findChild(buyCard, "bannerCard_closeButton")
            mouseMove(buyCard, buyCard.width / 2, buyCard.height / 2)
            verify(!!closeButton)
            verify(closeButton.visible)

            compare(componentUnderTest.closeBuySpy.count, 0)
            mouseClick(closeButton)
            compare(componentUnderTest.closeBuySpy.count, 1)
        }

        function test_closeReceive() {
            const receiveCard = findChild(componentUnderTest, "receiveCard")
            verify(!!receiveCard)
            const closeButton = findChild(receiveCard, "bannerCard_closeButton")
            mouseMove(receiveCard, receiveCard.width / 2, receiveCard.height / 2)
            verify(!!closeButton)
            verify(closeButton.visible)

            compare(componentUnderTest.closeReceiveSpy.count, 0)
            mouseClick(closeButton)
            compare(componentUnderTest.closeReceiveSpy.count, 1)
        }

        function test_anyVisibleItemsChanged() {
            compare(componentUnderTest.anyVisibleItems, true)
            compare(componentUnderTest.buyEnabled, true)
            compare(componentUnderTest.receiveEnabled, true)

            componentUnderTest.buyEnabled = false
            compare(componentUnderTest.anyVisibleItems, true)

            componentUnderTest.receiveEnabled = false
            tryVerify(() => componentUnderTest.anyVisibleItems, false)
        }

        function test_closeDisabled() {
            const buyCard = findChild(componentUnderTest, "buyCard")
            verify(!!buyCard)
            const closeButton = findChild(buyCard, "bannerCard_closeButton")
            mouseMove(buyCard, buyCard.width / 2, buyCard.height / 2)
            verify(!!closeButton)
            verify(closeButton.visible)

            componentUnderTest.closeEnabled = false
            verify(!closeButton.visible)

            const receiveCard = findChild(componentUnderTest, "receiveCard")
            verify(!!receiveCard)
            const receiveCloseButton = findChild(receiveCard, "bannerCard_closeButton")
            verify(!!receiveCloseButton)
            verify(!receiveCloseButton.visible)
        }

        function test_hideBuy() {
            const buyCard = findChild(componentUnderTest, "buyCard")
            verify(!!buyCard)
            verify(buyCard.visible)

            componentUnderTest.buyEnabled = false
            tryVerify(() => !buyCard.visible)
        }

        function test_hideReceive() {
            const receiveCard = findChild(componentUnderTest, "receiveCard")
            verify(!!receiveCard)
            verify(receiveCard.visible)

            componentUnderTest.receiveEnabled = false
            tryVerify(() => !receiveCard.visible)
        }
    }
}
