import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.panels 1.0

import utils 1.0

import "../controls"
import "../panels"
import "../stores"


OnboardingBasePage {
    id: root
    anchors.fill: parent
    Behavior on opacity { NumberAnimation { duration: 200 }}
    state: "username"

    signal keysGenerated()

    function gotoKeysStack(stackIndex) { createKeysStack.currentIndex = stackIndex }

    enum KeysStack {
        DETAILS,
        CREATE_PWD,
        CONFRIM_PWD,
        TOUCH_ID
    }

    QtObject {
        id: d

        property string newPassword
        property string confirmationPassword
   }

    StackLayout {
        id: createKeysStack
        anchors.fill: parent
        currentIndex: GenKeyView.KeysStack.DETAILS

        onCurrentIndexChanged: {
            // Set focus:
            if(currentIndex === GenKeyView.KeysStack.CREATE_PWD)
            createPswView.forceNewPswInputFocus()
            else if(currentIndex === GenKeyView.KeysStack.CONFRIM_PWD)
                confirmPswView.forcePswInputFocus()
        }

        InsertDetailsView {
            id: userDetailsPanel
            onCreatePassword: { gotoKeysStack(GenKeyView.KeysStack.CREATE_PWD) }
        }
        CreatePasswordView {
            id: createPswView
            newPassword: d.newPassword
            confirmationPassword: d.confirmationPassword

            onExit: {
                d.newPassword = newPassword
                d.confirmationPassword = confirmationPassword
                gotoKeysStack(GenKeyView.KeysStack.CONFRIM_PWD)
            }
            onBackClicked: {
                d.newPassword = ""
                d.confirmationPassword = ""
                gotoKeysStack(GenKeyView.KeysStack.DETAILS)
            }
        }
        ConfirmPasswordView {
            id: confirmPswView
            password: d.newPassword
            displayName: userDetailsPanel.displayName
            onExit: {
                if (Qt.platform.os == "osx") {
                    gotoKeysStack(GenKeyView.KeysStack.TOUCH_ID);
                } else {
                    root.keysGenerated();
                }
            }
            onBackClicked: { gotoKeysStack(GenKeyView.KeysStack.CREATE_PWD) }
        }
        TouchIDAuthView {
            userPass: d.newPassword
            onBackClicked: { gotoKeysStack(GenKeyView.KeysStack.CONFRIM_PWD) }
            onGenKeysDone: { root.keysGenerated() }
        }
    }

    onBackClicked: {
        if (userDetailsPanel.state === "chatkey") {
            userDetailsPanel.state = "username";
        } else {
            root.exit();
        }
    }
}
