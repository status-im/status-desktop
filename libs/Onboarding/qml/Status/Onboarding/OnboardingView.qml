import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QtQml

import Qt.labs.platform

import Status.Containers
import Status.Controls.Navigation
import Status.Onboarding
import Status.ApplicationCore

/** \brief Drives the onboarding workflow
 *
 */
Item {
    id: root

    signal userLoggedIn()

    implicitWidth: 1232
    implicitHeight: 770

    UserConfiguration {
        id: userConfiguration
    }

    OnboardingModule {
        id: onboardingModule

        userDataPath: userConfiguration.userDataFolder
    }

    MacTrafficLights {
        anchors.left: parent.left
        anchors.margins: 13
        anchors.top: parent.top
        z: stackView.z + 1
    }

    StackView {
        id: stackView

        anchors.fill: parent

        initialItem: WelcomeView {
            onboardingController: onboardingModule.controller
            onSetupNewAccount: stackView.push(setupNewProfileViewComponent)
            onAccountLoggedIn: root.userLoggedIn()
        }
    }

    Component {
        id: setupNewProfileViewComponent

        SetupNewProfileView {
            onAbortAccountCreation: stackView.pop()
            onUserLoggedIn: root.userLoggedIn()

            newAccountController: onboardingModule.controller.initNewAccountController()
            Component.onDestruction: onboardingModule.controller.terminateNewAccountController()
        }
    }
}
