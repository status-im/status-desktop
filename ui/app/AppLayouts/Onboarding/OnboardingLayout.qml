import QtQuick 2.12
import QtQml.StateMachine 1.14 as DSM
import utils 1.0

import "views"
import "stores"

QtObject {
    id: root
    property bool hasAccounts
    signal loadApp()
    signal onBoardingStepChanged(var view)

    property var stateMachine: DSM.StateMachine {
        id: stateMachine
        initialState: onboardingState
        running: true

        DSM.State {
            id: onboardingState
            initialState: root.hasAccounts ? stateLogin : keysMainState

            DSM.State {
                id: keysMainState
                onEntered: { onBoardingStepChanged(keysMain); }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: Global.applicationWindow.navigateTo
                    guard: path === "GenKey"
                }
            }

            DSM.State {
                id: existingKeyState
                onEntered: { onBoardingStepChanged(existingKey); }

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }
            }

            DSM.State {
                id: genKeyState
                onEntered: { onBoardingStepChanged(genKey); }

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }
            }

            DSM.State {
                id: keycardState
                onEntered: { onBoardingStepChanged(keycardFlowSelection); }

                DSM.SignalTransition {
                    targetState: appState
                    signal: startupModule.appStateChanged
                    guard: state === Constants.appState.main
                }
            }

            DSM.State {
                id: stateLogin
                onEntered: { onBoardingStepChanged(login); }

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

    property var keysMainComponent: Component {
        id: keysMain
        KeysMainView {
            btnGenKey.onClicked: Global.applicationWindow.navigateTo("GenKey")
            btnExistingKey.onClicked: Global.applicationWindow.navigateTo("ExistingKey")
            btnKeycard.onClicked: Global.applicationWindow.navigateTo("KeycardFlowSelection")
        }
    }

    property var existingKeyComponent: Component {
        id: existingKey
        ExistingKeyView {
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
}
