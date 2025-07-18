import QtQuick
import QtTest

import mainui

Item {
    id: root
    width: 800
    height: 600

    Component {
        id: componentUnderTest
        GlobalBanner {
            anchors.centerIn: parent
            width: 600
            isOnline: false
            testnetEnabled: false
            seedphraseBackedUp: false
        }
    }

    SignalSpy {
        id: testNetButtonSignalSpy
        target: controlUnderTest
        signalName: "openTestnetPopupRequested"
    }

    SignalSpy {
        id: seedphraseButtonSignalSpy
        target: controlUnderTest
        signalName: "openBackUpSeedPopupRequested"
    }

    SignalSpy {
        id: seedphraseCloseButtonSignalSpy
        target: controlUnderTest
        signalName: "userDeclinedBackupBannerRequested"
    }

    property GlobalBanner controlUnderTest: null

    TestCase {
        name: "GlobalBanner"
        when: windowShown

        function init() {
            testNetButtonSignalSpy.clear()
            seedphraseButtonSignalSpy.clear()
            seedphraseCloseButtonSignalSpy.clear()
        }

        function test_basicGeometry() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)
            tryVerify(() => controlUnderTest.width > 0)
            tryVerify(() => controlUnderTest.height > 0)
        }

        // assert that at most 1 banner is displayed at any given time, and it's the correct one
        // "1. Offline/online > 2. Testnet > 3. Seedphrase"
        function test_variations_data() {
            return [
                        // offline/online banner
                        {isOnline: false, testnetEnabled: false, seedphraseBackedUp: false, banner: "connectionInfoBanner"},
                        {isOnline: false, testnetEnabled: true, seedphraseBackedUp: false, banner: "connectionInfoBanner"},
                        {isOnline: false, testnetEnabled: false, seedphraseBackedUp: true, banner: "connectionInfoBanner"},
                        {isOnline: false, testnetEnabled: true, seedphraseBackedUp: true, banner: "connectionInfoBanner"},

                        // testnet banner
                        {isOnline: true, testnetEnabled: true, seedphraseBackedUp: false, banner: "testnetBanner"},
                        {isOnline: true, testnetEnabled: true, seedphraseBackedUp: true, banner: "testnetBanner"},

                        // seedphrase banner
                        {isOnline: true, testnetEnabled: false, seedphraseBackedUp: false, banner: "secureYourSeedPhraseBanner"},

                        // no banner
                        {isOnline: true, testnetEnabled: false, seedphraseBackedUp: true, banner: ""},
                    ]
        }

        function test_variations(data) {
            controlUnderTest = createTemporaryObject(componentUnderTest, root, data)
            verify(!!controlUnderTest)
            if (!!data.banner) {
                tryCompare(controlUnderTest.item, "objectName", data.banner)
                tryCompare(controlUnderTest.item, "visible", true)
            } else {
                tryVerify(() => controlUnderTest.item === null) // no banner, not visible at all
            }
        }

        // test that the testnet banner's button emits the right signal to open the resp. popup
        function test_testnet_button() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root,
                                                     {isOnline: true, testnetEnabled: true, seedphraseBackedUp: false})
            verify(!!controlUnderTest)
            tryCompare(controlUnderTest.item, "objectName", "testnetBanner")

            const btn = findChild(controlUnderTest.item, "actionButton")
            verify(!!btn)
            mouseClick(btn)
            compare(testNetButtonSignalSpy.count, 1)
        }

        // test that the seedphrase banner's buttons emit the right signals to open the resp. popup
        function test_seedphrase_buttons() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root,
                                                     {isOnline: true, testnetEnabled: false, seedphraseBackedUp: false})
            verify(!!controlUnderTest)
            tryCompare(controlUnderTest.item, "objectName", "secureYourSeedPhraseBanner")

            const btn = findChild(controlUnderTest.item, "actionButton")
            verify(!!btn)
            mouseClick(btn)
            compare(seedphraseButtonSignalSpy.count, 1)

            const closeBtn = findChild(controlUnderTest.item, "closeButton")
            verify(!!closeBtn)
            mouseClick(closeBtn)
            compare(seedphraseCloseButtonSignalSpy.count, 1)
        }
    }
}
