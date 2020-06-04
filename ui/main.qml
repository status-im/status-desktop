import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQml.StateMachine 1.14 as DSM
import "./onboarding"
import "./app"

ApplicationWindow {
    id: applicationWindow
    width: 1232
    height: 770
    title: "Nim Status Client"
    visible: true
    font.family: "Inter"

    signal navigateTo(string path)

    SystemTrayIcon {
        visible: true
        icon.source: "shared/img/status-logo.png"
        menu: Menu {
            MenuItem {
                text: qsTr("Quit")
                onTriggered: Qt.quit()
            }
        }

        onActivated: {
            applicationWindow.show()
            applicationWindow.raise()
            applicationWindow.requestActivate()
        }
    }

    DSM.StateMachine {
        id: stateMachine
        initialState: onboardingState
        running: true

        DSM.State {
            id: onboardingState
            initialState: loginModel.rowCount() ? stateLogin : stateIntro

            DSM.State {
                id: stateIntro
                onEntered: loader.sourceComponent = intro

                DSM.SignalTransition {
                    targetState: keysMainState
                    signal: applicationWindow.navigateTo
                    guard: path === "KeysMain"
                }
            }

            DSM.State {
                id: keysMainState
                onEntered: loader.sourceComponent = keysMain

                DSM.SignalTransition {
                    targetState: existingKeyState
                    signal: applicationWindow.navigateTo
                    guard: path === "ExistingKey"
                }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: applicationWindow.navigateTo
                    guard: path === "GenKey"
                }
            }

            DSM.State {
                id: existingKeyState
                onEntered: loader.sourceComponent = existingKey

                DSM.SignalTransition {
                    targetState: appState
                    signal: onboardingModel.loginResponseChanged
                    guard: !error
                }
            }

            DSM.State {
                id: genKeyState
                onEntered: loader.sourceComponent = genKey

                DSM.SignalTransition {
                    targetState: appState
                    signal: onboardingModel.loginResponseChanged
                    guard: !error
                }

                DSM.SignalTransition {
                    targetState: existingKeyState
                    signal: applicationWindow.navigateTo
                    guard: path === "ExistingKey"
                }
            }

            DSM.State {
                id: stateLogin
                onEntered: loader.sourceComponent = login

                DSM.SignalTransition {
                    targetState: appState
                    signal: loginModel.loginResponseChanged
                    guard: !error
                }

                DSM.SignalTransition {
                    targetState: genKeyState
                    signal: applicationWindow.navigateTo
                    guard: path === "GenKey"
                }
            }

            DSM.FinalState {
                id: onboardingDoneState
            }
        }
        
        DSM.State {
            id: appState
            onEntered: loader.sourceComponent = app

            DSM.SignalTransition {
                targetState: stateLogin
                signal: loginModel.onLoggedOut
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Component {
        id: app
        AppMain {}
    }

    Component {
        id: intro
        Intro {
            btnGetStarted.onClicked: applicationWindow.navigateTo("KeysMain")
        }
    }

    Component {
        id: keysMain
        KeysMain {
            btnGenKey.onClicked: applicationWindow.navigateTo("GenKey")
            btnExistingKey.onClicked: applicationWindow.navigateTo("ExistingKey")
        }
    }

    Component {
        id: existingKey
        ExistingKey {}
    }

    Component {
        id: genKey
        GenKey {
            btnExistingKey.onClicked: applicationWindow.navigateTo("ExistingKey")
        }
    }

    Component {
        id: login
        Login {
            btnGenKey.onClicked: applicationWindow.navigateTo("GenKey")
        }
    }
}
