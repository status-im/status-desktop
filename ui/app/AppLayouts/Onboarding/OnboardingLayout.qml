import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.popups.keycard 1.0

import "controls"
import "views"
import "stores"

OnboardingBasePage {
    id: root

    property var startupStore: StartupStore {}

    backButtonVisible: root.startupStore.currentStartupState.displayBackButton

    onBackClicked: {
        root.startupStore.backAction()
    }

    function unload() {
        loader.sourceComponent  = undefined
    }

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.allowNotifications)
            {
                return allowNotificationsViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.welcome)
            {
                return welcomeViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.welcomeNewStatusUser ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.welcomeOldStatusUser ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileImportSeedPhrase)
            {
                return keysMainViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileCreate ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileChatKey)
            {
                return insertDetailsViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileCreatePassword)
            {
                return createPasswordViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileConfirmPassword)
            {
                return confirmPasswordViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.biometrics)
            {
                return touchIdAuthViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileEnterSeedPhrase)
            {
                return seedPhraseInputViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.login ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardInsertKeycard ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardReadingKeycard ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardEnterPin ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardWrongKeycard ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardWrongPin ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardMaxPinRetriesReached ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardMaxPukRetriesReached ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.loginKeycardEmpty)
            {
                return loginViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardPluginReader ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardInsertKeycard ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardReadingKeycard)
            {
                return keycardInitViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardCreatePin ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardRepeatPin ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardPinSet ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardEnterPin ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardWrongPin)
            {
                return keycardPinViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardDisplaySeedPhrase)
            {
                return seedphraseViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardEnterSeedPhraseWords)
            {
                return seedphraseWordsInputViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardNotEmpty ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardEmpty ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardLocked ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardRecover ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPairingSlotsReached ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPinRetriesReached ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPukRetriesReached)
            {
                return keycardStateViewComponent
            }
            if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardEnterPuk ||
                    root.startupStore.currentStartupState.stateType === Constants.startupState.keycardWrongPuk)
            {
                return keycardPukViewComponent
            }

            return undefined
        }
    }

    Connections {
        target: root.startupStore.startupModuleInst
        onAccountSetupError: {
            if (error === Constants.existingAccountError) {
                msgDialog.title = qsTr("Keys for this account already exist")
                msgDialog.text = qsTr("Keys for this account already exist and can't be added again. If you've lost your password, passcode or Keycard, uninstall the app, reinstall and access your keys by entering your seed phrase")
            } else {
                msgDialog.title = qsTr("Login failed")
                msgDialog.text = qsTr("Login failed. Please re-enter your password and try again.")
            }
            msgDialog.open()
        }

        onAccountImportError: {
            if (error === Constants.existingAccountError) {
                msgDialog.title = qsTr("Keys for this account already exist")
                msgDialog.text = qsTr("Keys for this account already exist and can't be added again. If you've lost \
your password, passcode or Keycard, uninstall the app, reinstall and access your keys by entering your seed phrase. In \
case of Keycard try recovering using PUK or reinstall the app and try login with the Keycard option.")
            } else {
                msgDialog.title = qsTr("Error importing seed")
                msgDialog.text = error
            }
            msgDialog.open()
        }
        onDisplayKeycardSharedModuleFlow: {
            keycardPopup.active = true
        }
        onDestroyKeycardSharedModuleFlow: {
            keycardPopup.active = false
        }
    }

    MessageDialog {
        id: msgDialog
        title: qsTr("Login failed")
        text: qsTr("Login failed. Please re-enter your password and try again.")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
        onAccepted: {
            console.log("TODO: restart flow...")
        }
    }

    Component {
        id: allowNotificationsViewComponent
        AllowNotificationsView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: welcomeViewComponent
        WelcomeView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: keysMainViewComponent
        KeysMainView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: insertDetailsViewComponent
        InsertDetailsView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: createPasswordViewComponent
        CreatePasswordView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: confirmPasswordViewComponent
        ConfirmPasswordView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: touchIdAuthViewComponent
        TouchIDAuthView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: seedPhraseInputViewComponent
        SeedPhraseInputView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: loginViewComponent
        LoginView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: keycardInitViewComponent
        KeycardInitView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: keycardPinViewComponent
        KeycardPinView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: keycardPukViewComponent
        KeycardPukView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: seedphraseViewComponent
        SeedPhraseView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: seedphraseWordsInputViewComponent
        SeedPhraseWordsInputView {
            startupStore: root.startupStore
        }
    }

    Component {
        id: keycardStateViewComponent
        KeycardStateView {
            startupStore: root.startupStore
        }
    }

    Loader {
        id: keycardPopup
        active: false
        sourceComponent: KeycardPopup {
            sharedKeycardModule: root.startupStore.startupModuleInst.keycardSharedModule
        }

        onLoaded: {
            keycardPopup.item.open()
        }
    }
}
