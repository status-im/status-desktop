import QtQuick 2.3
import QtQml.StateMachine 1.14 as DSM
import QtQuick.Controls 2.3

Page {
    id: onboardingMain
    property string state
    anchors.fill: parent

    DSM.StateMachine {
        id: stateMachine
        initialState: showLogin ? stateLogin : stateIntro
        running: onboardingMain.visible

        DSM.State {
            id: stateIntro
            onEntered: intro.visible = true
            onExited: intro.visible = false

            DSM.SignalTransition {
                targetState: keysMainState
                signal: intro.btnGetStarted.clicked
            }
        }

        DSM.State {
            id: keysMainState
            onEntered: keysMain.visible = true
            onExited: keysMain.visible = false

            DSM.SignalTransition {
                targetState: existingKeyState
                signal: keysMain.btnExistingKey.clicked
            }

            DSM.SignalTransition {
                targetState: genKeyState
                signal: keysMain.btnGenKey.clicked
            }
        }

        DSM.State {
            id: existingKeyState
            onEntered: existingKey.visible = true
            onExited: existingKey.visible = false

            DSM.SignalTransition {
                targetState: appState
                signal: onboardingModel.loginResponseChanged
                guard: !error
            }
        }

        DSM.State {
            id: genKeyState
            onEntered: genKey.visible = true
            onExited: genKey.visible = false

            DSM.SignalTransition {
                targetState: appState
                signal: onboardingModel.loginResponseChanged
                guard: !error
            }

            DSM.SignalTransition {
                targetState: existingKeyState
                signal: genKey.btnExistingKey.clicked
            }
        }

        DSM.State {
            id: stateLogin
            onEntered: login.visible = true
            onExited: login.visible = false

            DSM.SignalTransition {
                targetState: appState
                signal: loginModel.loginResponseChanged
                guard: !error
            }

            DSM.SignalTransition {
                targetState: genKeyState
                signal: login.btnGenKey.clicked
            }
        }

        DSM.FinalState {
            id: appState
            onEntered: app.visible = true
            onExited: app.visible = false
        }
    }

    Intro {
        id: intro
        anchors.fill: parent
        visible: false
    }

    KeysMain {
        id: keysMain
        anchors.fill: parent
        visible: false
    }

    ExistingKey {
        id: existingKey
        anchors.fill: parent
        visible: false
    }

    GenKey {
        id: genKey
        anchors.fill: parent
        visible: false
    }

    Login {
        id: login
        anchors.fill: parent
        visible: false
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:770;width:1232}
}
##^##*/
