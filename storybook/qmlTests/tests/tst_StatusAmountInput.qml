import QtQuick
import QtTest

import StatusQ.Controls

import Storybook
import shared.controls

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        StatusAmountInput {
            id: input
            anchors.centerIn: parent
            locale: Qt.locale("en_US") // US uses period as decimal point
        }
    }

    TestCase {
        name: "StatusAmountInput"
        when: windowShown

        property StatusAmountInput controlUnderTest: null

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            controlUnderTest.forceActiveFocus()
        }

        function test_decimalPoint() {
            verify(!!controlUnderTest)

            keyClick(Qt.Key_1)
            keyClick(Qt.Key_2)
            keyClick(Qt.Key_Comma)
            keyClick(Qt.Key_2)

            compare(controlUnderTest.text, "12.2")

            keyClick(Qt.Key_Period)
            compare(controlUnderTest.text, "12.2", "There can be only single decimal point")

            controlUnderTest.text = ""
            compare(controlUnderTest.text.length, 0)

            keyClick(Qt.Key_5)
            keyClick(Qt.Key_3)
            keyClick(Qt.Key_Period)
            keyClick(Qt.Key_3)

            compare(controlUnderTest.text, "53.3")
            keyClick(Qt.Key_Comma)
            compare(controlUnderTest.text, "53.3", "There can be only single decimal point")

            controlUnderTest.text = ""
            compare(controlUnderTest.text.length, 0)

            controlUnderTest.locale = Qt.locale("pl_PL") // PL uses comma as decimal point

            keyClick(Qt.Key_6)
            keyClick(Qt.Key_2)
            keyClick(Qt.Key_Period)
            keyClick(Qt.Key_1)

            compare(controlUnderTest.text, "62,1")
        }

        function test_unallowedKeys() {
            verify(!!controlUnderTest)

            keyClick(Qt.Key_1)
            for (let i = Qt.Key_A ; i <= Qt.Key_BracketRight ; i++) {
                keyClick(i)
            }
            keyClick(Qt.Key_Space)
            keyClick(Qt.Key_3)

            compare(controlUnderTest.text, "13")
            compare(controlUnderTest.valid, true)
        }

        function test_defaultValidation() {
            verify(!!controlUnderTest)

            verify(!controlUnderTest.valid)

            keyClick(Qt.Key_4)
            verify(controlUnderTest.valid)

            controlUnderTest.text = "-12"
            verify(!controlUnderTest.valid, "Amount below zero is not allowed")
        }
    }
}
