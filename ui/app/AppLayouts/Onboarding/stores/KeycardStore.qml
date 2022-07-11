import QtQuick 2.13

QtObject {
    id: root

    property var keycardModule

    signal getOutOfTheKeycardFlow() // We will use this signal until we combine all flows.

    function runLoadAccountFlow() {
        root.keycardModule.runLoadAccountFlow()
    }

    function runLoginFlow() {
        root.keycardModule.runLoginFlow()
    }

    function cancelFlow() {
        root.keycardModule.cancelFlow()
    }

    function checkSeedPhrase(seedPhraseLength, seedPhrase) {
        return root.keycardModule.checkSeedPhrase(seedPhraseLength, seedPhrase)
    }

    function checkKeycardPin(pin) {
        return root.keycardModule.checkKeycardPin(pin)
    }

    function checkRepeatedKeycardPinCurrent(pin) {
        return root.keycardModule.checkRepeatedKeycardPinCurrent(pin)
    }

    function checkRepeatedKeycardPin(pin) {
        return root.keycardModule.checkRepeatedKeycardPin(pin)
    }

    function shouldExitKeycardFlow() {
        return root.keycardModule.shouldExitKeycardFlow()
    }

    function backClicked() {
        root.keycardModule.backClicked()
    }

    function getSeedPhrase() {
        return root.keycardModule.getSeedPhrase()
    }

    function nextState() {
        return root.keycardModule.nextState()
    }

    function factoryReset() {
        return root.keycardModule.factoryReset()
    }

    function switchCard() {
        return root.keycardModule.switchCard()
    }
}
