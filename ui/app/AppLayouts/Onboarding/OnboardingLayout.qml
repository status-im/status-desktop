import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3

import utils 1.0
import mainui 1.0

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
            else if (root.startupStore.currentStartupState.stateType === Constants.startupState.welcome)
            {
                return welcomeViewComponent
            }
            else if (root.startupStore.currentStartupState.stateType === Constants.startupState.welcomeNewStatusUser ||
                     root.startupStore.currentStartupState.stateType === Constants.startupState.welcomeOldStatusUser ||
                     root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileImportSeedPhrase)
            {
                return keysMainViewComponent
            }
            else if (root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileCreate ||
                     root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileChatKey)
            {
                return insertDetailsViewComponent
            }
            else if (root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileCreatePassword)
            {
                return createPasswordViewComponent
            }
            else if (root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileConfirmPassword)
            {
                return confirmPasswordViewComponent
            }
            else if (root.startupStore.currentStartupState.stateType === Constants.startupState.biometrics)
            {
                return touchIdAuthViewComponent
            }
            else if (root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileEnterSeedPhrase)
            {
                return seedPhraseInputViewComponent
            }
            else if (root.startupStore.currentStartupState.stateType === Constants.startupState.login)
            {
                return loginViewComponent
            }
            else if (root.startupStore.currentStartupState.stateType === Constants.startupState.loadingAppAnimation)
            {
                return splashScreenView
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
                msgDialog.text = qsTr("Keys for this account already exist and can't be added again. If you've lost your password, passcode or Keycard, uninstall the app, reinstall and access your keys by entering your seed phrase")
            } else {
                msgDialog.title = qsTr("Error importing seed")
                msgDialog.text = error
            }
            msgDialog.open()
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
        id: splashScreenView
        SplashScreen {
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
}
