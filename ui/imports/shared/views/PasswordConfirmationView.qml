import QtQuick 2.14
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

ColumnLayout {
    id: root

    required property string expectedPassword
    property bool passwordMatch

    signal submit()

    function forceInputFocus() {
        confPswInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    QtObject {
        id: d

        function updatePasswordMatch() {
            root.passwordMatch = confPswInput.text === root.expectedPassword
            if (!root.passwordMatch) {
                errorTxt.text = qsTr("Passwords don't match")
            }
        }
    }

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
        placeholderText: qsTr("Confirm your password (again)")
        echoMode: showPassword ? TextInput.Normal : TextInput.Password
        validator: RegExpValidator { regExp: /^[!-~]{0,64}$/ } // That incudes NOT extended ASCII printable characters less space and a maximum of 64 characters allowed
        rightPadding: showHideCurrentIcon.width + showHideCurrentIcon.anchors.rightMargin + Style.current.padding / 2
        onTextChanged: {
            errorTxt.text = ""
            d.updatePasswordMatch()
        }
        Keys.onReturnPressed: {
            root.submit()
        }

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
}
