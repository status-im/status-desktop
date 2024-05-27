import QtQuick 2.15
import QtTest 1.15

import StatusQ.Core.Theme 0.1

import Models 1.0
import utils 1.0

import AppLayouts.Wallet.popups 1.0

Item {
    id: root
    width: 600
    height: 800

    OnRampProvidersModel{
        id: onRampProvidersModal
    }

    Component {
        id: componentUnderTest
        BuyCryptoModal {
            onRampProvidersModel: onRampProvidersModal
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
            mouseClick(footer.rightButtons.get(0), Qt.LeftButton)

            // popup should be closed
            verify(!controlUnderTest.opened)
        }

        function test_modalContent() {
            // Launch modal
            launchPopup()

            // find tab bar
            const tabBar = findChild(controlUnderTest, "tabBar")
            verify(!!tabBar)

            // should have 2 items
            compare(tabBar.count, 2)

            // current index set should be to 0
            compare(tabBar.currentIndex, 0)

            // item 0 should have text "One time"
            compare(tabBar.itemAt(0).text, qsTr("One time"))

            // item 1 should have text "Recurrent"
            compare(tabBar.itemAt(1).text, qsTr("Recurrent"))

            // TODO: this will be implemnted under https://github.com/status-im/status-desktop/issues/14820
            // until then this list will be empty
            mouseClick(tabBar.itemAt(1), Qt.LeftButton)
            compare(tabBar.currentIndex, 1)

            const providersList = findChild(controlUnderTest, "providersList")
            waitForRendering(providersList)
            verify(!!providersList)
            compare(providersList.count, 0)

            // check data on 1st tab --------------------------------------------------------
            mouseClick(tabBar.itemAt(0), Qt.LeftButton)
            compare(tabBar.currentIndex, 0)

            waitForRendering(providersList)
            verify(!!providersList)

            // verify that 3 items are listed
            compare(providersList.count, 3)

            // check if delegate contents are as expected
            for(let i =0; i< providersList.count; i++) {
                let delegateUnderTest = providersList.itemAtIndex(i)
                verify(!!delegateUnderTest)

                compare(delegateUnderTest.title, onRampProvidersModal.get(i).name)
                compare(delegateUnderTest.subTitle, onRampProvidersModal.get(i).description)
                compare(delegateUnderTest.asset.name, onRampProvidersModal.get(i).logoUrl)

                const feesText = findChild(delegateUnderTest, "feesText")
                verify(!!feesText)
                compare(feesText.text,  onRampProvidersModal.get(i).fees)

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

            // test mouse click
            tryCompare(notificationSpy, "count", 0)
            mouseClick(providersList.itemAtIndex(0))
            tryCompare(notificationSpy, "count", 1)
            compare(notificationSpy.signalArguments[0][0],onRampProvidersModal.get(0).siteUrl)
            compare(notificationSpy.signalArguments[0][1],onRampProvidersModal.get(0).hostname)
        }
    }
}
