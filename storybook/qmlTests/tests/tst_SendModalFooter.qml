import QtQuick 2.15
import QtTest 1.15
import QtQml.Models 2.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.views 1.0
import AppLayouts.Wallet.controls 1.0

Item {
    id: root
    width: 600
    height: 800

    Component {
        id: componentUnderTest

        SendModalFooter {
            id: sendModalFooter
            readonly property SignalSpy reviewSendClickedSpy: SignalSpy {
                target: sendModalFooter
                signalName: "reviewSendClicked"
            }
        }
    }

    ObjectModel {
        id: errorTagsModel
        RouterErrorTag {
            errorTitle: qsTr("Insufficient funds for send transaction")
            buttonText: qsTr("Add assets")
        }
    }

    TestCase {
        name: "SendModalFooter"
        when: windowShown

        property SendModalFooter controlUnderTest: null

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function test_defaulValues() {
            verify(!!controlUnderTest)
            const estTimeLabel = findChild(controlUnderTest, "estTimeLabel")
            verify(!!estTimeLabel)
            const estimatedTimeText = findChild(controlUnderTest, "estimatedTimeText")
            verify(!!estimatedTimeText)
            const estFeesLabel = findChild(controlUnderTest, "estFeesLabel")
            verify(!!estFeesLabel)
            const estimatedFeesText = findChild(controlUnderTest, "estimatedFeesText")
            verify(!!estimatedFeesText)
            const transactionModalFooterButton = findChild(controlUnderTest, "transactionModalFooterButton")
            verify(!!transactionModalFooterButton)

            compare(controlUnderTest.color, Theme.palette.baseColor3)
            verify(controlUnderTest.dropShadowEnabled)

            compare(estTimeLabel.text, qsTr("Est time"))
            compare(estimatedTimeText.text, "--")
            compare(estimatedTimeText.customColor, Theme.palette.directColor5)
            verify(!estimatedTimeText.loading)

            compare(estFeesLabel.text, qsTr("Est fees"))
            compare(estimatedFeesText.text, "--")
            compare(estimatedFeesText.customColor, Theme.palette.directColor5)
            verify(!estimatedFeesText.loading)

            compare(transactionModalFooterButton.text, qsTr("Review Send"))
            verify(!transactionModalFooterButton.enabled)
            compare(transactionModalFooterButton.disabledColor, Theme.palette.directColor8)
        }

        function test_setValues() {
            verify(!!controlUnderTest)
            const estTimeLabel = findChild(controlUnderTest, "estTimeLabel")
            verify(!!estTimeLabel)
            const estimatedTimeText = findChild(controlUnderTest, "estimatedTimeText")
            verify(!!estimatedTimeText)
            const estFeesLabel = findChild(controlUnderTest, "estFeesLabel")
            verify(!!estFeesLabel)
            const estimatedFeesText = findChild(controlUnderTest, "estimatedFeesText")
            verify(!!estimatedFeesText)
            const transactionModalFooterButton = findChild(controlUnderTest, "transactionModalFooterButton")
            verify(!!transactionModalFooterButton)

            controlUnderTest.estimatedTime = "~60s"
            controlUnderTest.estimatedFees = "1.45 EUR"

            compare(estTimeLabel.text, qsTr("Est time"))
            compare(estimatedTimeText.text, "~60s")
            compare(estimatedTimeText.customColor, Theme.palette.directColor1)
            verify(!estimatedTimeText.loading)

            compare(estFeesLabel.text, qsTr("Est fees"))
            compare(estimatedFeesText.text, "1.45 EUR")
            compare(estimatedFeesText.customColor, Theme.palette.directColor1)
            verify(!estimatedFeesText.loading)

            compare(transactionModalFooterButton.text, qsTr("Review Send"))
            verify(transactionModalFooterButton.enabled)
            mouseClick(transactionModalFooterButton)

            controlUnderTest.reviewSendClickedSpy.wait()
        }

        function test_loadingState() {
            verify(!!controlUnderTest)
            const estTimeLabel = findChild(controlUnderTest, "estTimeLabel")
            verify(!!estTimeLabel)
            const estimatedTimeText = findChild(controlUnderTest, "estimatedTimeText")
            verify(!!estimatedTimeText)
            const estFeesLabel = findChild(controlUnderTest, "estFeesLabel")
            verify(!!estFeesLabel)
            const estimatedFeesText = findChild(controlUnderTest, "estimatedFeesText")
            verify(!!estimatedFeesText)
            const transactionModalFooterButton = findChild(controlUnderTest, "transactionModalFooterButton")
            verify(!!transactionModalFooterButton)

            controlUnderTest.loading = true

            compare(estTimeLabel.text, qsTr("Est time"))
            compare(estimatedTimeText.text, "XXXXXXXXXX")
            compare(estimatedTimeText.customColor, Theme.palette.directColor5)
            verify(estimatedTimeText.loading)

            compare(estFeesLabel.text, qsTr("Est fees"))
            compare(estimatedFeesText.text, "XXXXXXXXXX")
            compare(estimatedFeesText.customColor, Theme.palette.directColor5)
            verify(estimatedFeesText.loading)

            compare(transactionModalFooterButton.text, qsTr("Review Send"))
            verify(!transactionModalFooterButton.enabled)
        }

        function test_errorState() {
            verify(!!controlUnderTest)
            const estTimeLabel = findChild(controlUnderTest, "estTimeLabel")
            verify(!!estTimeLabel)
            const estimatedTimeText = findChild(controlUnderTest, "estimatedTimeText")
            verify(!!estimatedTimeText)
            const estFeesLabel = findChild(controlUnderTest, "estFeesLabel")
            verify(!!estFeesLabel)
            const estimatedFeesText = findChild(controlUnderTest, "estimatedFeesText")
            verify(!!estimatedFeesText)
            const transactionModalFooterButton = findChild(controlUnderTest, "transactionModalFooterButton")
            verify(!!transactionModalFooterButton)

            controlUnderTest.error = true

            waitForRendering(controlUnderTest)

            compare(estTimeLabel.text, qsTr("Est time"))
            compare(estimatedTimeText.text, "--")
            compare(estimatedTimeText.customColor, Theme.palette.directColor5)
            verify(!estimatedTimeText.loading)

            compare(estFeesLabel.text, qsTr("Est fees"))
            compare(estimatedFeesText.text, "--")
            tryCompare(estimatedFeesText, "customColor", Theme.palette.directColor5)
            verify(!estimatedFeesText.loading)

            compare(transactionModalFooterButton.text, qsTr("Review Send"))
            verify(!transactionModalFooterButton.enabled)

            verify(!controlUnderTest.errorTags)

            controlUnderTest.errorTags = errorTagsModel
            compare(controlUnderTest.errorTags, errorTagsModel)

            // error and values are set
            controlUnderTest.error = true
            controlUnderTest.estimatedTime = "~60s"
            controlUnderTest.estimatedFees = "1.45 EUR"

            compare(estTimeLabel.text, qsTr("Est time"))
            compare(estimatedTimeText.text, "~60s")
            compare(estimatedTimeText.customColor, Theme.palette.directColor1)
            verify(!estimatedTimeText.loading)

            compare(estFeesLabel.text, qsTr("Est fees"))
            compare(estimatedFeesText.text, "1.45 EUR")
            tryCompare(estimatedFeesText, "customColor", Theme.palette.dangerColor1)
            verify(!estimatedFeesText.loading)

            verify(!transactionModalFooterButton.enabled)
        }
    }
}
