import QtQuick 2.15
import QtTest 1.15

import StatusQ 0.1 // ClipboardUtils

import AppLayouts.Onboarding2 1.0
import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding2.stores 1.0
import AppLayouts.Onboarding.enums 1.0

import shared.stores 1.0 as SharedStores

import utils 1.0

Item {
    id: root

    width: 1200
    height: 700

    QtObject {
        id: mockDriver
        property int keycardState // enum Onboarding.KeycardState
        property bool biometricsAvailable
        property string existingPin

        readonly property string mnemonic: "dog dog dog dog dog dog dog dog dog dog dog dog"
        readonly property var seedWords: ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"]
        readonly property string dummyNewPassword: "0123456789"
    }

    Component {
        id: componentUnderTest

        OnboardingLayout {
            anchors.fill: parent
            networkChecksEnabled: false
            onboardingStore: OnboardingStore {
                readonly property int keycardState: mockDriver.keycardState // enum Onboarding.KeycardState
                property int keycardRemainingPinAttempts: 5

                function setPin(pin: string) {
                    const valid = pin === mockDriver.existingPin
                    if (!valid)
                        keycardRemainingPinAttempts--
                    return valid
                }

                readonly property int addKeyPairState: Onboarding.AddKeyPairState.InProgress // enum Onboarding.AddKeyPairState
                function startKeypairTransfer() {}

                // password
                function getPasswordStrengthScore(password: string) {
                    return Math.min(password.length-1, 4)
                }

                // seedphrase/mnemonic
                function validMnemonic(mnemonic: string) {
                    return mnemonic === mockDriver.mnemonic
                }
                function getMnemonic() {
                    return mockDriver.seedWords.join(" ")
                }
                function mnemonicWasShown() {}
                function removeMnemonic() {}

                readonly property int syncState: Onboarding.SyncState.InProgress // enum Onboarding.SyncState
                function validateLocalPairingConnectionString(connectionString: string) {
                    return !Number.isNaN(parseInt(connectionString))
                }
                function inputConnectionStringForBootstrapping(connectionString: string) {}
            }
            metricsStore: SharedStores.MetricsStore {
                readonly property var d: QtObject {
                    id: d
                    property bool isCentralizedMetricsEnabled
                }

                function toggleCentralizedMetrics(enabled) {
                    d.isCentralizedMetricsEnabled = enabled
                }

                function addCentralizedMetricIfEnabled(eventName, eventValue = null) {}

                readonly property bool isCentralizedMetricsEnabled : d.isCentralizedMetricsEnabled
            }

            splashScreenDurationMs: 3000
            biometricsAvailable: mockDriver.biometricsAvailable

            QtObject {
                id: localAppSettings
                property bool metricsPopupSeen
            }
        }
    }

    SignalSpy {
        id: dynamicSpy

        function setup(t, s) {
            clear()
            target = t
            signalName = s
        }

        function cleanup() {
            target = null
            signalName = ""
            clear()
        }
    }

    SignalSpy {
        id: finishedSpy
        target: controlUnderTest
        signalName: "finished"
    }

    property OnboardingLayout controlUnderTest: null

    TestCase {
        name: "OnboardingLayout"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)

            // disable animated transitions to speed-up tests
            const stack = findChild(controlUnderTest, "stack")
            stack.pushEnter = null
            stack.pushExit = null
            stack.popEnter = null
            stack.popExit = null
            stack.replaceEnter = null
            stack.replaceExit = null
        }

        function cleanup() {
            mockDriver.keycardState = -1
            mockDriver.biometricsAvailable = false
            mockDriver.existingPin = ""
            dynamicSpy.cleanup()
            finishedSpy.clear()
        }

        function keyClickSequence(keys) {
            for (let k of keys) {
                keyClick(k)
            }
        }

        function getCurrentPage(stack, pageClassName) {
            if (!stack || !pageClassName)
                fail("getCurrentPage: expected param 'stack' or 'pageClassName' empty")
            verify(!!stack)
            tryCompare(stack, "busy", false) // wait for page transitions to stop
            tryCompare(stack.currentItem, "pageClassName", pageClassName)
            return stack.currentItem
        }

        // common variant data for all flow related TDD tests
        function init_data() {
            return [ { tag: "shareUsageData+bioEnabled", shareBtnName: "btnShare", shareResult: true, biometrics: true, bioEnabled: true },
                    { tag: "dontShareUsageData+bioEnabled", shareBtnName: "btnDontShare", shareResult: false, biometrics: true, bioEnabled: true },

                    { tag: "shareUsageData+bioDisabled", shareBtnName: "btnShare", shareResult: true, biometrics: true, bioEnabled: false },
                    { tag: "dontShareUsageData+bioDisabled", shareBtnName: "btnDontShare", shareResult: false, biometrics: true, bioEnabled: false },

                    { tag: "shareUsageData-bio", shareBtnName: "btnShare", shareResult: true, biometrics: false },
                    { tag: "dontShareUsageData-bio", shareBtnName: "btnDontShare", shareResult: false, biometrics: false },
                    ]
        }

        function test_basicGeometry() {
            verify(!!controlUnderTest)
            verify(controlUnderTest.width > 0)
            verify(controlUnderTest.height > 0)
        }

        // FLOW: Create Profile -> Start fresh (create profile with new password)
        function test_flow_createProfile_withPassword(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, "WelcomePage")

            const linksText = findChild(controlUnderTest, "approvalLinks")
            verify(!!linksText)

            dynamicSpy.setup(page, "termsOfUseRequested")
            mouseClick(linksText, linksText.width/2 - 20, linksText.height - 8)
            tryCompare(dynamicSpy, "count", 1)
            keyClick(Qt.Key_Escape) // close the popup

            dynamicSpy.setup(page, "privacyPolicyRequested")
            mouseClick(linksText, linksText.width/2 + 20, linksText.height - 8)
            tryCompare(dynamicSpy, "count", 1)
            keyClick(Qt.Key_Escape) // close the popup

            const btnCreateProfile = findChild(controlUnderTest, "btnCreateProfile")
            verify(!!btnCreateProfile)
            mouseClick(btnCreateProfile)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, "HelpUsImproveStatusPage")

            let infoButton = findChild(controlUnderTest, "infoButton")
            verify(!!infoButton)
            mouseClick(infoButton)
            const helpUsImproveDetailsPopup = findChild(controlUnderTest, "helpUsImproveDetailsPopup")
            verify(!!helpUsImproveDetailsPopup)
            compare(helpUsImproveDetailsPopup.opened, true)
            keyClick(Qt.Key_Escape) // close the popup

            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Create profile
            page = getCurrentPage(stack, "CreateProfilePage")

            const btnCreateWithPassword = findChild(controlUnderTest, "btnCreateWithPassword")
            verify(!!btnCreateWithPassword)
            mouseClick(btnCreateWithPassword)

            // PAGE 4: Create password
            page = getCurrentPage(stack, "CreatePasswordPage")

            infoButton = findChild(controlUnderTest, "infoButton")
            verify(!!infoButton)
            mouseClick(infoButton)
            const passwordDetailsPopup = findChild(controlUnderTest, "passwordDetailsPopup")
            verify(!!passwordDetailsPopup)
            compare(passwordDetailsPopup.opened, true)
            keyClick(Qt.Key_Escape) // close the popup

            const btnConfirmPassword = findChild(controlUnderTest, "btnConfirmPassword")
            verify(!!btnConfirmPassword)
            compare(btnConfirmPassword.enabled, false)

            const passwordViewNewPassword = findChild(controlUnderTest, "passwordViewNewPassword")
            verify(!!passwordViewNewPassword)
            mouseClick(passwordViewNewPassword)
            compare(passwordViewNewPassword.activeFocus, true)
            compare(passwordViewNewPassword.text, "")

            keyClickSequence(mockDriver.dummyNewPassword)
            compare(passwordViewNewPassword.text, mockDriver.dummyNewPassword)
            compare(btnConfirmPassword.enabled, false)

            const passwordViewNewPasswordConfirm = findChild(controlUnderTest, "passwordViewNewPasswordConfirm")
            verify(!!passwordViewNewPasswordConfirm)
            mouseClick(passwordViewNewPasswordConfirm)
            compare(passwordViewNewPasswordConfirm.activeFocus, true)
            compare(passwordViewNewPasswordConfirm.text, "")

            keyClickSequence(mockDriver.dummyNewPassword)
            compare(passwordViewNewPassword.text, mockDriver.dummyNewPassword)
            compare(btnConfirmPassword.enabled, true)

            mouseClick(btnConfirmPassword)

            // PAGE 5: Enable Biometrics
            if (data.biometrics) {
                page = getCurrentPage(stack, "EnableBiometricsPage")

                const enableBioButton = findChild(controlUnderTest, data.bioEnabled ? "btnEnableBiometrics" : "btnDontEnableBiometrics")
                dynamicSpy.setup(page, "enableBiometricsRequested")
                mouseClick(enableBioButton)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], data.bioEnabled)
            }

            // FINISH
            tryCompare(finishedSpy, "count", 1)
            compare(finishedSpy.signalArguments[0][0], Onboarding.SecondaryFlow.CreateProfileWithPassword)
            const resultData = finishedSpy.signalArguments[0][1]
            verify(!!resultData)
            compare(resultData.password, mockDriver.dummyNewPassword)
            compare(resultData.enableBiometrics, data.biometrics && data.bioEnabled)
            compare(resultData.keycardPin, "")
            compare(resultData.seedphrase, "")
        }

        // FLOW: Create Profile -> Use a recovery phrase (create profile with seedphrase)
        function test_flow_createProfile_withSeedphrase(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, "WelcomePage")

            const btnCreateProfile = findChild(controlUnderTest, "btnCreateProfile")
            verify(!!btnCreateProfile)
            mouseClick(btnCreateProfile)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, "HelpUsImproveStatusPage")

            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Create profile
            page = getCurrentPage(stack, "CreateProfilePage")

            const btnCreateWithSeedPhrase = findChild(controlUnderTest, "btnCreateWithSeedPhrase")
            verify(!!btnCreateWithSeedPhrase)
            mouseClick(btnCreateWithSeedPhrase)

            // PAGE 4: Create profile using a recovery phrase
            page = getCurrentPage(stack, "SeedphrasePage")

            const btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, false)

            const firstInput = findChild(page, "enterSeedPhraseInputField1")
            verify(!!firstInput)
            tryCompare(firstInput, "activeFocus", true)
            ClipboardUtils.setText(mockDriver.mnemonic)
            keySequence(StandardKey.Paste)
            compare(btnContinue.enabled, true)
            mouseClick(btnContinue)

            // PAGE 5: Create password
            page = getCurrentPage(stack, "CreatePasswordPage")

            const btnConfirmPassword = findChild(controlUnderTest, "btnConfirmPassword")
            verify(!!btnConfirmPassword)
            compare(btnConfirmPassword.enabled, false)

            const passwordViewNewPassword = findChild(controlUnderTest, "passwordViewNewPassword")
            verify(!!passwordViewNewPassword)
            mouseClick(passwordViewNewPassword)
            compare(passwordViewNewPassword.activeFocus, true)
            compare(passwordViewNewPassword.text, "")

            keyClickSequence(mockDriver.dummyNewPassword)
            compare(passwordViewNewPassword.text, mockDriver.dummyNewPassword)
            compare(btnConfirmPassword.enabled, false)

            const passwordViewNewPasswordConfirm = findChild(controlUnderTest, "passwordViewNewPasswordConfirm")
            verify(!!passwordViewNewPasswordConfirm)
            mouseClick(passwordViewNewPasswordConfirm)
            compare(passwordViewNewPasswordConfirm.activeFocus, true)
            compare(passwordViewNewPasswordConfirm.text, "")

            keyClickSequence(mockDriver.dummyNewPassword)
            compare(passwordViewNewPassword.text, mockDriver.dummyNewPassword)
            compare(btnConfirmPassword.enabled, true)

            mouseClick(btnConfirmPassword)

            // PAGE 6: Enable Biometrics
            if (data.biometrics) {
                page = getCurrentPage(stack, "EnableBiometricsPage")

                const enableBioButton = findChild(controlUnderTest, data.bioEnabled ? "btnEnableBiometrics" : "btnDontEnableBiometrics")
                dynamicSpy.setup(page, "enableBiometricsRequested")
                mouseClick(enableBioButton)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], data.bioEnabled)
            }

            // FINISH
            tryCompare(finishedSpy, "count", 1)
            compare(finishedSpy.signalArguments[0][0], Onboarding.SecondaryFlow.CreateProfileWithSeedphrase)
            const resultData = finishedSpy.signalArguments[0][1]
            verify(!!resultData)
            compare(resultData.password, mockDriver.dummyNewPassword)
            compare(resultData.enableBiometrics, data.biometrics && data.bioEnabled)
            compare(resultData.keycardPin, "")
            compare(resultData.seedphrase, mockDriver.mnemonic)
        }

        function test_flow_createProfile_withKeycardAndNewSeedphrase_data() {
            const commonData = init_data()
            const flowData = []
            for (let dataRow of commonData) {
                let newRowEmptyPin = Object.create(dataRow)
                Object.assign(newRowEmptyPin, { tag: dataRow.tag + "+emptyPin", pin: "" })
                flowData.push(newRowEmptyPin)
            }

            return flowData
        }

        // FLOW: Create Profile -> Use an empty Keycard -> Use a new recovery phrase (create profile with keycard + new seedphrase)
        function test_flow_createProfile_withKeycardAndNewSeedphrase(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics
            mockDriver.existingPin = data.pin

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, "WelcomePage")
            const btnCreateProfile = findChild(controlUnderTest, "btnCreateProfile")
            verify(!!btnCreateProfile)
            mouseClick(btnCreateProfile)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, "HelpUsImproveStatusPage")
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Create profile
            page = getCurrentPage(stack, "CreateProfilePage")
            const btnCreateWithEmptyKeycard = findChild(controlUnderTest, "btnCreateWithEmptyKeycard")
            verify(!!btnCreateWithEmptyKeycard)
            mouseClick(btnCreateWithEmptyKeycard)

            // PAGE 4: Keycard intro
            page = getCurrentPage(stack, "KeycardIntroPage")
            dynamicSpy.setup(page, "emptyKeycardDetected")
            mockDriver.keycardState = Onboarding.KeycardState.Empty // SIMULATION // TODO test other states here as well
            tryCompare(dynamicSpy, "count", 1)
            tryCompare(page, "state", "empty")

            // PAGE 5: Create profile on empty Keycard -> Use a new recovery phrase
            page = getCurrentPage(stack, "CreateKeycardProfilePage")
            const btnCreateWithEmptySeedphrase = findChild(page, "btnCreateWithEmptySeedphrase")
            verify(!!btnCreateWithEmptySeedphrase)
            mouseClick(btnCreateWithEmptySeedphrase)

            // PAGE 6: Backup your recovery phrase (intro)
            page = getCurrentPage(stack, "BackupSeedphraseIntro")
            const btnBackupSeedphrase = findChild(page, "btnBackupSeedphrase")
            verify(!!btnBackupSeedphrase)
            mouseClick(btnBackupSeedphrase)

            // PAGE 7: Backup your recovery phrase (ack checkboxes)
            page = getCurrentPage(stack, "BackupSeedphraseAcks")
            let btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, false)
            for (let ack of ["ack1", "ack2", "ack3", "ack4"]) {
                const cb = findChild(page, ack)
                verify(!!cb)
                mouseClick(cb)
            }
            tryCompare(btnContinue, "enabled", true)
            mouseClick(btnContinue)

            // PAGE 8: Backup your recovery phrase (seedphrase reveal) - step 1
            page = getCurrentPage(stack, "BackupSeedphraseReveal")
            const seedGrid = findChild(page, "seedGrid")
            verify(!!seedGrid)
            tryCompare(seedGrid.layer, "enabled", true)
            const btnConfirm = findChild(page, "btnConfirm")
            verify(!!btnConfirm)
            compare(btnConfirm.enabled, false)
            const btnReveal = findChild(page, "btnReveal")
            verify(!!btnReveal)
            mouseClick(btnReveal)
            tryCompare(seedGrid.layer, "enabled", false)
            compare(btnConfirm.enabled, true)
            mouseClick(btnConfirm)

            // PAGE 9: Backup your recovery phrase (seedphrase verification) - step 2
            page = getCurrentPage(stack, "BackupSeedphraseVerify")
            btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, false)
            const seedWords = page.seedWordsToVerify.map((entry) => entry.seedWord)
            for (let i = 0; i < 4; i++) {
                const seedInput = findChild(page, "seedInput_%1".arg(i))
                verify(!!seedInput)
                mouseClick(seedInput)
                keyClickSequence(seedWords[i])
                keyClick(Qt.Key_Tab)
            }
            compare(btnContinue.enabled, true)
            mouseClick(btnContinue)

            // PAGE 10: Backup your recovery phrase (outro) - step 3
            page = getCurrentPage(stack, "BackupSeedphraseOutro")
            btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, false)
            const cbAck = findChild(page, "cbAck")
            verify(!!cbAck)
            compare(cbAck.checked, false)
            mouseClick(cbAck)
            compare(cbAck.checked, true)
            compare(btnContinue.enabled, true)
            mouseClick(btnContinue)

            // PAGE 11a: Enter Keycard PIN
            if (!!data.pin) {
                page = getCurrentPage(stack, "KeycardEnterPinPage")
                dynamicSpy.setup(page, "keycardPinEntered")
                keyClickSequence(data.pin)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], data.pin)
            }
            // PAGE 11b: Create new Keycard PIN
            else {
                const newPin = "123321"
                page = getCurrentPage(stack, "KeycardCreatePinPage")
                tryCompare(page, "state", "creating")
                dynamicSpy.setup(page, "keycardPinCreated")
                keyClickSequence(newPin)
                tryCompare(page, "state", "repeating")
                keyClickSequence(newPin)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], newPin)
            }

            // PAGE 12: Adding key pair to Keycard
            page = getCurrentPage(stack, "KeycardAddKeyPairPage")
            tryCompare(page, "addKeyPairState", Onboarding.AddKeyPairState.InProgress)
            page.addKeyPairState = Onboarding.AddKeyPairState.Success // SIMULATION
            btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, true)
            mouseClick(btnContinue)

            // PAGE 13: Enable Biometrics
            if (data.biometrics) {
                page = getCurrentPage(stack, "EnableBiometricsPage")

                const enableBioButton = findChild(controlUnderTest, data.bioEnabled ? "btnEnableBiometrics" : "btnDontEnableBiometrics")
                dynamicSpy.setup(page, "enableBiometricsRequested")
                mouseClick(enableBioButton)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], data.bioEnabled)
            }

            // FINISH
            tryCompare(finishedSpy, "count", 1)
            compare(finishedSpy.signalArguments[0][0], Onboarding.SecondaryFlow.CreateProfileWithKeycardNewSeedphrase)
            const resultData = finishedSpy.signalArguments[0][1]
            verify(!!resultData)
            compare(resultData.password, "")
            compare(resultData.enableBiometrics, data.biometrics && data.bioEnabled)
            compare(resultData.keycardPin, !!data.pin ? data.pin : "123321")
            compare(resultData.seedphrase, "") // TODO check seed here as well?
        }

        function test_flow_createProfile_withKeycardAndExistingSeedphrase_data() {
            return test_flow_createProfile_withKeycardAndNewSeedphrase_data()
        }

        // FLOW: Create Profile -> Use an empty Keycard -> Use an existing recovery phrase (create profile with keycard + existing seedphrase)
        function test_flow_createProfile_withKeycardAndExistingSeedphrase(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics
            mockDriver.existingPin = data.pin

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, "WelcomePage")
            const btnCreateProfile = findChild(controlUnderTest, "btnCreateProfile")
            verify(!!btnCreateProfile)
            mouseClick(btnCreateProfile)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, "HelpUsImproveStatusPage")
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Create profile
            page = getCurrentPage(stack, "CreateProfilePage")
            const btnCreateWithEmptyKeycard = findChild(controlUnderTest, "btnCreateWithEmptyKeycard")
            verify(!!btnCreateWithEmptyKeycard)
            mouseClick(btnCreateWithEmptyKeycard)

            // PAGE 4: Keycard intro
            page = getCurrentPage(stack, "KeycardIntroPage")
            dynamicSpy.setup(page, "emptyKeycardDetected")
            mockDriver.keycardState = Onboarding.KeycardState.Empty // SIMULATION // TODO test other states here as well
            tryCompare(dynamicSpy, "count", 1)
            tryCompare(page, "state", "empty")

            // PAGE 5: Create profile on empty Keycard -> Use an existing recovery phrase
            page = getCurrentPage(stack, "CreateKeycardProfilePage")
            const btnCreateWithExistingSeedphrase = findChild(page, "btnCreateWithExistingSeedphrase")
            verify(!!btnCreateWithExistingSeedphrase)
            mouseClick(btnCreateWithExistingSeedphrase)

            // PAGE 6: Create profile on empty Keycard using a recovery phrase
            page = getCurrentPage(stack, "SeedphrasePage")
            const btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, false)
            const firstInput = findChild(page, "enterSeedPhraseInputField1")
            verify(!!firstInput)
            tryCompare(firstInput, "activeFocus", true)
            ClipboardUtils.setText(mockDriver.mnemonic)
            keySequence(StandardKey.Paste)
            compare(btnContinue.enabled, true)
            mouseClick(btnContinue)

            // PAGE 7a: Enter Keycard PIN
            if (!!data.pin) {
                page = getCurrentPage(stack, "KeycardEnterPinPage")
                dynamicSpy.setup(page, "keycardPinEntered")
                keyClickSequence(data.pin)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], data.pin)
            }
            // PAGE 7b: Create new Keycard PIN
            else {
                const newPin = "123321"
                page = getCurrentPage(stack, "KeycardCreatePinPage")
                tryCompare(page, "state", "creating")
                dynamicSpy.setup(page, "keycardPinCreated")
                keyClickSequence(newPin)
                tryCompare(page, "state", "repeating")
                keyClickSequence(newPin)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], newPin)
            }

            // PAGE 8: Adding key pair to Keycard
            page = getCurrentPage(stack, "KeycardAddKeyPairPage")
            tryCompare(page, "addKeyPairState", Onboarding.AddKeyPairState.InProgress)
            page.addKeyPairState = Onboarding.AddKeyPairState.Success // SIMULATION
            const btnContinue2 = findChild(page, "btnContinue")
            verify(!!btnContinue2)
            compare(btnContinue2.enabled, true)
            mouseClick(btnContinue2)

            // PAGE 9: Enable Biometrics
            if (controlUnderTest.biometricsAvailable) {
                page = getCurrentPage(stack, "EnableBiometricsPage")

                const enableBioButton = findChild(controlUnderTest, data.bioEnabled ? "btnEnableBiometrics" : "btnDontEnableBiometrics")
                dynamicSpy.setup(page, "enableBiometricsRequested")
                mouseClick(enableBioButton)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], data.bioEnabled)
            }

            // FINISH
            tryCompare(finishedSpy, "count", 1)
            compare(finishedSpy.signalArguments[0][0], Onboarding.SecondaryFlow.CreateProfileWithKeycardExistingSeedphrase)
            const resultData = finishedSpy.signalArguments[0][1]
            verify(!!resultData)
            compare(resultData.password, "")
            compare(resultData.enableBiometrics, data.biometrics && data.bioEnabled)
            compare(resultData.keycardPin, !!data.pin ? data.pin : "123321")
            compare(resultData.seedphrase, mockDriver.mnemonic)
        }

        // FLOW: Log in -> Log in with recovery phrase
        function test_flow_login_withSeedphrase(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, "WelcomePage")
            const btnLogin = findChild(controlUnderTest, "btnLogin")
            verify(!!btnLogin)
            mouseClick(btnLogin)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, "HelpUsImproveStatusPage")
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Log in -> Enter recovery phrase
            page = getCurrentPage(stack, "LoginPage")
            const btnWithSeedphrase = findChild(page, "btnWithSeedphrase")
            verify(!!btnWithSeedphrase)
            mouseClick(btnWithSeedphrase)

            // PAGE 4: Sign in with your Status recovery phrase
            page = getCurrentPage(stack, "SeedphrasePage")

            const btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, false)

            const firstInput = findChild(page, "enterSeedPhraseInputField1")
            verify(!!firstInput)
            tryCompare(firstInput, "activeFocus", true)
            ClipboardUtils.setText(mockDriver.mnemonic)
            keySequence(StandardKey.Paste)
            compare(btnContinue.enabled, true)
            mouseClick(btnContinue)

            // PAGE 5: Create password
            page = getCurrentPage(stack, "CreatePasswordPage")

            const btnConfirmPassword = findChild(controlUnderTest, "btnConfirmPassword")
            verify(!!btnConfirmPassword)
            compare(btnConfirmPassword.enabled, false)

            const passwordViewNewPassword = findChild(controlUnderTest, "passwordViewNewPassword")
            verify(!!passwordViewNewPassword)
            mouseClick(passwordViewNewPassword)
            compare(passwordViewNewPassword.activeFocus, true)
            compare(passwordViewNewPassword.text, "")

            keyClickSequence(mockDriver.dummyNewPassword)
            compare(passwordViewNewPassword.text, mockDriver.dummyNewPassword)
            compare(btnConfirmPassword.enabled, false)

            const passwordViewNewPasswordConfirm = findChild(controlUnderTest, "passwordViewNewPasswordConfirm")
            verify(!!passwordViewNewPasswordConfirm)
            mouseClick(passwordViewNewPasswordConfirm)
            compare(passwordViewNewPasswordConfirm.activeFocus, true)
            compare(passwordViewNewPasswordConfirm.text, "")

            keyClickSequence(mockDriver.dummyNewPassword)
            compare(passwordViewNewPassword.text, mockDriver.dummyNewPassword)
            compare(btnConfirmPassword.enabled, true)

            mouseClick(btnConfirmPassword)

            // PAGE 6: Enable Biometrics
            if (data.biometrics) {
                page = getCurrentPage(stack, "EnableBiometricsPage")

                const enableBioButton = findChild(controlUnderTest, data.bioEnabled ? "btnEnableBiometrics" : "btnDontEnableBiometrics")
                dynamicSpy.setup(page, "enableBiometricsRequested")
                mouseClick(enableBioButton)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], data.bioEnabled)
            }

            tryCompare(finishedSpy, "count", 1)
            compare(finishedSpy.signalArguments[0][0], Onboarding.SecondaryFlow.LoginWithSeedphrase)
            const resultData = finishedSpy.signalArguments[0][1]
            verify(!!resultData)
            compare(resultData.password, mockDriver.dummyNewPassword)
            compare(resultData.enableBiometrics, data.biometrics && data.bioEnabled)
            compare(resultData.keycardPin, "")
            compare(resultData.seedphrase, mockDriver.mnemonic)
        }

        // FLOW: Log in -> Log in by syncing
        function test_flow_login_bySyncing(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, "WelcomePage")
            const btnLogin = findChild(controlUnderTest, "btnLogin")
            verify(!!btnLogin)
            mouseClick(btnLogin)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, "HelpUsImproveStatusPage")
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Log in
            page = getCurrentPage(stack, "LoginPage")
            const btnBySyncing = findChild(page, "btnBySyncing")
            verify(!!btnBySyncing)
            mouseClick(btnBySyncing)

            const loginWithSyncAckPopup = findChild(page, "loginWithSyncAckPopup")
            verify(!!loginWithSyncAckPopup)

            let btnContinue = findChild(loginWithSyncAckPopup, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, false)
            for (let ack of ["ack1", "ack2", "ack3"]) {
                const cb = findChild(loginWithSyncAckPopup, ack)
                verify(!!cb)
                mouseClick(cb)
            }
            tryCompare(btnContinue, "enabled", true)
            mouseClick(btnContinue)

            // PAGE 4: Log in by syncing
            page = getCurrentPage(stack, "LoginBySyncingPage")

            const enterCodeTabBtn = findChild(page, "secondTab_StatusSwitchTabButton")
            verify(!!enterCodeTabBtn)
            mouseClick(enterCodeTabBtn)

            btnContinue = findChild(page, "continue_StatusButton")
            verify(!!btnContinue)
            tryCompare(btnContinue, "enabled", false)

            const syncCodeInput = findChild(page, "syncCodeInput")
            verify(!!syncCodeInput)
            mouseClick(syncCodeInput)
            compare(syncCodeInput.input.edit.activeFocus, true)
            keyClickSequence("1234")
            tryCompare(btnContinue, "enabled", true)
            mouseClick(btnContinue)

            // PAGE 5: Profile sync in progress
            page = getCurrentPage(stack, "SyncProgressPage")
            tryCompare(page, "syncState", Onboarding.SyncState.InProgress)
            page.syncState = Onboarding.SyncState.Success // SIMULATION
            const btnLogin2 = findChild(page, "btnLogin") // TODO test other flows/buttons here as well
            verify(!!btnLogin2)
            compare(btnLogin2.enabled, true)
            mouseClick(btnLogin2)

            // PAGE 6: Enable Biometrics
            if (data.biometrics) {
                page = getCurrentPage(stack, "EnableBiometricsPage")

                const enableBioButton = findChild(controlUnderTest, data.bioEnabled ? "btnEnableBiometrics" : "btnDontEnableBiometrics")
                dynamicSpy.setup(page, "enableBiometricsRequested")
                mouseClick(enableBioButton)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], data.bioEnabled)
            }

            // FINISH
            tryCompare(finishedSpy, "count", 1)
            compare(finishedSpy.signalArguments[0][0], Onboarding.SecondaryFlow.LoginWithSyncing)
            const resultData = finishedSpy.signalArguments[0][1]
            verify(!!resultData)
            compare(resultData.password, "")
            compare(resultData.enableBiometrics, data.biometrics && data.bioEnabled)
            compare(resultData.keycardPin, "")
            compare(resultData.seedphrase, "")
        }

        // FLOW: Log in -> Log in with Keycard
        function test_flow_login_withKeycard(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics
            mockDriver.existingPin = "123456"

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, "WelcomePage")
            const btnLogin = findChild(controlUnderTest, "btnLogin")
            verify(!!btnLogin)
            mouseClick(btnLogin)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, "HelpUsImproveStatusPage")
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Log in -> Login with Keycard
            page = getCurrentPage(stack, "LoginPage")
            const btnWithKeycard = findChild(page, "btnWithKeycard")
            verify(!!btnWithKeycard)
            mouseClick(btnWithKeycard)

            // PAGE 4: Keycard intro
            page = getCurrentPage(stack, "KeycardIntroPage")
            dynamicSpy.setup(page, "notEmptyKeycardDetected")
            mockDriver.keycardState = Onboarding.KeycardState.NotEmpty // SIMULATION // TODO test other states here as well
            tryCompare(dynamicSpy, "count", 1)
            tryCompare(page, "state", "notEmpty")

            // PAGE 5: Enter Keycard PIN
            page = getCurrentPage(stack, "KeycardEnterPinPage")
            dynamicSpy.setup(page, "keycardPinEntered")
            keyClickSequence(mockDriver.existingPin)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], mockDriver.existingPin)

            // PAGE 6: Enable Biometrics
            if (data.biometrics) {
                page = getCurrentPage(stack, "EnableBiometricsPage")

                const enableBioButton = findChild(controlUnderTest, data.bioEnabled ? "btnEnableBiometrics" : "btnDontEnableBiometrics")
                dynamicSpy.setup(page, "enableBiometricsRequested")
                mouseClick(enableBioButton)
                tryCompare(dynamicSpy, "count", 1)
                compare(dynamicSpy.signalArguments[0][0], data.bioEnabled)
            }

            // FINISH
            tryCompare(finishedSpy, "count", 1)
            compare(finishedSpy.signalArguments[0][0], Onboarding.SecondaryFlow.LoginWithKeycard)
            const resultData = finishedSpy.signalArguments[0][1]
            verify(!!resultData)
            compare(resultData.password, "")
            compare(resultData.enableBiometrics, data.biometrics && data.bioEnabled)
            compare(resultData.keycardPin, mockDriver.existingPin)
            compare(resultData.seedphrase, "")
        }
    }
}
