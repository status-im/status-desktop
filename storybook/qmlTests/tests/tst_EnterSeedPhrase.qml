import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import QtTest 1.15

import shared.panels 1.0
import utils 1.0

Item {
    id: root
    width: 600
    height: 400

    TestCase {
        name: "EnterSeedPhraseTest"
        when: windowShown

        Component {
            id: enterSeedPhraseComponent
            EnterSeedPhrase {
                id: enterSeedPhrase
                anchors.fill: parent
                dictionary: ListModel {}
                
                readonly property SignalSpy submitSpy: SignalSpy { target: enterSeedPhrase; signalName: "submitSeedPhrase" }
                readonly property SignalSpy seedPhraseUpdatedSpy: SignalSpy { target: enterSeedPhrase; signalName: "seedPhraseUpdated" }
            }
        }

        property EnterSeedPhrase itemUnderTest: null

        function generateDictionaryVariation(baseDictionary) {
            let dictionaryVariation = baseDictionary.map((word) => word + "a")
            dictionaryVariation = baseDictionary.map((word) => word + "b").concat(dictionaryVariation)
            dictionaryVariation = baseDictionary.map((word) => word + "c").concat(dictionaryVariation)
            dictionaryVariation = baseDictionary.map((word) => word + "d").concat(dictionaryVariation)
            dictionaryVariation.sort()
            return dictionaryVariation
        }

        function init() {
            itemUnderTest = createTemporaryObject(enterSeedPhraseComponent, root)
            waitForItemPolished(itemUnderTest)
            waitForRendering(itemUnderTest)
        }

        // regression test for https://github.com/status-im/status-desktop/issues/16291
        function test_threeLetterPrefixSuggestionInput() {
            const commonPrefixToTest = "cat"

            //generate a seed phrase
            const expectedSeedPhrase = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", commonPrefixToTest]
            const baseDictionary = [...expectedSeedPhrase, "cow", "catalog", "catch", "category", "cattle"]

            let isSeedPhraseValidCalled = false
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                verify(seedPhrase === expectedSeedPhrase.join(" "), "Seed phrase is not valid")
                isSeedPhraseValidCalled = true
                return true
            }

            itemUnderTest.dictionary.append(baseDictionary.map((word) => ({seedWord: word})))

            //Type the seed phrase except the last word
            const str = expectedSeedPhrase.join(" ")
            for (let i = 0; i < str.length - commonPrefixToTest.length; i++) {
                keyPress(str.charAt(i))
            }

            const lastInputField = findChild(itemUnderTest, "enterSeedPhraseInputField12")
            verify(!!lastInputField)
            mouseClick(lastInputField)
            tryCompare(lastInputField, "activeFocus", true)

            // type the common prefix -> "cat..."
            keyClick(Qt.Key_C)
            keyClick(Qt.Key_A)
            keyClick(Qt.Key_T)
            tryCompare(lastInputField, "text", "cat")

            // hit Enter to accept "cat"
            keyClick(Qt.Key_Enter)
            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")

            // hit Enter to submit the form
            keyClick(Qt.Key_Enter)
            verify(itemUnderTest.submitSpy.count === 1, "submitSeedPhrase signal was not emitted")
            // This signal is emitted multiple times due to the way the seed phrase is updated and validated
            // The minimum is the length if the seed phrase
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        function test_componentCreation() {
            verify(itemUnderTest !== null, "Component creation failed")
        }

        // Test seed phrase input by typing on the keyboard
        // The seed phrase is valid and the typing is done without any space between words
        // This is the most common way to input a seed phrase
        function test_seedPhraseKeyboardInput() {
            //generate a seed phrase
            const expectedSeedPhrase = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
            expectedSeedPhrase.sort();
            
            let isSeedPhraseValidCalled = false
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                verify(seedPhrase === expectedSeedPhrase.join(" "), "Seed phrase is not valid")
                isSeedPhraseValidCalled = true
                return true
            }

            itemUnderTest.dictionary.append(expectedSeedPhrase.map((word) => ({seedWord: word})))

            //Type the seed phrase. No space is needed between words
            const str = expectedSeedPhrase.join("")
            for (let i = 0; i < str.length; i++) {
                keyPress(str.charAt(i))
            }

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")

            keyClick(Qt.Key_Enter)
            verify(itemUnderTest.submitSpy.count === 1, "submitSeedPhrase signal was not emitted")
            // This signal is emitted multiple times due to the way the seed phrase is updated and validated
            // The minimum is the length if the seed phrase
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        // Test seed phrase input by typing on the keyboard
        // The seed phrase is valid and the typing is done with a space between words
        // The space between words is ignored and the seed should be valid
        function test_seedPhraseKeyboardInputWithExtraSpace() {
            //generate a seed phrase
            const expectedSeedPhrase = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
            expectedSeedPhrase.sort();
            
            let isSeedPhraseValidCalled = false
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                verify(seedPhrase === expectedSeedPhrase.join(" "), "Seed phrase is not valid")
                isSeedPhraseValidCalled = true
                return true
            }

            itemUnderTest.dictionary.append(expectedSeedPhrase.map((word) => ({seedWord: word})))

            //Type the seed phrase. A space is needed between words
            const str = expectedSeedPhrase.join(" ")
            for (let i = 0; i < str.length; i++) {
                keyPress(str.charAt(i))
            }

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")
            keyClick(Qt.Key_Enter)
            verify(itemUnderTest.submitSpy.count === 1, "submitSeedPhrase signal was not emitted")
            // This signal is emitted multiple times due to the way the seed phrase is updated and validated
            // The minimum is the length if the seed phrase
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        // Test seed phrase input by pasting from clipboard
        // The seed phrase is valid and the clipboard seed is space separated
        function test_seedPhrasePaste() {
            //generate a seed phrase
            const expectedSeedPhrase = ["abandona", "abilityb", "ablec", "aboutd", "abovea", "absentb", "absorbc", "abstractd", "absurda", "abuseb", "accessc", "accidentd"]
            const baseDictionary = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]

            expectedSeedPhrase.sort();
            
            let isSeedPhraseValidCalled = false
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                verify(seedPhrase === expectedSeedPhrase.join(" "), "Seed phrase is not valid")
                isSeedPhraseValidCalled = true
                return true
            }

            itemUnderTest.dictionary.append(expectedSeedPhrase.map((word) => ({seedWord: word})))

            ClipboardUtils.setText(expectedSeedPhrase.join(" "))

            // Trigger the paste action
            keySequence(StandardKey.Paste)

            // verify the last field has focus (https://github.com/status-im/status-desktop/issues/17105; issue 18)
            const lastInputField = findChild(itemUnderTest, "enterSeedPhraseInputField12")
            verify(!!lastInputField)
            tryCompare(lastInputField, "activeFocus", true)

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")

            keyClick(Qt.Key_Enter)
            verify(itemUnderTest.submitSpy.count === 1, "submitSeedPhrase signal was not emitted")
            // This signal is emitted multiple times due to the way the seed phrase is updated and validated
            // The minimum is the length if the seed phrase
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        // Test the seed phrase by choosing from the suggestions
        // The seed phrase is valid and the user selects the words from the suggestions
        function test_seedPhraseChooseFromSuggestions() {
            //generate a seed phrase
            const expectedSeedPhrase = ["abandona", "abilityb", "ablec", "aboutd", "abovea", "absentb", "absorbc", "abstractd", "absurda", "abuseb", "accessc", "accidentd"]
            expectedSeedPhrase.sort()

            const baseDictionary = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
            let dictionaryVariation = generateDictionaryVariation(baseDictionary)

            let isSeedPhraseValidCalled = false
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                verify(seedPhrase === expectedSeedPhrase.join(" "), "Seed phrase is not valid")
                isSeedPhraseValidCalled = true
                return true
            }

            itemUnderTest.dictionary.append(dictionaryVariation.map((word) => ({seedWord: word})))

            // Suggestions dialog is expected to receive key events when there's multiple suggestions
            let downKeyEvents = 0
            for (let i = 0; i < expectedSeedPhrase.length; i++) {
                keySequence(expectedSeedPhrase[i].substring(0, 4).split('').join(','))
                for (let j = 0; j < downKeyEvents; j++) {
                    keyClick(Qt.Key_Down)
                }
                downKeyEvents = downKeyEvents === 3 ? 0 : downKeyEvents + 1
                keyClick(Qt.Key_Tab)
            }

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")

            keyPress(Qt.Key_Enter)
            verify(itemUnderTest.submitSpy.count === 1, "submitSeedPhrase signal was not emitted")
            // This signal is emitted multiple times due to the way the seed phrase is updated and validated
            // The minimum is the length if the seed phrase
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        // Test seed phrase input by typing on the keyboard
        // The seed phrase is invalidated by the external isSeedPhraseValid
        function test_invalidatedSeedPhraseKeyboardInput() {
            //generate a seed phrase
            const expectedSeedPhrase = ["abandona", "abilityb", "ablec", "aboutd", "abovea", "absentb", "absorbc", "abstractd", "absurda", "abuseb", "accessc", "accidentd"]
            expectedSeedPhrase.sort()

            const baseDictionary = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
            let dictionaryVariation = generateDictionaryVariation(baseDictionary)

            let isSeedPhraseValidCalled = false
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                verify(seedPhrase === expectedSeedPhrase.join(" "), "Seed phrase is not valid")
                isSeedPhraseValidCalled = true
                return false
            }

            itemUnderTest.dictionary.append(dictionaryVariation.map((word) => ({seedWord: word})))

            //Type the seed phrase
            const str = expectedSeedPhrase.join("")
            for (let i = 0; i < str.length; i++) {
                keyPress(str.charAt(i))
            }

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")

            keyClick(Qt.Key_Enter)
            verify(itemUnderTest.submitSpy.count === 0, "submitSeedPhrase signal was emitted")
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        // Test seed phrase input by pasting from clipboard
        // The seed phrase is invalidated by the external isSeedPhraseValid
        function test_invalidatedSeedPhrasePaste() {
            //generate a seed phrase
            const expectedSeedPhrase = ["abandona", "abilityb", "ablec", "aboutd", "abovea", "absentb", "absorbc", "abstractd", "absurda", "abuseb", "accessc", "accidentd"]
            expectedSeedPhrase.sort()

            const baseDictionary = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
            let dictionaryVariation = generateDictionaryVariation(baseDictionary)

            let isSeedPhraseValidCalled = false
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                verify(seedPhrase === expectedSeedPhrase.join(" "), "Seed phrase is not valid")
                isSeedPhraseValidCalled = true
                return false
            }

            itemUnderTest.dictionary.append(dictionaryVariation.map((word) => ({seedWord: word})))

            ClipboardUtils.setText(expectedSeedPhrase.join(" "))

            // Trigger the paste action
            keyClick("v", Qt.ControlModifier)

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")

            keyClick(Qt.Key_Enter)
            verify(itemUnderTest.submitSpy.count === 0, "submitSeedPhrase signal was emitted")
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        // Test seed phrase input by typing on the keyboard
        // The seed phrase is invalid due to the length
        function test_invalidLengthSeedPhrase() {
            const expectedSeedPhrase = ["abandona", "abilityb", "ablec"]
            expectedSeedPhrase.sort()

            const baseDictionary = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
            let dictionaryVariation = generateDictionaryVariation(baseDictionary)

            let isSeedPhraseValidCalled = false
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                verify(seedPhrase === expectedSeedPhrase.join(" "), "Seed phrase is not valid")
                isSeedPhraseValidCalled = true
                return true
            }

            itemUnderTest.dictionary.append(dictionaryVariation.map((word) => ({seedWord: word})))

            //Type the seed phrase
            const str = expectedSeedPhrase.join("")
            for (let i = 0; i < str.length; i++) {
                keyPress(str.charAt(i))
            }

            keyClick(Qt.Key_Enter)
            verify(!isSeedPhraseValidCalled, "isSeedPhraseValid was called when it should not have been")
            verify(itemUnderTest.submitSpy.count === 0, "submitSeedPhrase signal was emitted")
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        // Test seed phrase input by typing on the keyboard
        // The seed phrase is invalid due to the dictionary word
        function test_invalidDictionarySeedPhrase() {
            const expectedSeedPhrase = ["abandonna", "abilityb", "ablec", "aboutd", "abovea", "absentb", "absorbc", "abstractd", "absurda", "abuseb", "accessc", "accidentd"]
            //                              ^^ invalid word
            expectedSeedPhrase.sort()

            const baseDictionary = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
            let dictionaryVariation = generateDictionaryVariation(baseDictionary)

            let isSeedPhraseValidCalled = false
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                verify(seedPhrase === expectedSeedPhrase.join(" "), "Seed phrase is not valid")
                isSeedPhraseValidCalled = true
                return true
            }

            itemUnderTest.dictionary.append(dictionaryVariation.map((word) => ({seedWord: word})))

            //Type the seed phrase
            const str = expectedSeedPhrase.join("")
            for (let i = 0; i < str.length; i++) {
                keyPress(str.charAt(i))
                if (i === 8) {
                    // The first word is invalid. Move on to the next word
                    keyPress(Qt.Key_Tab)
                }
            }

            keyClick(Qt.Key_Enter)
            verify(itemUnderTest.submitSpy.count === 0, "submitSeedPhrase signal was emitted")
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        // Test suggestions are active after the seed phrase word is updated
        function test_suggestionsActiveAfterUpdatingWord() {
            const expectedSeedPhrase = ["abandona", "abilityb", "ablec", "aboutd", "abovea", "absentb", "absorbc", "abstractd", "absurda", "abuseb", "accessc", "accidentd"]
            expectedSeedPhrase.sort()

            const baseDictionary = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
            let dictionaryVariation = generateDictionaryVariation(baseDictionary)

            let isSeedPhraseValidCalled = false
            let lastVerifiedSeedPhrase = ""
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                lastVerifiedSeedPhrase = seedPhrase
                isSeedPhraseValidCalled = true
                return true
            }

            itemUnderTest.dictionary.append(dictionaryVariation.map((word) => ({seedWord: word})))

            // Suggestions dialog is expected to receive key events when there's multiple suggestions
            let downKeyEvents = 0
            for (let i = 0; i < expectedSeedPhrase.length; i++) {
                keySequence(expectedSeedPhrase[i].substring(0, 4).split('').join(','))
                for (let j = 0; j < downKeyEvents; j++) {
                    keyClick(Qt.Key_Down)
                }
                downKeyEvents = downKeyEvents === 3 ? 0 : downKeyEvents + 1
                keyClick(Qt.Key_Tab)
            }

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")

            isSeedPhraseValidCalled = false

            keyPress(Qt.Key_Backspace)
            wait (500) // Wait for the suggestions to appear
            keyClick(Qt.Key_Tab)
            keyClick(Qt.Key_Enter)

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")
            verify(lastVerifiedSeedPhrase === expectedSeedPhrase.join(" ").slice(0, -1) + "a", "Seed phrase is not updated")
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
        }

        // Test suggestions are active after the seed phrase word is fixed
        function test_suggestionsActiveAfterFixingWord() {
            const expectedSeedPhrase = ["abandona", "abilityb", "ablec", "aboutd", "abovea", "absentb", "absorbc", "abstractd", "absurda", "abuseb", "accessc", "accidenntd"]
            expectedSeedPhrase.sort()

            const baseDictionary = ["abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract", "absurd", "abuse", "access", "accident"]
            let dictionaryVariation = generateDictionaryVariation(baseDictionary)

            let isSeedPhraseValidCalled = false
            let lastVerifiedSeedPhrase = ""
            itemUnderTest.isSeedPhraseValid = (seedPhrase) => {
                lastVerifiedSeedPhrase = seedPhrase
                isSeedPhraseValidCalled = true
                return true
            }

            itemUnderTest.dictionary.append(dictionaryVariation.map((word) => ({seedWord: word})))

            // Suggestions dialog is expected to receive key events when there's multiple suggestions
            let downKeyEvents = 0
            for (let i = 0; i < expectedSeedPhrase.length; i++) {
                keySequence(expectedSeedPhrase[i].substring(0, 4).split('').join(','))
                for (let j = 0; j < downKeyEvents; j++) {
                    keyClick(Qt.Key_Down)
                }
                downKeyEvents = downKeyEvents === 3 ? 0 : downKeyEvents + 1
                keyClick(Qt.Key_Tab)
            }

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid is not called")

            isSeedPhraseValidCalled = false

            for (let i = 0; i < 2; i++) {
                keyPress(Qt.Key_Backspace)
            }

            wait (500) // Wait for the suggestions to appear
            keyClick(Qt.Key_Tab)
            keyClick(Qt.Key_Enter)

            verify(isSeedPhraseValidCalled, "isSeedPhraseValid was not called")
            verify(lastVerifiedSeedPhrase === expectedSeedPhrase.join(" ").slice(0, -3) + "ta", "Seed phrase is not updated")
            verify(itemUnderTest.seedPhraseUpdatedSpy.count >= expectedSeedPhrase.length, "seedPhraseUpdate signal was not emitted")
            verify(itemUnderTest.submitSpy.count === 1, "submitSeedPhrase signal was emitted")
        }
    }
}
