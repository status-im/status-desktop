import QtQuick 2.12
import QtQml.StateMachine 1.14 as DSM
import utils 1.0

import "views"
import "stores"

QtObject {
    id: root
    property bool hasAccounts
    property string keysMainSetState: ""

    signal loadApp()
    signal onBoardingStepChanged(var view, string state)

    property var stateMachine: DSM.StateMachine {
        id: stateMachine
        initialState: onboardingState
        running: true

        DSM.State {
            id: onboardingState
            initialState: root.hasAccounts ? stateLogin : welcomeMainState

            DSM.State {
                id: welcomeMainState
                onEntered: { onBoardingStepChanged(welcomeMain, ""); }

                DSM.SignalTransition {
                    targetState: keysMainState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "KeyMain"
                }
            }

            DSM.State {
                id: keysMainState
                onEntered: { onBoardingStepChanged(keysMain, root.keysMainSetState); }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "GenKey"
                }

                DSM.SignalTransition {
                    targetState: welcomeMainState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "Welcome"
                }
            }

            DSM.State {
                id: existingKeyState
                onEntered: { onBoardingStepChanged(existingKey, ""); }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "GenKey"
                }

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }

                DSM.SignalTransition {
                    targetState: welcomeMainState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "Welcome"
                }
            }

            DSM.State {
                id: genKeyState
                onEntered: { onBoardingStepChanged(genKey, ""); }
                DSM.SignalTransition {
                    targetState: welcomeMainState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "Welcome"
                }

                DSM.SignalTransition {
                    targetState: appState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "LoggedIn"
                }

                DSM.SignalTransition {
                    targetState: stateLogin
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "LogIn"
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
                targetState: keysMainState
                signal: Global.applicationWindow.navigateTo
                guard: path === "KeysMain"
            }

            DSM.SignalTransition {
                targetState: existingKeyState
                signal: Global.applicationWindow.navigateTo
                guard: path === "ExistingKey"
            }

            DSM.SignalTransition {
                targetState: keycardState
                signal: Global.applicationWindow.navigateTo
                guard: path === "KeycardFlowSelection"
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
                root.keysMainSetState = "getkeys";
                Global.applicationWindow.navigateTo("KeyMain");
            }
            onBtnExistingUserClicked: {
                root.keysMainSetState = "connectkeys";
                Global.applicationWindow.navigateTo("KeyMain");
            }
        }
    }

    property var keysMainComponent: Component {
        id: keysMain
        KeysMainView {
            onButtonClicked: {
                OnboardingStore.accountImported = false
                Global.applicationWindow.navigateTo("GenKey");
            }
            onKeycardLinkClicked: {
                OnboardingStore.accountImported = false
                Global.applicationWindow.navigateTo("KeycardFlowSelection");
            }
            onSeedLinkClicked: {
                Global.applicationWindow.navigateTo("ExistingKey");
            }
            onBackClicked: {
                OnboardingStore.accountImported = false
                Global.applicationWindow.navigateTo("Welcome");
            }
        }
    }

    property var existingKeyComponent: Component {
        id: existingKey
        ExistingKeyView {
            onShowCreatePasswordView: {
                Global.applicationWindow.navigateTo("GenKey");
            }
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
            onFinished: {
                if (LoginStore.currentAccount.username !== "") {
                    Global.applicationWindow.navigateTo("LogIn");
                } else {
                    Global.applicationWindow.navigateTo("KeysMain");
                }
            }
            onKeysGenerated: {
                Global.applicationWindow.navigateTo("LoggedIn")
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
}
