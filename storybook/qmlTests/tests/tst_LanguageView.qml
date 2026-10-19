import QtQuick
import QtTest

import AppLayouts.Profile.views

Item {
    id: root

    width: 800
    height: 700

    Component {
        id: componentUnderTest

        LanguageView {
            width: 700
            height: 600
            contentWidth: 500

            availableLanguages: ["en", "ko"]
            currentLanguage: "en"
            currentCurrency: "USD"
            currenciesModel: ListModel {
                ListElement {
                    key: "usd"
                    shortName: "USD"
                    name: "US Dollars"
                    symbol: "$"
                    category: ""
                    imageSource: ""
                    selected: true
                    isToken: false
                }
            }
        }
    }

    SignalSpy {
        id: languageSpy
        signalName: "changeLanguageRequested"
    }

    SignalSpy {
        id: spellCheckSpy
        signalName: "spellCheckEnabledChangeRequested"
    }

    SignalSpy {
        id: capitalizationSpy
        signalName: "spellCheckSkipCapitalizedWordsChangeRequested"
    }

    property LanguageView controlUnderTest: null

    TestCase {
        name: "LanguageView"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
            verify(!!controlUnderTest)
            languageSpy.target = controlUnderTest
            languageSpy.clear()
            spellCheckSpy.target = controlUnderTest
            spellCheckSpy.clear()
            capitalizationSpy.target = controlUnderTest
            capitalizationSpy.clear()
        }

        function cleanup() {
            if (controlUnderTest) {
                controlUnderTest.destroy()
                controlUnderTest = null
            }
            languageSpy.clear()
        }

        function openKoreanDialog() {
            const selector = findChild(controlUnderTest, "languageViewLanguageSelector")
            verify(!!selector)
            mouseClick(selector)

            const dropdown = findChild(selector, "statusLanguageSelectorDropdown")
            verify(!!dropdown)
            tryCompare(dropdown, "opened", true)
            waitForRendering(selector)

            const listView = findChild(dropdown.contentItem, "statusLanguageSelectorListView")
            verify(!!listView)
            waitForRendering(listView)
            const item = findChild(listView, "itemDelegate_ko")
            verify(!!item)
            mouseClick(item)

            const dialog = findChild(controlUnderTest, "ConfirmationDialog")
            verify(!!dialog)
            tryCompare(dialog, "opened", true)
            return dialog
        }

        function test_confirm_requestsLanguageChange() {
            const dialog = openKoreanDialog()
            const confirmButton = findChild(dialog, "languageViewLanguageChangeConfirmButton")
            verify(!!confirmButton)
            mouseClick(confirmButton)

            compare(languageSpy.count, 1)
            compare(languageSpy.signalArguments[0][0], "ko")
        }

        function test_spellCheckDefaultsAndToggles() {
            const enabled = findChild(controlUnderTest, "languageViewSpellCheckEnabled")
            const skip = findChild(controlUnderTest, "languageViewSpellCheckSkipCapitalizedWords")
            verify(enabled.checked)
            verify(skip.checked)
            mouseClick(skip)
            compare(capitalizationSpy.count, 1)
            compare(capitalizationSpy.signalArguments[0][0], false)
            mouseClick(enabled)
            compare(spellCheckSpy.count, 1)
            compare(spellCheckSpy.signalArguments[0][0], false)
            controlUnderTest.spellCheckEnabled = false
            verify(!skip.enabled)
        }

        function test_cancel_keepsCurrentLanguage() {
            const dialog = openKoreanDialog()
            dialog.close()

            compare(languageSpy.count, 0)
            compare(controlUnderTest.currentLanguage, "en")
        }
    }
}
