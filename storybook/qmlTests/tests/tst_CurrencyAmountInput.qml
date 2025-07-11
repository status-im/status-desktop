import QtQuick
import QtTest

import Storybook
import shared.controls

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        CurrencyAmountInput {
            id: input
            anchors.centerIn: parent
        }
    }

    QtObject {
        id: defaults

        readonly property int decimals: 2
        readonly property string currencySymbol: "USD"
    }

    TestCase {
        name: "CurrencyAmountInput"
        when: windowShown

        property CurrencyAmountInput controlUnderTest: null

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            controlUnderTest.locale = "en_US"
        }

        function test_getSetValueProgramatically() {
            verify(!!controlUnderTest)

            // initial value is 0
            verify(controlUnderTest.value === 0)

            // initial num of decimals is 2
            verify(controlUnderTest.decimals === defaults.decimals)

            // verify setting a value yields a valid state
            controlUnderTest.value = 1.23

            // verify both the value and text displayed is correct
            verify(controlUnderTest.valid)
            verify(controlUnderTest.value === 1.23)
            verify(controlUnderTest.text === "1.23")
            verify(controlUnderTest.text === controlUnderTest.asString)

            // verify setting value as text works as well
            controlUnderTest.value = "456.78"
            verify(controlUnderTest.valid)
            verify(controlUnderTest.value === 456.78)
            verify(controlUnderTest.text === "456.78")
            verify(controlUnderTest.text === controlUnderTest.asString)
        }

        function test_inputValueManually() {
            verify(!!controlUnderTest)

            // click the control to get focus and type "1.23"
            mouseClick(controlUnderTest)
            controlUnderTest.clear()
            keyClick(Qt.Key_1)
            keyClick(Qt.Key_Period)
            keyClick(Qt.Key_2)
            keyClick(Qt.Key_3)

            // verify we get 1.23 back
            verify(controlUnderTest.valid)
            verify(controlUnderTest.value === 1.23)
            verify(controlUnderTest.text === "1.23")
            verify(controlUnderTest.text === controlUnderTest.asString)
        }

        function test_decimals() {
            verify(!!controlUnderTest)

            // initial num of decimals is 2
            verify(controlUnderTest.decimals === defaults.decimals)

            // set 8 decimals
            controlUnderTest.decimals = 8
            verify(controlUnderTest.decimals === 8)

            // set a number with 8 decimals
            controlUnderTest.value = 1.12345678

            // verify the value and validity
            verify(controlUnderTest.valid)
            verify(controlUnderTest.value === 1.12345678)
            verify(controlUnderTest.text === "1.12345678")
            verify(controlUnderTest.text === controlUnderTest.asString)

            // set back to 3 decimals
            controlUnderTest.decimals = 3

            // setting a value with more decimals -> invalid
            controlUnderTest.value = 1.1234
            verify(!controlUnderTest.valid)
        }

        function test_currencySymbol() {
            verify(!!controlUnderTest)

            // USD is default
            verify(controlUnderTest.currencySymbol === defaults.currencySymbol)

            // try setting a different one
            controlUnderTest.currencySymbol = "EUR"
            verify(controlUnderTest.currencySymbol === "EUR")

            // try clearing the currency symbol
            controlUnderTest.currencySymbol = ""
            verify(controlUnderTest.currencySymbol === "")
        }

        function test_explicitLocale() {
            verify(!!controlUnderTest)
            controlUnderTest.locale = "cs_CZ"

            // verify setting a value programatically yields a valid state
            controlUnderTest.value = 1.23
            verify(controlUnderTest.valid)
            verify(controlUnderTest.value === 1.23)
            verify(controlUnderTest.text === "1,23")

            // verify the text displayed observes the locale decimal point (,)
            verify(controlUnderTest.text === "1,23")

            // verify typing both a period and comma (this locale's decimal separator) both yield the same correct value
            mouseClick(controlUnderTest)

            // first with the default comma (,) as decimal separator
            controlUnderTest.clear()
            keyClick(Qt.Key_6)
            keyClick(Qt.Key_Comma)
            keyClick(Qt.Key_6)
            keyClick(Qt.Key_6)
            verify(controlUnderTest.valid)
            verify(controlUnderTest.value === 6.66)
            verify(controlUnderTest.text === "6,66")

            // try the fallback decimal separator (.)
            controlUnderTest.clear()
            verify(controlUnderTest.text === "")
            keyClick(Qt.Key_6)
            keyClick(Qt.Key_Period)
            keyClick(Qt.Key_6)
            keyClick(Qt.Key_6)
            verify(controlUnderTest.valid)
            verify(controlUnderTest.value === 6.66)
            verify(controlUnderTest.text === "6,66")
        }

        function test_validator() {
            verify(!!controlUnderTest)
            controlUnderTest.decimals = 4
            controlUnderTest.value = 1.1234
            verify(controlUnderTest.valid)

            controlUnderTest.decimals = 3
            verify(!controlUnderTest.valid)

            // delete one char from the middle and type some string
            mouseClick(controlUnderTest)
            keyClick(Qt.Key_Left)
            keyClick(Qt.Key_Left)
            keyClick(Qt.Key_Backspace)
            keyClick(Qt.Key_A) // <== should get ignored

            verify(controlUnderTest.valid)
            verify(controlUnderTest.value === 1.134)
        }
    }
}
