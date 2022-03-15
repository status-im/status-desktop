import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12

import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../stores"

Page {
    id: root

    property string password

    signal backClicked()

    anchors.fill: parent

    Component.onCompleted: confPswInput.forceActiveFocus(Qt.MouseFocusReason)

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
                font.pixelSize: 12
                color: Theme.palette.dangerColor1
            }

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("If you need to, write it using pen and paper and keep in a safe place.")
                font.pixelSize: 12
                color: Theme.palette.baseColor1
            }

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("If you lose your password you will lose access to  your Status profile.")
                font.pixelSize: 12
                color: Theme.palette.baseColor1
            }
        }

        // TODO replace with StatusInput as soon as it supports password
        Input {
            id: confPswInput

            property bool showPassword: false

            width: parent.width
            enabled: !submitBtn.loading
            placeholderText: submitBtn.loading ?
                             qsTr("Connecting...") :
                             qsTr("Confirm you password (again)")
            textField.echoMode: showPassword ? TextInput.Normal : TextInput.Password
            textField.validator: RegExpValidator { regExp: /^[!-~]+$/ } // That incudes NOT extended ASCII printable characters less space
            keepHeight: true
            textField.rightPadding: showHideCurrentIcon.width + showHideCurrentIcon.anchors.rightMargin + Style.current.padding / 2

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

        // Just a column filler to fit the design
        Item {
            height: Style.current.padding
            width: parent.width
        }

        StatusButton {
            id: submitBtn
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Finalize Status Password Creation")
            enabled: !submitBtn.loading && confPswInput.text === root.password

            property Timer sim: Timer {
                id: pause
                interval: 20
                onTriggered: {
                    // Create new password call action to the backend
                    OnboardingStore.onBoardingModul.storeSelectedAccountAndLogin(root.password)
                    Global.applicationWindow.prepareForStoring(root.password, false)
                }
            }

            onClicked: {
                confPswInput.text = ""
                submitBtn.loading = true
                // Create password operation blocks the UI so loading = true; will never have any affect until changePassword/createPassword is done.
                // Getting around it with a small pause (timer) in order to get the desired behavior
                pause.start()
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
}
