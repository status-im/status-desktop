import QtQuick 2.15
import QtTest 1.15

import AppLayouts.Wallet.controls 1.0

import Storybook 1.0

import StatusQ.Components 0.1

Item {
    id: root

    width: 600
    height: 400

    Component {
        id: buttonCmp

        TokenSelectorButton {
            name: "ETH"
            icon: ""
        }
    }

    TestCase {
        name: "TokenSelectorButton"
        when: windowShown

        function test_notSelected() {
            const button = createTemporaryObject(buttonCmp, root)

            verify(TestUtils.findTextItem(button, button.text))
            verify(!TestUtils.findTextItem(button, "ETH"))
            verify(findChild(button, "notSelectedContent"))
        }

        function test_selected() {
            const button = createTemporaryObject(buttonCmp, root)
            button.selected = true

            verify(!TestUtils.findTextItem(button, button.text))
            verify(TestUtils.findTextItem(button, "ETH"))
            verify(findChild(button, "selectedContent"))

            const icon = TestUtils.findByType(button, StatusRoundedImage)
            verify(icon)
            compare(icon.width, 24)
            compare(icon.height, 24)
        }
    }
}
