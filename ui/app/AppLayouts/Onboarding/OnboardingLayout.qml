import QtQuick 2.12
import QtQml.StateMachine 1.14 as DSM
import utils 1.0

import "views"
import "stores"

QtObject {
    id: root
    property bool hasAccounts
    signal loadApp()
    signal onBoardingStepChanged(var view, string state)

    property var stateMachine: DSM.StateMachine {
        id: stateMachine
        initialState: onboardingState
        running: true

        DSM.State {
            id: onboardingState
            initialState: root.hasAccounts ? stateLogin : keysMainState

            DSM.State {
                id: keysMainState
                onEntered: { onBoardingStepChanged(welcomeMain, ""); }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "GenKey"
                }
            }

            DSM.State {
                id: existingKeyState
                onEntered: { onBoardingStepChanged(existingKey, ""); }

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }
            }

            DSM.State {
                id: genKeyState
                onEntered: { onBoardingStepChanged(genKey, ""); }

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }
            }

            DSM.State {
                id: keycardState
                onEntered: { onBoardingStepChanged(keycardFlowSelection, ""); }

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }
            }

            DSM.State {
                id: createPasswordState
                onEntered: loader.sourceComponent = createPassword

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }
            }

            DSM.State {
                id: confirmPasswordState
                onEntered: loader.sourceComponent = confirmPassword

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }
            }

            DSM.State {
                id: stateLogin
                onEntered: { onBoardingStepChanged(login, ""); }

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "GenKey"
                }
            }

            DSM.SignalTransition {
                targetState: root.hasAccounts ? stateLogin : keysMainState
                signal: Global.applicationWindow.navigateTo
                guard: path === "InitialState"
            }

            DSM.SignalTransition {
                targetState: existingKeyState
                signal: Global.applicationWindow.navigateTo
                guard: path === "ExistingKey"
            }

            DSM.SignalTransition {
                targetState: keysMainState
                signal: Global.applicationWindow.navigateTo
                guard: path === "KeysMain"
            }

            DSM.SignalTransition {
                targetState: keycardState
                signal: Global.applicationWindow.navigateTo
                guard: path === "KeycardFlowSelection"
            }

            DSM.SignalTransition {
                targetState: createPasswordState
                signal: applicationWindow.navigateTo
                guard: path === "CreatePassword"
            }

            DSM.SignalTransition {
                targetState: confirmPasswordState
                signal: applicationWindow.navigateTo
                guard: path === "ConfirmPassword"
            }

            DSM.FinalState {
                id: onboardingDoneState
            }
        }

        DSM.State {
            id: appState
            onEntered: loadApp();

            DSM.SignalTransition {
                targetState: stateLogin
                signal: startupModule.logOut
            }
        }
    }

    property var welcomeComponent: Component {
        id: welcomeMain
        WelcomeView {
            onBtnNewUserClicked: {
                onBoardingStepChanged(keysMain, "getkeys");
            }
            onBtnExistingUserClicked: {
                onBoardingStepChanged(keysMain, "connectkeys");
            }
        }
    }

    property var keysMainComponent: Component {
        id: keysMain
        KeysMainView {
            onButtonClicked: {
                Global.applicationWindow.navigateTo("GenKey");
            }
            onKeycardLinkClicked: {
                Global.applicationWindow.navigateTo("KeycardFlowSelection");
            }
            onSeedLinkClicked: {
                Global.applicationWindow.navigateTo("ExistingKey");
            }
            onBackClicked: {
                onBoardingStepChanged(welcomeMain, "");
            }
        }
    }

    property var existingKeyComponent: Component {
        id: existingKey
        ExistingKeyView {
            onShowCreatePasswordView: { Global.applicationWindow.navigateTo("CreatePassword") }
            onClosed: function () {
                if (root.hasAccounts) {
                    Global.applicationWindow.navigateTo("InitialState")
                } else {
                    Global.applicationWindow.navigateTo("KeysMain")
                }
            }
        }
    }

    property var genKeyComponent: Component {
        id: genKey
        GenKeyView {
            onShowCreatePasswordView: { Global.applicationWindow.navigateTo("CreatePassword") }
            onClosed: function () {
                if (root.hasAccounts) {
                    Global.applicationWindow.navigateTo("InitialState")
                } else {
                    Global.applicationWindow.navigateTo("KeysMain")
                }
            }
        }
    }

    property var keycardFlowSelectionComponent: Component {
        id: keycardFlowSelection
        KeycardFlowSelectionView {
            onClosed: function () {
                if (root.hasAccounts) {
                    Global.applicationWindow.navigateTo("InitialState")
                } else {
                    Global.applicationWindow.navigateTo("KeysMain")
                }
            }
        }
    }

    property var loginComponent: Component {
        id: login
        LoginView {
            onGenKeyClicked: function () {
                Global.applicationWindow.navigateTo("GenKey")
            }
            onExistingKeyClicked: function () {
                Global.applicationWindow.navigateTo("ExistingKey")
            }
        }
    }

    property var d: QtObject {
        property string newPassword
        property string confirmationPassword
    }

    property var createPasswordComponent: Component {
        id: createPassword
        CreatePasswordView {
            store: OnboardingStore
            newPassword: d.newPassword
            confirmationPassword: d.confirmationPassword

            onPasswordCreated: {
                d.newPassword = newPassword
                d.confirmationPassword = confirmationPassword
                applicationWindow.navigateTo("ConfirmPassword")
            }
            onBackClicked: {
                d.newPassword = ""
                d.confirmationPassword = ""
                applicationWindow.navigateTo("InitialState");
                console.warn("TODO: Integration with onboarding flow!")
            }
        }
    }

     property var confirmPasswordComponent: Component {
        id: confirmPassword
        ConfirmPasswordView {
            password: d.newPassword

            onBackClicked: { applicationWindow.navigateTo("CreatePassword") }
        }
    }
}
