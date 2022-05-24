import QtQuick 2.12
import QtQml.StateMachine 1.14 as DSM
import utils 1.0

import "views"
import "stores"

QtObject {
    id: root
    property bool hasAccounts
    property string keysMainSetState: ""
    property string prevState: ""

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
                    targetState: importSeedState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "ImportSeed"
                }

                DSM.SignalTransition {
                    targetState: welcomeMainState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "Welcome"
                }

                DSM.SignalTransition {
                    targetState: stateLogin
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "LogIn"
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

                DSM.SignalTransition {
                    targetState: importSeedState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "ImportSeed"
                }
            }

            DSM.State {
                id: importSeedState
                property string seedInputState: "existingUser"
                onEntered: { onBoardingStepChanged(seedPhrase, seedInputState); }

                DSM.SignalTransition {
                    targetState: keysMainState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "KeyMain"
                }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "GenKey"
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
                if (state === "importseed") {
                    importSeedState.seedInputState = "existingUser";
                    Global.applicationWindow.navigateTo("ImportSeed");
                } else {
                    importSeedState.seedInputState = "newUser";
                    Global.applicationWindow.navigateTo("GenKey");
                }
            }
            onKeycardLinkClicked: {
                Global.applicationWindow.navigateTo("KeycardFlowSelection");
            }
            onSeedLinkClicked: {
                if (state === "getkeys") {
                    importSeedState.seedInputState = "newUser";
                    state = "importseed";
                } else {
                    importSeedState.seedInputState = "existingUser";
                    Global.applicationWindow.navigateTo("ImportSeed");
                }
            }
            onBackClicked: {
                if (state === "importseed") {
                    state = "getkeys";
                } else if (((root.keysMainSetState === "connectkeys") && (LoginStore.currentAccount.username !== ""))
                          || (root.prevState === "LogIn") || (state === "getkeys")) {
                    Global.applicationWindow.navigateTo("LogIn");
                } else {
                    Global.applicationWindow.navigateTo("Welcome");
                }
            }
        }
    }

    property var seedPhraseInputComponent: Component {
        id: seedPhrase
        SeedPhraseInputView {
            onExit: {
                if (root.keysMainSetState !== "connectkeys") {
                    root.keysMainSetState = "importseed";
                }
                Global.applicationWindow.navigateTo("KeyMain");
            }
            onSeedValidated: {
                root.keysMainSetState = "importseed";
                Global.applicationWindow.navigateTo("GenKey");
            }
        }
    }

    property var genKeyComponent: Component {
        id: genKey
        GenKeyView {
            onExit: {
                if (root.keysMainSetState === "importseed") {
                    root.keysMainSetState = "connectkeys"
                    Global.applicationWindow.navigateTo("ImportSeed");
                } else if (LoginStore.currentAccount.username !== "" && importSeedState.seedInputState === "existingUser") {
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
            onClosed: {
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
            onAddNewUserClicked: {
                root.keysMainSetState = "getkeys";
                root.prevState = "LogIn"
                Global.applicationWindow.navigateTo("KeysMain");
            }
            onAddExistingKeyClicked: {
                root.keysMainSetState = "connectkeys";
                root.prevState = "LogIn"
                Global.applicationWindow.navigateTo("KeysMain");
            }
        }
    }
}
