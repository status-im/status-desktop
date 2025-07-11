import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Controls.Validators

import utils

import "../helpers"

Item {
    id: root

    property var sharedKeycardModule

    property string kcData: root.sharedKeycardModule.keycardData

    signal passwordValid(bool valid)

    onKcDataChanged: {
        d.updatePasswordValidation()
    }

    onStateChanged: {
        password.focus = true
    }

    Component.onCompleted: timer.start()

    Timer {
        id: timer
        interval: 1000
        onTriggered: {
            password.forceActiveFocus(Qt.MouseFocusReason)
        }
    }

    QtObject {
        id: d

        readonly property bool wrongPassword: root.kcData & Constants.predefinedKeycardData.wrongPassword

        function updatePasswordValidation() {
            root.passwordValid(password.text !== "" && !d.wrongPassword)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Theme.xlPadding
        anchors.bottomMargin: Theme.halfPadding
        anchors.leftMargin: Theme.xlPadding
        anchors.rightMargin: Theme.xlPadding
        spacing: Theme.padding

        KeycardImage {
            id: image
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Constants.keycard.shared.imageHeight
            Layout.preferredWidth: Constants.keycard.shared.imageWidth
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignCenter
            Layout.maximumWidth: parent.width
            font.weight: Font.Bold
        }

        StatusBaseText {
            id: message
            Layout.alignment: Qt.AlignCenter
            Layout.maximumWidth: parent.width
            wrapMode: Text.WordWrap
            visible: text != ""
        }

        StatusPasswordInput {
            id: password
            objectName: "keycardPasswordInput"
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width
            placeholderText: qsTr("Password")
            selectByMouse: true
            focus: true

            onTextChanged: {
                root.sharedKeycardModule.keycardData = ""
                root.sharedKeycardModule.setPassword(text)
                d.updatePasswordValidation()
            }

            onAccepted: {
                if (password.text !== "") {
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }
        }

        StatusBaseText {
            id: info
            Layout.alignment: Qt.AlignCenter
            Layout.maximumWidth: parent.width
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.enterPassword
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword
            PropertyChanges {
                target: image
                source: Theme.png("keycard/authenticate")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Enter your password")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: message
                text: ""
            }
            PropertyChanges {
                target: info
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.wrongPassword
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword
            PropertyChanges {
                target: image
                source: Theme.png("keycard/authenticate")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Enter your password")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: message
                text: ""
            }
            PropertyChanges {
                target: info
                text: d.wrongPassword? qsTr("Password incorrect") : ""
                color: Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.enterBiometricsPassword
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterBiometricsPassword
            PropertyChanges {
                target: image
                source: Theme.png("keycard/biometrics-success")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Stored password doesn't match")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: message
                text: qsTr("Enter your new password to proceed")
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: info
                text: d.wrongPassword? qsTr("Password incorrect") : ""
                color: Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.wrongBiometricsPassword
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongBiometricsPassword
            PropertyChanges {
                target: image
                source: Theme.png("keycard/biometrics-success")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Stored password doesn't match")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: message
                text: qsTr("Enter your new password to proceed")
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: info
                text: d.wrongPassword? qsTr("Password incorrect") : ""
                color: Theme.palette.dangerColor1
            }
        }
    ]
}
