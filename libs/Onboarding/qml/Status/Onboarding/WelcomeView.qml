import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Containers

import "base"

OnboardingPageBase {
    id: root

    required property var onboardingController      // OnboardingController

    signal setupNewAccount()
    signal accountLoggedIn()

    backAvailable: false

    ColumnLayout {
        anchors {
            centerIn: parent
            verticalCenterOffset: -117
        }
        spacing: 10

        Label {
            text: qsTr("Welcome to Status")
        }

        LayoutSpacer {
            Layout.preferredHeight: 50
        }

        ColumnLayout {
            visible: accountsComboBox.count > 0
            ComboBox {
                id: accountsComboBox

                Layout.preferredWidth: 328
                Layout.preferredHeight: 44

                model: onboardingController.accounts
                textRole: "name"
                valueRole: "account"
            }

            TempTextInput {
                id: passwordInput
                Layout.preferredWidth: 328
                Layout.preferredHeight: 44

                // TODO: remove dev helper
                text: "1234567890"
                // END dev
            }

            Button {
                text: qsTr("Login")
                enabled: passwordInput.text.length >= 10
                onClicked: {
                    errorLabel.visible = false
                    onboardingController.login(accountsComboBox.currentValue, passwordInput.text)
                }
            }
            Label {
                id: errorLabel
                text: qsTr("Failed logging in")
                visible: false
                color: "red"
            }
        }

        Button {
            text: qsTr("I am new to Status")
            onClicked: root.setupNewAccount()
        }
    }

    Connections {
        target: onboardingController

        function onAccountLoggedIn() {
            root.accountLoggedIn()
        }
        function onAccountLoginError(error) {
            console.warn(`Error logging in "${error}"`)
            errorLabel.visible = true
        }
    }
}
