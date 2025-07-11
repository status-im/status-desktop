import QtQuick
import QtTest

import AppLayouts.Wallet.controls

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: bannerCardComponent

        BannerCard {}
    }

    TestCase {
        id: bannerCardTest

        when: windowShown

        property BannerCard componentUnderTest

        function init() {
            componentUnderTest = createTemporaryObject(bannerCardComponent, root)
        }

        function test_empty() {
            compare(componentUnderTest.image, "")
            compare(componentUnderTest.title, "")
            compare(componentUnderTest.subTitle, "")
            compare(componentUnderTest.closeEnabled, true)
        }

        function test_geometry() {
            verify(componentUnderTest.height > 0)
            verify(componentUnderTest.width > 0)
        }

        function test_hoverState() {
            compare(componentUnderTest.hovered, false)
            mouseMove(componentUnderTest, componentUnderTest.width / 2, componentUnderTest.height / 2)
            compare(componentUnderTest.hovered, true)
            
            const closeButton = findChild(componentUnderTest, "bannerCard_closeButton")
            verify(!!closeButton)
            verify(closeButton.visible)
            verify(closeButton.width > 0)
            verify(closeButton.height > 0)

            mouseMove(closeButton, closeButton.width / 2, closeButton.height / 2)
            compare(componentUnderTest.hovered, true)
        }

        function test_click() {
            let clicked = false
            componentUnderTest.clicked.connect(() => {
                clicked = true
            })
            mouseClick(componentUnderTest)
            compare(clicked, true)

            clicked = false

            const closeButton = findChild(componentUnderTest, "bannerCard_closeButton")

            let closed = false
            componentUnderTest.close.connect(() => {
                closed = true
            })
            mouseMove(closeButton, closeButton.width / 2, closeButton.height / 2)
            mouseClick(closeButton)
            compare(closed, true)
            compare(clicked, false)
        }
    }
}
