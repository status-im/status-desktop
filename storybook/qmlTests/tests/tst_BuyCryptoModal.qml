import QtQuick 2.15
import QtTest 1.15

import SortFilterProxyModel 0.2

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import Models 1.0
import utils 1.0

import AppLayouts.Wallet.popups 1.0

Item {
    id: root
    width: 600
    height: 800

    OnRampProvidersModel{
        id: _onRampProvidersModel
    }

    SortFilterProxyModel {
        id: recurrentOnRampProvidersModel
        sourceModel: _onRampProvidersModel
        filters: ValueFilter {
            roleName: "recurrentSiteUrl"
            value: ""
            inverted: true
        }
    }

    Component {
        id: componentUnderTest
        BuyCryptoModal {
            onRampProvidersModel: _onRampProvidersModel
            onClosed: destroy()
        }
    }

    SignalSpy {
        id: notificationSpy
        target: Global
        signalName: "openLinkWithConfirmation"
    }

    TestCase {
        name: "BuyCryptoModal"
        when: windowShown

        property BuyCryptoModal controlUnderTest: null

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }

        function launchPopup() {
            verify(!!controlUnderTest)
            controlUnderTest.open()
            verify(!!controlUnderTest.opened)
        }

        function testDelegateItems(providersList, modelToCompareAgainst) {
            for(let i =0; i< providersList.count; i++) {
                let delegateUnderTest = providersList.itemAtIndex(i)
                verify(!!delegateUnderTest)

                compare(delegateUnderTest.title, modelToCompareAgainst.get(i).name)
                compare(delegateUnderTest.subTitle, modelToCompareAgainst.get(i).description)
                compare(delegateUnderTest.asset.name, modelToCompareAgainst.get(i).logoUrl)

                const feesText = findChild(delegateUnderTest, "feesText")
                verify(!!feesText)
                compare(feesText.text,  modelToCompareAgainst.get(i).fees)

                const externalLinkIcon = findChild(delegateUnderTest, "externalLinkIcon")
                verify(!!externalLinkIcon)
                compare(externalLinkIcon.icon, "tiny/external")
                compare(externalLinkIcon.color, Theme.palette.baseColor1)

                // Hover over the item and check hovered state
                mouseMove(delegateUnderTest, delegateUnderTest.width/2, delegateUnderTest.height/2)
                verify(delegateUnderTest.sensor.containsMouse)
                compare(externalLinkIcon.color, Theme.palette.directColor1)
                verify(delegateUnderTest.color, Theme.palette.baseColor2)
            }
        }

        function test_launchAndCloseModal() {
            launchPopup()

            // close popup
            controlUnderTest.close()
            verify(!controlUnderTest.opened)
        }

        function test_ModalFooter() {
            // Launch modal
            launchPopup()

            // check if footer has Done button and action on button clicked
            const footer = findChild(controlUnderTest, "footer")
            verify(!!footer)
            compare(footer.rightButtons.count, 1)
            compare(footer.rightButtons.get(0).text, qsTr("Done"))
            mouseClick(footer.rightButtons.get(0))

            // popup should be closed
            verify(!controlUnderTest.opened)
        }

        function test_modalContent() {
            // Launch modal
            launchPopup()

            // find tab bar
            const tabBar = findChild(controlUnderTest, "tabBar")
            verify(!!tabBar)

            // find providers list
            const providersList = findChild(controlUnderTest, "providersList")
            waitForRendering(providersList)
            verify(!!providersList)

            // should have 2 items
            compare(tabBar.count, 2)

            // current index set should be to 0
            compare(tabBar.currentIndex, 0)

            // item 0 should have text "One time"
            compare(tabBar.itemAt(0).text, qsTr("One time"))

            // item 1 should have text "Recurrent"
            compare(tabBar.itemAt(1).text, qsTr("Recurrent"))

            // close popup
            controlUnderTest.close()
            verify(!controlUnderTest.opened)
        }

        function test_modalContent_OneTime_tab() {
            // Launch modal
            launchPopup()

            // find tab bar
            const tabBar = findChild(controlUnderTest, "tabBar")
            verify(!!tabBar)

            // find providers list
            const providersList = findChild(controlUnderTest, "providersList")
            waitForRendering(providersList)
            verify(!!providersList)

            mouseClick(tabBar.itemAt(0))
            compare(tabBar.currentIndex, 0)

            // verify that 3 items are listed
            compare(providersList.count, 3)

            // check if delegate contents are as expected
            testDelegateItems(providersList, _onRampProvidersModel)

            let delegateUnderTest = providersList.itemAtIndex(0)
            verify(!!delegateUnderTest)

            // test mouse click
            tryCompare(notificationSpy, "count", 0)
            mouseClick(delegateUnderTest)
            tryCompare(notificationSpy, "count", 1)
            compare(notificationSpy.signalArguments[0][0], _onRampProvidersModel.get(0).siteUrl)
            compare(notificationSpy.signalArguments[0][1], _onRampProvidersModel.get(0).hostname)
            notificationSpy.clear()

            // popup should be closed
            verify(!controlUnderTest.opened)
        }

        function test_modalContent_recurrent_tab() {
            // Launch modal
            launchPopup()

            // find tab bar
            const tabBar = findChild(controlUnderTest, "tabBar")
            verify(!!tabBar)

            // find providers list
            const providersList = findChild(controlUnderTest, "providersList")
            waitForRendering(providersList)
            verify(!!providersList)


            // check data in "Recurrent" tab --------------------------------------------------------
            mouseClick(tabBar.itemAt(1))
            compare(tabBar.currentIndex, 1)
            waitForRendering(providersList)
            verify(!!providersList)

            // verify that 1 item is listed
            compare(providersList.count, 1)

            // check if delegate contents are as expected
            testDelegateItems(providersList, recurrentOnRampProvidersModel)

            let delegateUnderTest = providersList.itemAtIndex(0)
            verify(!!delegateUnderTest)

            // test mouse click
            tryCompare(notificationSpy, "count", 0)
            verify(controlUnderTest.opened)
            mouseClick(delegateUnderTest)
            tryCompare(notificationSpy, "count", 1)
            compare(notificationSpy.signalArguments[0][0], recurrentOnRampProvidersModel.get(0).recurrentSiteUrl)
            compare(notificationSpy.signalArguments[0][1], recurrentOnRampProvidersModel.get(0).hostname)
            notificationSpy.clear()

            // popup should be closed
            verify(!controlUnderTest.opened)
        }
    }
}
