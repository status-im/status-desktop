import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12

import shared.controls 1.0
import shared 1.0
import shared.panels 1.0
import shared.stores 1.0
import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../stores"
import "../controls"

Item {
    id: root

    property StartupStore startupStore

    property string password

    Component.onCompleted: {
        root.password = root.startupStore.getPassword()
        d.forcePasswordInputFocus()
    }

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

            root.startupStore.doPrimaryAction()
        }

        function forcePasswordInputFocus() { confPswInput.forceActiveFocus(Qt.MouseFocusReason) }
    }

    ColumnLayout {
        id: view
        spacing: Style.current.bigPadding
        height: 460
        anchors.centerIn: parent

        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Have you written down your password?")
            font.pixelSize: 22
            font.bold: true
            color: Theme.palette.directColor1
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("You will never be able to recover your password if you lose it.")
                font.pixelSize: 15
                color: Theme.palette.dangerColor1
            }

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("If you need to, write it using pen and paper and keep in a safe place.")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("If you lose your password you will lose access to your Status profile.")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }

        StatusPasswordInput {
            id: confPswInput

            property bool showPassword: false

            objectName: "confirmAgainPasswordInput"
            Layout.preferredWidth: 416
            Layout.alignment: Qt.AlignHCenter
            enabled: !submitBtn.loading
            placeholderText: qsTr("Confirm your password (again)")
            echoMode: showPassword ? TextInput.Normal : TextInput.Password
            validator: RegExpValidator { regExp: /^[!-~]{0,64}$/ } // That incudes NOT extended ASCII printable characters less space and a maximum of 64 characters allowed
            rightPadding: showHideCurrentIcon.width + showHideCurrentIcon.anchors.rightMargin + Style.current.padding / 2
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
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.topMargin: -Style.current.halfPadding
            font.pixelSize: 12
            color: Theme.palette.dangerColor1
        }

        StatusButton {
            id: submitBtn
            objectName: "confirmPswSubmitBtn"
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Finalise Status Password Creation")
            enabled: !submitBtn.loading && (confPswInput.text === root.password)

            onClicked: { d.submit() }
        }
    }

    Connections {
        target: RootStore.privacyModule
        onPasswordChanged: {
            if (success) {
                submitBtn.loading = false
                root.exit();
            }
        }
    }
}
