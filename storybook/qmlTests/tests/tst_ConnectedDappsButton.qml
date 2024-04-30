import QtQuick 2.15
import QtTest 1.15

import QtQuick.Controls 2.15

import Storybook 1.0

import AppLayouts.Wallet.controls 1.0

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        ConnectedDappsButton {
            id: control
        }
    }

    TestCase {
        name: "ConnectedDappsButton"
        when: windowShown

        property ConnectedDappsButton controlUnderTest: null

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function test_ClickToOpenAndClosePopup() {
            verify(!!controlUnderTest)
            waitForRendering(controlUnderTest)

            mouseClick(controlUnderTest, Qt.LeftButton)
            waitForRendering(controlUnderTest)

            let popup = findChild(controlUnderTest, "dappsPopup")
            verify(!!popup)
            verify(popup.opened)

            mouseClick(Overlay.overlay, Qt.LeftButton)
            waitForRendering(controlUnderTest)

            verify(!popup.opened)
        }
    }
}
