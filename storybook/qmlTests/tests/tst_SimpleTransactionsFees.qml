import QtQuick 2.15
import QtTest 1.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.panels 1.0

Item {
    id: root
    width: 600
    height: 800

    Component {
        id: componentUnderTest

        SimpleTransactionsFees {}
    }

    TestCase {
        name: "SimpleTransactionsFees"
        when: windowShown

        property SimpleTransactionsFees controlUnderTest: null

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function test_defaulValues() {
            verify(!!controlUnderTest)
            const background = findChild(controlUnderTest, "background")
            verify(!!background)
            const gasIcon = findChild(controlUnderTest, "gasIcon")
            verify(!!gasIcon)
            const infoText = findChild(controlUnderTest, "infoText")
            verify(!!infoText)
            const cryptoFeesText = findChild(controlUnderTest, "cryptoFeesText")
            verify(!!cryptoFeesText)
            const fiatFeesText = findChild(controlUnderTest, "fiatFeesText")
            verify(!!fiatFeesText)

            compare(background.color, Theme.palette.indirectColor1)
            compare(gasIcon.asset.name, "gas")
            compare(infoText.text, qsTr("Est Mainnet transaction fee"))
            compare(cryptoFeesText.text, "--")
            verify(!cryptoFeesText.loading)
            compare(cryptoFeesText.customColor, Theme.palette.baseColor1)
            compare(fiatFeesText.text, "--")
            verify(!fiatFeesText.loading)
            compare(fiatFeesText.customColor, Theme.palette.baseColor1)
        }

        function test_setValues() {
            verify(!!controlUnderTest)
            const background = findChild(controlUnderTest, "background")
            verify(!!background)
            const gasIcon = findChild(controlUnderTest, "gasIcon")
            verify(!!gasIcon)
            const infoText = findChild(controlUnderTest, "infoText")
            verify(!!infoText)
            const cryptoFeesText = findChild(controlUnderTest, "cryptoFeesText")
            verify(!!cryptoFeesText)
            const fiatFeesText = findChild(controlUnderTest, "fiatFeesText")
            verify(!!fiatFeesText)

            controlUnderTest.cryptoFees = "0.0007 ETH"
            controlUnderTest.fiatFees = "1.45 EUR"

            compare(background.color, Theme.palette.indirectColor1)
            compare(gasIcon.asset.name, "gas")
            compare(infoText.text, qsTr("Est Mainnet transaction fee"))
            compare(cryptoFeesText.text,"0.0007 ETH")
            verify(!cryptoFeesText.loading)
            compare(cryptoFeesText.customColor, Theme.palette.baseColor1)
            compare(fiatFeesText.text, "1.45 EUR")
            verify(!fiatFeesText.loading)
            compare(fiatFeesText.customColor, Theme.palette.baseColor1)
        }

        function test_loadingState() {
            verify(!!controlUnderTest)
            const background = findChild(controlUnderTest, "background")
            verify(!!background)
            const gasIcon = findChild(controlUnderTest, "gasIcon")
            verify(!!gasIcon)
            const infoText = findChild(controlUnderTest, "infoText")
            verify(!!infoText)
            const cryptoFeesText = findChild(controlUnderTest, "cryptoFeesText")
            verify(!!cryptoFeesText)
            const fiatFeesText = findChild(controlUnderTest, "fiatFeesText")
            verify(!!fiatFeesText)

            controlUnderTest.loading = true

            compare(background.color, Theme.palette.indirectColor1)
            compare(gasIcon.asset.name, "gas")
            compare(infoText.text, qsTr("Est Mainnet transaction fee"))
            compare(cryptoFeesText.text,"XXXXXXXXXX")
            verify(cryptoFeesText.loading)
            compare(cryptoFeesText.customColor, Theme.palette.baseColor1)
            compare(fiatFeesText.text,"XXXXXXXXXX")
            verify(fiatFeesText.loading)
            compare(fiatFeesText.customColor, Theme.palette.baseColor1)

            controlUnderTest.cryptoFees = "0.0007 ETH"
            controlUnderTest.fiatFees = "1.45 EUR"

            compare(background.color, Theme.palette.indirectColor1)
            compare(gasIcon.asset.name, "gas")
            compare(infoText.text, qsTr("Est Mainnet transaction fee"))
            compare(cryptoFeesText.text,"0.0007 ETH")
            verify(cryptoFeesText.loading)
            compare(cryptoFeesText.customColor, Theme.palette.baseColor1)
            compare(fiatFeesText.text, "1.45 EUR")
            verify(fiatFeesText.loading)
            compare(fiatFeesText.customColor, Theme.palette.baseColor1)
        }

        function test_errorState() {
            verify(!!controlUnderTest)
            const background = findChild(controlUnderTest, "background")
            verify(!!background)
            const gasIcon = findChild(controlUnderTest, "gasIcon")
            verify(!!gasIcon)
            const infoText = findChild(controlUnderTest, "infoText")
            verify(!!infoText)
            const cryptoFeesText = findChild(controlUnderTest, "cryptoFeesText")
            verify(!!cryptoFeesText)
            const fiatFeesText = findChild(controlUnderTest, "fiatFeesText")
            verify(!!fiatFeesText)

            controlUnderTest.error = true
            controlUnderTest.cryptoFees = "0.0007 ETH"
            controlUnderTest.fiatFees = "1.45 EUR"

            compare(background.color, Theme.palette.indirectColor1)
            compare(gasIcon.asset.name, "gas")
            compare(infoText.text, qsTr("Est Mainnet transaction fee"))
            compare(cryptoFeesText.text,"0.0007 ETH")
            verify(!cryptoFeesText.loading)
            compare(cryptoFeesText.customColor, Theme.palette.dangerColor1)
            compare(fiatFeesText.text, "1.45 EUR")
            verify(!fiatFeesText.loading)
            compare(fiatFeesText.customColor, Theme.palette.dangerColor1)

            controlUnderTest.error = true
            controlUnderTest.cryptoFees = ""
            controlUnderTest.fiatFees = ""

            compare(background.color, Theme.palette.indirectColor1)
            compare(gasIcon.asset.name, "gas")
            compare(infoText.text, qsTr("Est Mainnet transaction fee"))
            compare(cryptoFeesText.text,"--")
            verify(!cryptoFeesText.loading)
            compare(cryptoFeesText.customColor, Theme.palette.baseColor1)
            compare(fiatFeesText.text, "--")
            verify(!fiatFeesText.loading)
            compare(fiatFeesText.customColor, Theme.palette.baseColor1)
        }
    }
}
