import QtQuick 2.15
import QtTest 1.15

import AppLayouts.Wallet.controls 1.0

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        RouterErrorTag {
            anchors.centerIn: parent
            errorTitle: "Not enough ETH to pay gas fees"
        }
    }

    SignalSpy {
        id: signalSpy
        target: controlUnderTest
        signalName: "buttonClicked"
    }

    property RouterErrorTag controlUnderTest: null

    TestCase {
        name: "RouterErrorTag"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            signalSpy.clear()
        }

        function test_basicGeometry() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
        }

        function test_DefaultState() {
            verify(!!controlUnderTest)
            const errorTitle = findChild(controlUnderTest, "errorTitle")
            verify(!!errorTitle)
            verify(errorTitle.visible)
            const button = findChild(controlUnderTest, "addBalanceButton")
            verify(!!button)
            verify(!button.visible)
            const expandButton = findChild(controlUnderTest, "expandButton")
            verify(!!expandButton)
            verify(!expandButton.visible)
            const errorDetails = findChild(controlUnderTest, "errorDetails")
            verify(!!errorDetails)
            verify(!errorDetails.visible)
        }

        function test_correctWidthWithButtonOrWithout() {
            verify(!!controlUnderTest)
            waitForRendering(controlUnderTest)
            const origWidth = controlUnderTest.width

            controlUnderTest.buttonText = "Add assets"
            waitForRendering(controlUnderTest)
            const widthWithButton = controlUnderTest.width
            verify(widthWithButton > origWidth)

            controlUnderTest.buttonText = ""
            waitForRendering(controlUnderTest)
            verify(controlUnderTest.width < widthWithButton)
        }

        function test_addButtonClick() {
            verify(!!controlUnderTest)
            controlUnderTest.buttonText = "Add assets"
            const button = findChild(controlUnderTest, "addBalanceButton")
            verify(!!button)
            verify(button.visible)
            mouseClick(button)
            tryCompare(signalSpy, "count", 1)
        }

        function test_detailsVisibleOnceItHasValidText() {
            verify(!!controlUnderTest)
            const errorDetails = findChild(controlUnderTest, "errorDetails")
            verify(!!errorDetails)
            verify(!errorDetails.visible)

            controlUnderTest.errorDetails = "Added some details here"
            verify(errorDetails.visible)
        }

        function test_expandableOption() {
            verify(!!controlUnderTest)
            controlUnderTest.buttonText = "Add assets"
            controlUnderTest.errorDetails = "Added some details here"

            const errorTitle = findChild(controlUnderTest, "errorTitle")
            verify(!!errorTitle)
            const button = findChild(controlUnderTest, "addBalanceButton")
            verify(!!button)
            const expandButton = findChild(controlUnderTest, "expandButton")
            verify(!!expandButton)
            const errorDetails = findChild(controlUnderTest, "errorDetails")
            verify(!!errorDetails)

            controlUnderTest.expandable = true
            verify(errorTitle.visible)
            verify(!button.visible)
            verify(expandButton.visible)
            compare(expandButton.text, qsTr("+ Show details"))
            verify(!errorDetails.visible)

            mouseClick(expandButton)
            compare(expandButton.text, qsTr("- Hide details"))
            verify(errorDetails.visible)

            controlUnderTest.expandable = false
            verify(errorTitle.visible)
            verify(button.visible)
            verify(!expandButton.visible)
            verify(errorDetails.visible)
        }
    }
}
