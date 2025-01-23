import QtQuick 2.15
import QtTest 1.15

import StatusQ 0.1 // ClipboardUtils
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2 1.0
import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding2.stores 1.0
import AppLayouts.Onboarding.enums 1.0

import shared.stores 1.0 as SharedStores

import utils 1.0

import Models 1.0

Item {
    id: root

    width: 1200
    height: 700

    QtObject {
        id: mockDriver
        property int keycardState // enum Onboarding.KeycardState
        property int pinSettingState // enum Onboarding.ProgressState
        property int authorizationState // enum Onboarding.ProgressState
        property int restoreKeysExportState // enum Onboarding.ProgressState
        property bool biometricsAvailable
        property string existingPin

        readonly property string mnemonic: "dog dog dog dog dog dog dog dog dog dog dog dog"
        readonly property var seedWords: ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"]
        readonly property string dummyNewPassword: "0123456789"
    }

    LoginAccountsModel {
        id: loginAccountsModel
    }

    ListModel {
        id: emptyModel
    }

    Component {
        id: componentUnderTest

        OnboardingLayout {
            anchors.fill: parent

            networkChecksEnabled: false
            biometricsAvailable: mockDriver.biometricsAvailable
            keycardPinInfoPageDelay: 0

            loginAccountsModel: emptyModel
            isBiometricsLogin: biometricsAvailable

            onboardingStore: OnboardingStore {
                readonly property int keycardState: mockDriver.keycardState // enum Onboarding.KeycardState
                readonly property int pinSettingState: mockDriver.pinSettingState // enum Onboarding.ProgressState
                readonly property int authorizationState: mockDriver.authorizationState // enum Onboarding.ProgressState
                readonly property int restoreKeysExportState: mockDriver.restoreKeysExportState // enum Onboarding.ProgressState
                property int keycardRemainingPinAttempts: 5

                function setPin(pin: string) {
                    const valid = pin === mockDriver.existingPin
                    if (!valid)
                        keycardRemainingPinAttempts--
                    return valid
                }

                function authorize(pin: string) {}

                readonly property int addKeyPairState: Onboarding.ProgressState.InProgress // enum Onboarding.ProgressState

                // password
                function getPasswordStrengthScore(password: string) {
                    return Math.min(password.length-1, 4)
                }

                function finishOnboardingFlow(flow: int, data: Object) { // -> bool
                    return true
                }

                // seedphrase/mnemonic
                function validMnemonic(mnemonic: string) {
                    return mnemonic === mockDriver.mnemonic
                }
                function getMnemonic() {
                    return JSON.stringify(mockDriver.seedWords)
                }
                function loadMnemonic(mnemonic) {}
                function exportRecoverKeys() {}

                readonly property int syncState: Onboarding.ProgressState.InProgress // enum Onboarding.ProgressState
                function validateLocalPairingConnectionString(connectionString: string) {
                    return !Number.isNaN(parseInt(connectionString))
                }
                function inputConnectionStringForBootstrapping(connectionString: string) {}

                // password signals
                signal accountLoginError(string error, bool wrongPassword)

                // biometrics signals
                signal obtainingPasswordSuccess(string password)
                signal obtainingPasswordError(string errorDescription, string errorType /* Constants.keychain.errorType.* */, bool wrongFingerprint)
            }
            onLoginRequested: (keyUid, method, data) => {
                // SIMULATION: emit an error in case of wrong password
                if (method === Onboarding.LoginMethod.Password && data.password !== mockDriver.dummyNewPassword) {
                    onboardingStore.accountLoginError("An error ocurred, wrong password?", Math.random() < 0.5)
                }
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

    SignalSpy {
        id: loginSpy
        target: controlUnderTest
        signalName: "loginRequested"
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
            mockDriver.pinSettingState = 0
            mockDriver.authorizationState = 0
            mockDriver.restoreKeysExportState = 0
            mockDriver.biometricsAvailable = false
            mockDriver.existingPin = ""
            dynamicSpy.cleanup()
            finishedSpy.clear()
            loginSpy.clear()
        }

        function keyClickSequence(keys) {
            for (let k of keys) {
                keyClick(k)
            }
        }

        function getCurrentPage(stack, pageClass) {
            if (!stack || !pageClass)
                fail("getCurrentPage: expected param 'stack' or 'pageClass' empty")
            verify(!!stack)
            tryCompare(stack, "busy", false) // wait for page transitions to stop

            verify(stack.currentItem instanceof pageClass)
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
            let page = getCurrentPage(stack, WelcomePage)

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
            page = getCurrentPage(stack, HelpUsImproveStatusPage)

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
            page = getCurrentPage(stack, CreateProfilePage)

            const btnCreateWithPassword = findChild(controlUnderTest, "btnCreateWithPassword")
            verify(!!btnCreateWithPassword)
            mouseClick(btnCreateWithPassword)

            // PAGE 4: Create password
            page = getCurrentPage(stack, CreatePasswordPage)

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
                page = getCurrentPage(stack, EnableBiometricsPage)

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
            let page = getCurrentPage(stack, WelcomePage)

            const btnCreateProfile = findChild(controlUnderTest, "btnCreateProfile")
            verify(!!btnCreateProfile)
            mouseClick(btnCreateProfile)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, HelpUsImproveStatusPage)

            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Create profile
            page = getCurrentPage(stack, CreateProfilePage)

            const btnCreateWithSeedPhrase = findChild(controlUnderTest, "btnCreateWithSeedPhrase")
            verify(!!btnCreateWithSeedPhrase)
            mouseClick(btnCreateWithSeedPhrase)

            // PAGE 4: Create profile using a recovery phrase
            page = getCurrentPage(stack, SeedphrasePage)

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
            page = getCurrentPage(stack, CreatePasswordPage)

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
                page = getCurrentPage(stack, EnableBiometricsPage)

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

        // FLOW: Create Profile -> Use an empty Keycard -> Use a new recovery phrase (create profile with keycard + new seedphrase)
        function test_flow_createProfile_withKeycardAndNewSeedphrase(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, WelcomePage)
            const btnCreateProfile = findChild(controlUnderTest, "btnCreateProfile")
            verify(!!btnCreateProfile)
            mouseClick(btnCreateProfile)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, HelpUsImproveStatusPage)
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Create profile
            page = getCurrentPage(stack, CreateProfilePage)
            const btnCreateWithEmptyKeycard = findChild(controlUnderTest, "btnCreateWithEmptyKeycard")
            verify(!!btnCreateWithEmptyKeycard)
            mouseClick(btnCreateWithEmptyKeycard)

            // PAGE 4: Keycard intro
            page = getCurrentPage(stack, KeycardIntroPage)
            dynamicSpy.setup(page, "emptyKeycardDetected")
            mockDriver.keycardState = Onboarding.KeycardState.Empty // SIMULATION // TODO test other states here as well
            tryCompare(dynamicSpy, "count", 1)
            tryCompare(page, "state", "empty")

            // PAGE 5: Create profile on empty Keycard -> Use a new recovery phrase
            page = getCurrentPage(stack, CreateKeycardProfilePage)
            const btnCreateWithEmptySeedphrase = findChild(page, "btnCreateWithEmptySeedphrase")
            verify(!!btnCreateWithEmptySeedphrase)
            mouseClick(btnCreateWithEmptySeedphrase)

            // PAGE 6: Create new Keycard PIN
            const newPin = "123321"
            page = getCurrentPage(stack, KeycardCreatePinPage)
            tryCompare(page, "state", "creating")
            dynamicSpy.setup(page, "keycardPinCreated")
            keyClickSequence(newPin)
            tryCompare(page, "state", "repeating")
            keyClickSequence(newPin)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], newPin)
            dynamicSpy.setup(page, "keycardAuthorized")
            mockDriver.authorizationState = Onboarding.ProgressState.Success
            tryCompare(dynamicSpy, "count", 1)

            // PAGE 7: Backup your recovery phrase (intro)
            page = getCurrentPage(stack, BackupSeedphraseIntro)
            const btnBackupSeedphrase = findChild(page, "btnBackupSeedphrase")
            verify(!!btnBackupSeedphrase)
            mouseClick(btnBackupSeedphrase)

            // PAGE 8: Backup your recovery phrase (ack checkboxes)
            page = getCurrentPage(stack, BackupSeedphraseAcks)
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

            // PAGE 9: Backup your recovery phrase (seedphrase reveal) - step 1
            page = getCurrentPage(stack, BackupSeedphraseReveal)
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

            // PAGE 10: Backup your recovery phrase (seedphrase verification) - step 2
            page = getCurrentPage(stack, BackupSeedphraseVerify)
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

            // PAGE 11: Backup your recovery phrase (outro) - step 3
            page = getCurrentPage(stack, BackupSeedphraseOutro)
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

            // PAGE 12: Adding key pair to Keycard
            page = getCurrentPage(stack, KeycardAddKeyPairPage)
            tryCompare(page, "addKeyPairState", Onboarding.ProgressState.InProgress)
            page.addKeyPairState = Onboarding.ProgressState.Success // SIMULATION
            btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, true)
            mouseClick(btnContinue)

            // PAGE 13: Enable Biometrics
            if (data.biometrics) {
                page = getCurrentPage(stack, EnableBiometricsPage)

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
            compare(resultData.keycardPin, newPin)
            compare(resultData.seedphrase, mockDriver.seedWords.join(","))
        }

        // FLOW: Create Profile -> Use an empty Keycard -> Use an existing recovery phrase (create profile with keycard + existing seedphrase)
        function test_flow_createProfile_withKeycardAndExistingSeedphrase(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, WelcomePage)
            const btnCreateProfile = findChild(controlUnderTest, "btnCreateProfile")
            verify(!!btnCreateProfile)
            mouseClick(btnCreateProfile)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, HelpUsImproveStatusPage)
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Create profile
            page = getCurrentPage(stack, CreateProfilePage)
            const btnCreateWithEmptyKeycard = findChild(controlUnderTest, "btnCreateWithEmptyKeycard")
            verify(!!btnCreateWithEmptyKeycard)
            mouseClick(btnCreateWithEmptyKeycard)

            // PAGE 4: Keycard intro
            page = getCurrentPage(stack, KeycardIntroPage)
            dynamicSpy.setup(page, "emptyKeycardDetected")
            mockDriver.keycardState = Onboarding.KeycardState.Empty // SIMULATION // TODO test other states here as well
            tryCompare(dynamicSpy, "count", 1)
            tryCompare(page, "state", "empty")

            // PAGE 5: Create profile on empty Keycard -> Use an existing recovery phrase
            page = getCurrentPage(stack, CreateKeycardProfilePage)
            const btnCreateWithExistingSeedphrase = findChild(page, "btnCreateWithExistingSeedphrase")
            verify(!!btnCreateWithExistingSeedphrase)
            mouseClick(btnCreateWithExistingSeedphrase)

            // PAGE 6: Create new Keycard PIN
            const newPin = "123321"
            page = getCurrentPage(stack, KeycardCreatePinPage)
            tryCompare(page, "state", "creating")
            dynamicSpy.setup(page, "keycardPinCreated")
            keyClickSequence(newPin)
            tryCompare(page, "state", "repeating")
            keyClickSequence(newPin)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], newPin)
            dynamicSpy.setup(page, "keycardPinSuccessfullySet")
            mockDriver.pinSettingState = Onboarding.ProgressState.Success
            tryCompare(dynamicSpy, "count", 1)


            // PAGE 7: Create profile on empty Keycard using a recovery phrase
            page = getCurrentPage(stack, SeedphrasePage)
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
            dynamicSpy.setup(page, "keycardAuthorized")
            mockDriver.authorizationState = Onboarding.ProgressState.Success
            tryCompare(dynamicSpy, "count", 1)

            // PAGE 8: Adding key pair to Keycard
            page = getCurrentPage(stack, KeycardAddKeyPairPage)
            tryCompare(page, "addKeyPairState", Onboarding.ProgressState.InProgress)
            page.addKeyPairState = Onboarding.ProgressState.Success // SIMULATION
            const btnContinue2 = findChild(page, "btnContinue")
            verify(!!btnContinue2)
            compare(btnContinue2.enabled, true)
            mouseClick(btnContinue2)

            // PAGE 9: Enable Biometrics
            if (controlUnderTest.biometricsAvailable) {
                page = getCurrentPage(stack, EnableBiometricsPage)

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
            compare(resultData.keycardPin, newPin)
            compare(resultData.seedphrase, mockDriver.mnemonic)
        }

        // FLOW: Log in -> Log in with recovery phrase
        function test_flow_login_withSeedphrase(data) {
            verify(!!controlUnderTest)
            controlUnderTest.biometricsAvailable = data.biometrics

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Welcome
            let page = getCurrentPage(stack, WelcomePage)
            const btnLogin = findChild(controlUnderTest, "btnLogin")
            verify(!!btnLogin)
            mouseClick(btnLogin)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, HelpUsImproveStatusPage)
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Log in -> Enter recovery phrase
            page = getCurrentPage(stack, NewAccountLoginPage)
            const btnWithSeedphrase = findChild(page, "btnWithSeedphrase")
            verify(!!btnWithSeedphrase)
            mouseClick(btnWithSeedphrase)

            // PAGE 4: Sign in with your Status recovery phrase
            page = getCurrentPage(stack, SeedphrasePage)

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
            page = getCurrentPage(stack, CreatePasswordPage)

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
                page = getCurrentPage(stack, EnableBiometricsPage)

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
            let page = getCurrentPage(stack, WelcomePage)
            const btnLogin = findChild(controlUnderTest, "btnLogin")
            verify(!!btnLogin)
            mouseClick(btnLogin)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, HelpUsImproveStatusPage)
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Log in
            page = getCurrentPage(stack, NewAccountLoginPage)
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
            page = getCurrentPage(stack, LoginBySyncingPage)

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
            page = getCurrentPage(stack, SyncProgressPage)
            tryCompare(page, "syncState", Onboarding.ProgressState.InProgress)
            page.syncState = Onboarding.ProgressState.Success // SIMULATION
            const btnLogin2 = findChild(page, "btnLogin") // TODO test other flows/buttons here as well
            verify(!!btnLogin2)
            compare(btnLogin2.enabled, true)
            mouseClick(btnLogin2)

            // PAGE 6: Enable Biometrics
            if (data.biometrics) {
                page = getCurrentPage(stack, EnableBiometricsPage)

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
            let page = getCurrentPage(stack, WelcomePage)
            const btnLogin = findChild(controlUnderTest, "btnLogin")
            verify(!!btnLogin)
            mouseClick(btnLogin)

            // PAGE 2: Help us improve
            page = getCurrentPage(stack, HelpUsImproveStatusPage)
            const shareButton = findChild(controlUnderTest, data.shareBtnName)
            dynamicSpy.setup(page, "shareUsageDataRequested")
            mouseClick(shareButton)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], data.shareResult)

            // PAGE 3: Log in -> Login with Keycard
            page = getCurrentPage(stack, NewAccountLoginPage)
            const btnWithKeycard = findChild(page, "btnWithKeycard")
            verify(!!btnWithKeycard)
            mouseClick(btnWithKeycard)

            // PAGE 4: Keycard intro
            page = getCurrentPage(stack, KeycardIntroPage)
            dynamicSpy.setup(page, "notEmptyKeycardDetected")
            mockDriver.keycardState = Onboarding.KeycardState.NotEmpty // SIMULATION // TODO test other states here as well
            tryCompare(dynamicSpy, "count", 1)
            tryCompare(page, "state", "notEmpty")

            // PAGE 5: Enter Keycard PIN
            page = getCurrentPage(stack, KeycardEnterPinPage)
            dynamicSpy.setup(page, "authorizationRequested")
            keyClickSequence(mockDriver.existingPin)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], mockDriver.existingPin)

            dynamicSpy.setup(page, "exportKeysRequested")
            mockDriver.authorizationState = Onboarding.ProgressState.Success
            tryCompare(dynamicSpy, "count", 1)

            dynamicSpy.setup(page, "exportKeysDone")
            mockDriver.restoreKeysExportState = Onboarding.ProgressState.Success
            tryCompare(dynamicSpy, "count", 1)

            // PAGE 6: Enable Biometrics
            if (data.biometrics) {
                page = getCurrentPage(stack, EnableBiometricsPage)

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
            compare(resultData.keycardPin, "")
            compare(resultData.seedphrase, "")
        }

        // LOGIN SCREEN
        function test_loginScreen_data() {
            return [
              // password based profile ("uid_1")
              { tag: "correct password", keyUid: "uid_1", password: mockDriver.dummyNewPassword, biometrics: false },
              { tag: "correct password+biometrics", keyUid: "uid_1", password: mockDriver.dummyNewPassword, biometrics: true },
              { tag: "wrong password", keyUid: "uid_1", password: "foobar", biometrics: false },
              { tag: "wrong password+biometrics", keyUid: "uid_1", password: "foobar", biometrics: true },
              // keycard based profile ("uid_4")
              { tag: "correct PIN", keyUid: "uid_4", pin: "111111", biometrics: false },
              { tag: "correct PIN+biometrics", keyUid: "uid_4", pin: "111111", biometrics: true },
              { tag: "wrong PIN", keyUid: "uid_4", pin: "123321", biometrics: false },
              { tag: "wrong PIN+biometrics", keyUid: "uid_4", pin: "123321", biometrics: true },
            ]
        }
        function test_loginScreen(data) {
            verify(!!controlUnderTest)
            controlUnderTest.loginAccountsModel = loginAccountsModel
            controlUnderTest.biometricsAvailable = data.biometrics // both available _and_ enabled for this profile
            controlUnderTest.restartFlow()

            mockDriver.existingPin = "111111" // let this be the correct PIN

            const page = getCurrentPage(controlUnderTest.stack, LoginScreen)

            const userSelector = findChild(page, "loginUserSelector")
            verify(!!userSelector)
            userSelector.setSelection(data.keyUid) // select the right profile, keycard or regular one (password)
            tryCompare(userSelector, "selectedProfileKeyId", data.keyUid)
            tryCompare(userSelector, "keycardCreatedAccount", !!data.pin && data.pin !== "")

            if (!!data.password) { // regular profile, no keycard
                const loginButton = findChild(page, "loginButton")
                verify(!!loginButton)
                tryCompare(loginButton, "visible", true)
                compare(loginButton.enabled, false)

                const passwordBox = findChild(page, "passwordBox")
                verify(!!passwordBox)

                const passwordInput = findChild(page, "loginPasswordInput")
                verify(!!passwordInput)
                tryCompare(passwordInput, "activeFocus", true)
                if (data.biometrics) { // biometrics + password
                    if (data.password === mockDriver.dummyNewPassword) { // expecting correct fingerprint
                        // simulate the external biometrics signal
                        controlUnderTest.onboardingStore.obtainingPasswordSuccess(data.password)

                        tryCompare(passwordBox, "biometricsSuccessful", true)
                        tryCompare(passwordBox, "biometricsFailed", false)
                        tryCompare(passwordBox, "validationError", "")

                        // this fills the password and submits it, emits the loginRequested() signal below
                        tryCompare(passwordInput, "text", data.password)
                    } else { // expecting wrong fingerprint
                        // simulate the external biometrics signal
                        controlUnderTest.onboardingStore.obtainingPasswordError("ERROR", Constants.keychain.errorType.keychain, true)

                        tryCompare(passwordBox, "biometricsSuccessful", false)
                        tryCompare(passwordBox, "biometricsFailed", true)
                        tryCompare(passwordBox, "validationError", "Fingerprint not recognised. Try entering password instead.")

                        // this fails and switches to the password method; so just verify we have an error and can enter the pass manually
                        tryCompare(passwordInput, "hasError", true)
                        tryCompare(passwordInput, "activeFocus", true)
                        tryCompare(passwordInput, "text", "")
                        expectFail(data.tag, "Wrong fingerprint, expected to fail to login")
                    }
                } else { // manual password
                    keyClickSequence(data.password)
                    tryCompare(passwordInput, "text", data.password)
                    compare(loginButton.enabled, true)
                    mouseClick(loginButton)
                }

                // verify the final "loginRequested" signal emission and params
                tryCompare(loginSpy, "count", 1)
                compare(loginSpy.signalArguments[0][0], data.keyUid)
                compare(loginSpy.signalArguments[0][1], Onboarding.LoginMethod.Password)
                const resultData = loginSpy.signalArguments[0][2]
                verify(!!resultData)
                compare(resultData.password, data.password)

                // verify validation & pass error
                tryCompare(passwordInput, "hasError", data.password !== mockDriver.dummyNewPassword)
            } else if (!!data.pin) { // keycard profile
                mockDriver.keycardState = Onboarding.KeycardState.NotEmpty // happy path; keycard ready
                const pinInput = findChild(page, "pinInput")
                verify(!!pinInput)
                tryCompare(pinInput, "visible", true)
                compare(pinInput.pinInput, "")

                const keycardBox = findChild(page, "keycardBox")
                verify(!!keycardBox)

                if (data.biometrics) { // biometrics + PIN
                    if (data.pin === mockDriver.existingPin) { // expecting correct fingerprint
                        // simulate the external biometrics signal
                        controlUnderTest.onboardingStore.obtainingPasswordSuccess(data.pin)

                        tryCompare(keycardBox, "biometricsSuccessful", true)
                        tryCompare(keycardBox, "biometricsFailed", false)

                        // this fills the password and submits it, emits the loginRequested() signal below
                        tryCompare(pinInput, "pinInput", data.pin)
                    } else { // expecting wrong fingerprint
                        // simulate the external biometrics signal
                        controlUnderTest.onboardingStore.obtainingPasswordError("Fingerprint not recognized",
                                                                                Constants.keychain.errorType.keychain, true)

                        tryCompare(keycardBox, "biometricsSuccessful", false)
                        tryCompare(keycardBox, "biometricsFailed", true)

                        // this fails and lets the user enter the PIN manually; so just verify we have an error and empty PIN
                        tryCompare(pinInput, "pinInput", "")
                        expectFail(data.tag, "Wrong fingerprint, expected to fail to login")
                    }
                } else { // manual PIN
                    keyClickSequence(data.pin)
                    if (data.pin !== mockDriver.existingPin) {
                        expectFail(data.tag, "Wrong PIN entered, expected to fail to login")
                    }
                }

                // verify the final "loginRequested" signal emission and params
                tryCompare(loginSpy, "count", 1)
                compare(loginSpy.signalArguments[0][0], data.keyUid)
                compare(loginSpy.signalArguments[0][1], Onboarding.LoginMethod.Keycard)
                const resultData = loginSpy.signalArguments[0][2]
                verify(!!resultData)
                compare(resultData.pin, data.pin)
            }
        }

        function test_loginScreen_launchesExternalFlow_data() {
            return [
              { tag: "onboarding: create profile", delegateName: "createProfileDelegate", signalName: "onboardingCreateProfileFlowRequested", landingPageTitle: "Create profile" },
              { tag: "onboarding: log in", delegateName: "logInDelegate", signalName: "onboardingLoginFlowRequested", landingPageTitle: "Log in" },
              // TODO cover also `signal unblockWithSeedphraseRequested()` and `signal lostKeycard()`
            ]
        }
        function test_loginScreen_launchesExternalFlow(data) {
            verify(!!controlUnderTest)
            controlUnderTest.loginAccountsModel = loginAccountsModel
            controlUnderTest.restartFlow()

            const page = getCurrentPage(controlUnderTest.stack, LoginScreen)

            const loginUserSelector = findChild(page, "loginUserSelector")
            verify(!!loginUserSelector)
            mouseClick(loginUserSelector)

            const dropdown = findChild(loginUserSelector, "dropdown")
            verify(!!dropdown)
            tryCompare(dropdown, "opened", true)

            const menuDelegate = findChild(dropdown, data.delegateName)
            verify(!!menuDelegate)
            dynamicSpy.setup(page, data.signalName)
            mouseClick(menuDelegate)
            tryCompare(dynamicSpy, "count", 1)

            tryCompare(controlUnderTest.stack.currentItem, "title", data.landingPageTitle)
        }

        function test_loginScreenLostKeycardSeedphraseLoginFlow() {
            verify(!!controlUnderTest)
            controlUnderTest.loginAccountsModel = loginAccountsModel
            controlUnderTest.biometricsAvailable = false
            controlUnderTest.restartFlow()

            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            // PAGE 1: Login screen
            let page = getCurrentPage(stack, LoginScreen)
            const keyUid = "uid_4"

            const userSelector = findChild(page, "loginUserSelector")
            verify(!!userSelector)
            userSelector.setSelection(keyUid)
            tryCompare(userSelector, "selectedProfileKeyId", keyUid)
            tryCompare(userSelector, "keycardCreatedAccount", true)

            const lostKeycardButon = findChild(page, "lostKeycardButon")
            verify(!!lostKeycardButon)
            mouseClick(lostKeycardButon)

            // PAGE 2: Keycard lost page
            page = getCurrentPage(stack, KeycardLostPage)

            const startUsingWithoutKeycardButton = findChild(page, "startUsingWithoutKeycardButton")
            verify(!!startUsingWithoutKeycardButton)
            mouseClick(startUsingWithoutKeycardButton)

            // PAGE 3: Seedphrase
            page = getCurrentPage(stack, SeedphrasePage)

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

            // PAGE 4: Create password
            page = getCurrentPage(stack, CreatePasswordPage)

            const btnConfirmPassword = findChild(page, "btnConfirmPassword")
            verify(!!btnConfirmPassword)
            compare(btnConfirmPassword.enabled, false)

            const passwordViewNewPassword = findChild(page, "passwordViewNewPassword")
            verify(!!passwordViewNewPassword)
            mouseClick(passwordViewNewPassword)
            compare(passwordViewNewPassword.activeFocus, true)
            compare(passwordViewNewPassword.text, "")

            keyClickSequence(mockDriver.dummyNewPassword)
            compare(passwordViewNewPassword.text, mockDriver.dummyNewPassword)
            compare(btnConfirmPassword.enabled, false)

            const passwordViewNewPasswordConfirm = findChild(page, "passwordViewNewPasswordConfirm")
            verify(!!passwordViewNewPasswordConfirm)
            mouseClick(passwordViewNewPasswordConfirm)
            compare(passwordViewNewPasswordConfirm.activeFocus, true)
            compare(passwordViewNewPasswordConfirm.text, "")

            keyClickSequence(mockDriver.dummyNewPassword)
            compare(passwordViewNewPassword.text, mockDriver.dummyNewPassword)
            compare(btnConfirmPassword.enabled, true)

            mouseClick(btnConfirmPassword)

            // FINISH
            tryCompare(finishedSpy, "count", 1)
            compare(finishedSpy.signalArguments[0][0], Onboarding.SecondaryFlow.LoginWithLostKeycardSeedphrase)
            const resultData = finishedSpy.signalArguments[0][1]
            verify(!!resultData)
            compare(resultData.password, mockDriver.dummyNewPassword)
            compare(resultData.enableBiometrics, false)
            compare(resultData.keycardPin, "")
            compare(resultData.seedphrase, mockDriver.mnemonic)
        }

        function test_loginScreenLostKeycardCreateReplacementFlow() {
            verify(!!controlUnderTest)
            controlUnderTest.loginAccountsModel = loginAccountsModel
            controlUnderTest.biometricsAvailable = false
            controlUnderTest.restartFlow()

            // PAGE 1: Login screen
            const stack = findChild(controlUnderTest, "stack")
            verify(!!stack)

            let page = getCurrentPage(stack, LoginScreen)
            const keyUid = "uid_4"

            const userSelector = findChild(page, "loginUserSelector")
            verify(!!userSelector)
            userSelector.setSelection(keyUid)
            tryCompare(userSelector, "selectedProfileKeyId", keyUid)
            tryCompare(userSelector, "keycardCreatedAccount", true)

            const lostKeycardButon = findChild(page, "lostKeycardButon")
            verify(!!lostKeycardButon)
            mouseClick(lostKeycardButon)

            // PAGE 2: Keycard lost page
            page = getCurrentPage(stack, KeycardLostPage)

            const startUsingWithoutKeycardButton = findChild(page, "createReplacementButton")
            verify(!!startUsingWithoutKeycardButton)
            mouseClick(startUsingWithoutKeycardButton)

            // PAGE 3: Keycard intro
            page = getCurrentPage(stack, KeycardIntroPage)
            dynamicSpy.setup(page, "emptyKeycardDetected")
            mockDriver.keycardState = Onboarding.KeycardState.Empty // SIMULATION // TODO test other states here as well
            tryCompare(dynamicSpy, "count", 1)
            tryCompare(page, "state", "empty")

            // PAGE 4: Seedphrase
            page = getCurrentPage(stack, SeedphrasePage)
            let btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, false)

            const firstInput = findChild(page, "enterSeedPhraseInputField1")
            verify(!!firstInput)
            tryCompare(firstInput, "activeFocus", true)
            ClipboardUtils.setText(mockDriver.mnemonic)
            keySequence(StandardKey.Paste)
            compare(btnContinue.enabled, true)
            mouseClick(btnContinue)

            // PAGE 5: Create new Keycard PIN
            const newPin = "123321"
            page = getCurrentPage(stack, KeycardCreatePinPage)
            tryCompare(page, "state", "creating")
            dynamicSpy.setup(page, "keycardPinCreated")
            keyClickSequence(newPin)
            tryCompare(page, "state", "repeating")
            keyClickSequence(newPin)
            tryCompare(dynamicSpy, "count", 1)
            compare(dynamicSpy.signalArguments[0][0], newPin)
            dynamicSpy.setup(page, "keycardAuthorized")
            mockDriver.authorizationState = Onboarding.ProgressState.Success
            tryCompare(dynamicSpy, "count", 1)

            // PAGE 6: Adding key pair to Keycard
            page = getCurrentPage(stack, KeycardAddKeyPairPage)
            tryCompare(page, "addKeyPairState", Onboarding.ProgressState.InProgress)
            page.addKeyPairState = Onboarding.ProgressState.Success // SIMULATION

            btnContinue = findChild(page, "btnContinue")
            verify(!!btnContinue)
            compare(btnContinue.enabled, true)
            mouseClick(btnContinue)

            // FINISH
            tryCompare(finishedSpy, "count", 1)
            compare(finishedSpy.signalArguments[0][0], Onboarding.SecondaryFlow.LoginWithRestoredKeycard)
            const resultData = finishedSpy.signalArguments[0][1]
            verify(!!resultData)
            compare(resultData.enableBiometrics, false)
            compare(resultData.keycardPin, newPin)
            compare(resultData.seedphrase, mockDriver.mnemonic)
        }
    }
}
