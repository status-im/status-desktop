import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../stores"
import "../controls"

OnboardingBasePage {
    id: root

    property string password
    property string tmpPass
    property string displayName
    function forcePswInputFocus() { confPswInput.forceActiveFocus(Qt.MouseFocusReason)}

    QtObject {
        id: d

        function checkPasswordMatches() {
            if (confPswInput.text !== root.password) {
                errorTxt.text = qsTr("Passwords don't match")
                return false
            }
            return true
        }

        function submit() {
            if (!checkPasswordMatches()) {
                return
            }

            if (OnboardingStore.accountCreated) {
                if (root.password !== root.tmpPass) {
                    OnboardingStore.changePassword(root.tmpPass, root.password)
                    root.tmpPass = root.password
                }
                else {
                    submitBtn.loading = false
                    root.exit();
                }
            }
            else {
                root.tmpPass = root.password
                submitBtn.loading = true
                OnboardingStore.setCurrentAccountAndDisplayName(root.displayName)
                pause.start()
            }
        }
    }

    Column {
        id: view
        spacing: 4 * Style.current.padding
        width: 416
        anchors.centerIn: parent

        StatusBaseText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Have you written down your password?")
            font.pixelSize: 22
            font.bold: true
            color: Theme.palette.directColor1
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.current.padding

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("You will never be able to recover your password if you lose it.")
                font.pixelSize: 15
                color: Theme.palette.dangerColor1
            }

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("If you need to, write it using pen and paper and keep in a safe place.")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("If you lose your password you will lose access to your Status profile.")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.current.padding
            width: parent.width

            // TODO replace with StatusInput as soon as it supports password
            Input {
                id: confPswInput

                property bool showPassword: false

                width: parent.width
                enabled: !submitBtn.loading
                placeholderText: qsTr("Confirm your password (again)")
                textField.echoMode: showPassword ? TextInput.Normal : TextInput.Password
                textField.validator: RegExpValidator { regExp: /^[!-~]{0,64}$/ } // That incudes NOT extended ASCII printable characters less space and a maximum of 64 characters allowed
                keepHeight: true
                textField.rightPadding: showHideCurrentIcon.width + showHideCurrentIcon.anchors.rightMargin + Style.current.padding / 2
                onTextChanged: { errorTxt.text = "" }
                Keys.onReturnPressed: { if(submitBtn.enabled) d.submit()}

                StatusFlatRoundButton {
                    id: showHideCurrentIcon
                    visible: confPswInput.text !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    width: 24
                    height: 24
                    icon.name: confPswInput.showPassword ? "hide" : "show"
                    icon.color: Theme.palette.baseColor1

                    onClicked: confPswInput.showPassword = !confPswInput.showPassword
                }
            }

            StatusBaseText {
                id: errorTxt
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 12
                color: Theme.palette.dangerColor1
                onTextChanged: {
                    if(text === "") filler.visible = true
                    else filler.visible = false
                }
            }
        }

        // Just a column filler to fit the design
        Item {
            height: Style.current.padding
            width: parent.width
        }

        StatusButton {
            id: submitBtn
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Finalise Status Password Creation")
            enabled: !submitBtn.loading && (confPswInput.text === root.password)

            property Timer sim: Timer {
                id: pause
                interval: 20
                onTriggered: {
                    // Create account operation blocks the UI so loading = true; will never have any affect until it is done.
                    // Getting around it with a small pause (timer) in order to get the desired behavior
                    OnboardingStore.finishCreatingAccount(root.password)
                }
            }

            onClicked: { d.submit() }

            Connections {
                target: onboardingModule
                onAccountSetupError: {
                    if (error === Constants.existingAccountError) {
                        importLoginError.title = qsTr("Keys for this account already exist")
                        importLoginError.text = qsTr("Keys for this account already exist and can't be added again. If you've lost your password, passcode or Keycard, uninstall the app, reinstall and access your keys by entering your seed phrase")
                    } else {
                        importLoginError.title = qsTr("Login failed")
                        importLoginError.text = qsTr("Login failed. Please re-enter your password and try again.")
                    }
                    importLoginError.open()
                }
            }

            MessageDialog {
                id: importLoginError
                title: qsTr("Login failed")
                text: qsTr("Login failed. Please re-enter your password and try again.")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
                onVisibilityChanged: {
                    submitBtn.loading = false
                }
            }
        }
    }

    // Back button:
    StatusRoundButton {
        enabled: !submitBtn.loading
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        icon.name: "arrow-left"
        onClicked: { root.backClicked() }
    }

    Connections {
        target: startupModule
        onAppStateChanged: {
            if (state === Constants.appState.main) {
                if (!!OnboardingStore.profImgUrl) {
                    OnboardingStore.saveImage();
                    OnboardingStore.accountCreated = true;
                }
                submitBtn.loading = false
                root.exit()
            }
        }
    }

    Connections {
        target: OnboardingStore.privacyModule
        onPasswordChanged: {
            if (success) {
                submitBtn.loading = false
                root.exit();
            }
        }
    }
}
