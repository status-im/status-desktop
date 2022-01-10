import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12


import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls 1.0

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

StatusModal {
    id: root

    signal passwordChanged()

    width: 480
    height: 510
    closePolicy: Popup.NoAutoClose
    header.title: qsTr("Change password")

    onOpened: d.reset()

    QtObject {
        id: d

        function lengthValidator(text) {
            return text.length >= 6 ? "" : qsTr("At least 6 characters")
        }

        function reset() {
            currentPasswordInput.state = "init"
            passwordInput.state = "init"
            confirmPasswordInput.state = "init"
            currentPasswordInput.forceActiveFocus(Qt.MouseFocusReason)
        }
    }

    contentItem: ColumnLayout {
        id: contentItem
        anchors.fill: parent
        anchors {
            topMargin: Style.current.xlPadding + root.topPadding
            leftMargin: Style.current.xlPadding
            rightMargin: Style.current.xlPadding
            bottomMargin: Style.current.xlPadding + root.bottomPadding
        }
        spacing: Style.current.padding

        // TODO replace with StatusInput as soon as it supports password
        Input {
            id: currentPasswordInput

            readonly property bool ready: state == "typing" && validationError == ""

            anchors.left: undefined
            anchors.right: undefined
            Layout.fillWidth: true
            label: qsTr("Current password")

            textField.echoMode: TextInput.Password
            keepHeight: true
            placeholderText: ""
            state: "init"

            onTextChanged: if (text != "" && state != "typing") state = "typing"
            onStateChanged: if (state == "init") resetInternal()

            states: [
                State {
                    name: "init"
                },
                State {
                    name: "typing"
                    PropertyChanges { target: currentPasswordInput; validationError: d.lengthValidator(text) }
                },
                State {
                    name: "incorrect"
                    PropertyChanges { target: currentPasswordInput; validationError: qsTr("Incorrect password") }
                }
            ]
        }

        // TODO replace with StatusInput as soon as it supports password
        Input {
            id: passwordInput

            readonly property bool ready: state == "typing" && validationError == ""

            anchors.left: undefined
            anchors.right: undefined
            Layout.fillWidth: true
            label: qsTr("New password")

            textField.echoMode: TextInput.Password
            keepHeight: true
            placeholderText: ""
            state: "init"

            onTextChanged: if (text != "" && state != "typing") state = "typing"
            onStateChanged: if (state == "init") resetInternal()

            states: [
                State {
                    name: "init"
                },
                State {
                    name: "typing"
                    PropertyChanges { target: passwordInput; validationError: d.lengthValidator(text) }
                }
            ]
        }

        // TODO replace with StatusInput as soon as it supports password
        Input {
            id: confirmPasswordInput

            readonly property bool ready: state == "typing" && validationError == ""

            anchors.left: undefined
            anchors.right: undefined
            Layout.fillWidth: true
            label: qsTr("Confirm new password")

            textField.echoMode: TextInput.Password
            keepHeight: true
            placeholderText: ""
            state: "init"

            onTextChanged: if (text != "" && state != "typing") state = "typing"
            onStateChanged: if (state == "init") resetInternal()

            states: [
                State {
                    name: "init"
                },
                State {
                    name: "typing"
                    PropertyChanges {
                        target: confirmPasswordInput;
                        validationError: confirmPasswordInput.text != passwordInput.text ? qsTr("Password does not match") : ""
                    }
                }
            ]
        }

        Item {
            Layout.fillHeight: true
        }

        StyledText {
            text: qsTr("Your password protects your keys. You need it to unlock Status and transact.")
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 340
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            color: Style.current.secondaryText
            font.pixelSize: Style.current.tertiaryTextFontSize
        }
    }

    rightButtons: [
        StatusButton {
            id: submitBtn

            text: qsTr("Change password")
            enabled: !submitBtn.loading && currentPasswordInput.ready &&
                     passwordInput.ready && confirmPasswordInput.ready

            property Timer sim: Timer {
                id: pause
                interval: 20
                onTriggered: {
                    submitBtn.changePasswordBegin();
                }
            }

            onClicked: {
                submitBtn.loading = true;
                //changePassword operation blocks the UI so loading = true; will never
                //have any affect until changePassword is done. Getting around it with a
                //small pause (timer) in order to get the desired behavior
                pause.start();
            }

            function changePasswordBegin() {
                if (privacyModule.changePassword(currentPasswordInput.text, passwordInput.text)) {
                    passwordChanged()
                    submitBtn.enabled = false;
                } else {
                    currentPasswordInput.state = "incorrect"
                    currentPasswordInput.forceActiveFocus(Qt.MouseFocusReason)
                }
                submitBtn.loading = false;
            }
        }
    ]
}
