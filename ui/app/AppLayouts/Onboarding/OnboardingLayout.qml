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

    backButtonVisible: root.startupStore.currentStartupState ? root.startupStore.currentStartupState.displayBackButton
                                                             : false

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
            switch (root.startupStore.currentStartupState.stateType) {
            case Constants.startupState.allowNotifications:
                return allowNotificationsViewComponent

            case Constants.startupState.welcome:
                return welcomeViewComponent

            case Constants.startupState.welcomeNewStatusUser:
            case Constants.startupState.welcomeOldStatusUser:
            case Constants.startupState.recoverOldUser:
            case Constants.startupState.userProfileImportSeedPhrase:
            case Constants.startupState.profileFetchingAnnouncement:
            case Constants.startupState.userProfileCreateSameChatKey:
                return keysMainViewComponent

            case Constants.startupState.userProfileCreate:
            case Constants.startupState.userProfileChatKey:
                return insertDetailsViewComponent

            case Constants.startupState.userProfileCreatePassword:
                return createPasswordViewComponent

            case Constants.startupState.userProfileConfirmPassword:
                return confirmPasswordViewComponent

            case Constants.startupState.biometrics:
                return touchIdAuthViewComponent

            case Constants.startupState.userProfileEnterSeedPhrase:
                return seedPhraseInputViewComponent

            case Constants.startupState.login:
            case Constants.startupState.loginPlugin:
            case Constants.startupState.loginKeycardInsertKeycard:
            case Constants.startupState.loginKeycardInsertedKeycard:
            case Constants.startupState.loginKeycardReadingKeycard:
            case Constants.startupState.loginKeycardRecognizedKeycard:
            case Constants.startupState.loginKeycardEnterPin:
            case Constants.startupState.loginKeycardEnterPassword:
            case Constants.startupState.loginKeycardPinVerified:
            case Constants.startupState.loginKeycardWrongKeycard:
            case Constants.startupState.loginKeycardWrongPin:
            case Constants.startupState.loginKeycardMaxPinRetriesReached:
            case Constants.startupState.loginKeycardMaxPukRetriesReached:
            case Constants.startupState.loginKeycardMaxPairingSlotsReached:
            case Constants.startupState.loginKeycardEmpty:
            case Constants.startupState.loginNotKeycard:
                return loginViewComponent

            case Constants.startupState.keycardPluginReader:
            case Constants.startupState.keycardInsertKeycard:
            case Constants.startupState.keycardInsertedKeycard:
            case Constants.startupState.keycardReadingKeycard:
            case Constants.startupState.keycardRecognizedKeycard:
                return keycardInitViewComponent

            case Constants.startupState.keycardCreatePin:
            case Constants.startupState.keycardRepeatPin:
            case Constants.startupState.keycardPinSet:
            case Constants.startupState.keycardEnterPin:
            case Constants.startupState.keycardWrongPin:
                return keycardPinViewComponent

            case Constants.startupState.keycardDisplaySeedPhrase:
                return seedphraseViewComponent

            case Constants.startupState.keycardEnterSeedPhraseWords:
                return seedphraseWordsInputViewComponent

            case Constants.startupState.keycardNotEmpty:
            case Constants.startupState.keycardNotKeycard:
            case Constants.startupState.keycardEmpty:
            case Constants.startupState.keycardWrongKeycard:
            case Constants.startupState.keycardLocked:
            case Constants.startupState.keycardRecover:
            case Constants.startupState.keycardMaxPairingSlotsReached:
            case Constants.startupState.keycardMaxPinRetriesReached:
            case Constants.startupState.keycardMaxPukRetriesReached:
                return keycardStateViewComponent

            case Constants.startupState.keycardEnterPuk:
            case Constants.startupState.keycardWrongPuk:
                return keycardPukViewComponent

            case Constants.startupState.keycardWrongPuk:
                return keycardPukViewComponent

            case Constants.startupState.keycardWrongPuk:
                return keycardPukViewComponent

            case Constants.startupState.profileFetching:
            case Constants.startupState.profileFetchingSuccess:
            case Constants.startupState.profileFetchingTimeout:
                return fetchingDataViewComponent
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

    Component {
        id: fetchingDataViewComponent
        ProfileFetchingView {
            startupStore: root.startupStore
        }
    }

    Loader {
        id: keycardPopup
        active: false
        sourceComponent: KeycardPopup {
            anchors.centerIn: parent
            sharedKeycardModule: root.startupStore.startupModuleInst.keycardSharedModule
        }

        onLoaded: {
            keycardPopup.item.open()
        }
    }
}
