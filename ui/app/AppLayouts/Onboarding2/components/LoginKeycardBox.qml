import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding.enums 1.0
import AppLayouts.Onboarding2.controls 1.0

Control {
    id: root

    required property int keycardState
    property var tryToSetPinFunction: (pin) => { console.error("LoginKeycardBox::tryToSetPinFunction: IMPLEMENT ME"); return false }
    required property int keycardRemainingPinAttempts
    required property int keycardRemainingPukAttempts

    required property bool isBiometricsLogin
    required property bool biometricsSuccessful
    required property bool biometricsFailed
    signal biometricsRequested()

    signal pinEditedManually()

    signal unblockWithSeedphraseRequested()
    signal unblockWithPukRequested()
    signal keycardFactoryResetRequested()

    signal loginRequested(string pin)

    function clear() {
        d.wrongPin = false
        pinInputField.statesInitialization()
        pinInputField.forceFocus()
    }

    function setPin(pin: string) {
        pinInputField.setPin(pin)
    }

    padding: 12

    QtObject {
        id: d
        property bool wrongPin
    }

    background: Rectangle {
        color: "transparent"
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: Theme.radius
    }

    contentItem: ColumnLayout {
        spacing: 12
        LoginTouchIdIndicator {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.halfPadding
            id: touchIdIcon
            visible: false
            success: root.biometricsSuccessful
            error: root.biometricsFailed
            onClicked: root.biometricsRequested()
        }
        StatusBaseText {
            Layout.fillWidth: true
            id: infoText
            horizontalAlignment: Qt.AlignHCenter
            elide: Text.ElideRight
            color: Theme.palette.baseColor1
        }
        Column {
            id: lockedButtons
            Layout.fillWidth: true
            spacing: 12
            visible: false
            MaybeOutlineButton {
                width: parent.width
                visible: root.keycardState === Onboarding.KeycardState.BlockedPIN && root.keycardRemainingPukAttempts > 0
                text: qsTr("Unblock with PUK")
                onClicked: root.unblockWithPukRequested()
            }
            MaybeOutlineButton {
                width: parent.width
                visible: root.keycardState === Onboarding.KeycardState.BlockedPIN
                text: qsTr("Unblock with recovery phrase")
                onClicked: root.unblockWithSeedphraseRequested()
            }
            MaybeOutlineButton {
                width: parent.width
                visible: root.keycardState === Onboarding.KeycardState.BlockedPUK
                text: qsTr("Factory reset Keycard")
                onClicked: root.keycardFactoryResetRequested()
            }
        }
        StatusPinInput {
            Layout.alignment: Qt.AlignHCenter
            id: pinInputField
            objectName: "pinInput"
            validator: StatusIntValidator { bottom: 0; top: 999999 }
            visible: false

            onPinInputChanged: {
                if (pinInput.length === 6) {
                    if (root.tryToSetPinFunction(pinInput)) {
                        root.loginRequested(pinInput)
                        d.wrongPin = false
                    } else {
                        d.wrongPin = true
                        pinInputField.statesInitialization()
                        pinInputField.forceFocus()
                    }
                }
            }
            onPinEditedManually: {
                d.wrongPin = false
                root.pinEditedManually()
            }
        }
    }

    states: [
        // normal/intro states
        State {
            name: "plugin"
            when: root.keycardState === Onboarding.KeycardState.PluginReader ||
                  root.keycardState === -1
            PropertyChanges {
                target: infoText
                text: qsTr("Plug in Keycard reader...")
            }
        },
        State {
            name: "insert"
            when: root.keycardState === Onboarding.KeycardState.InsertKeycard
            PropertyChanges {
                target: infoText
                text: qsTr("Insert your Keycard...")
            }
        },
        State {
            name: "reading"
            when: root.keycardState === Onboarding.KeycardState.ReadingKeycard
            PropertyChanges {
                target: infoText
                text: qsTr("Reading Keycard...")
            }
        },
        // error states
        State {
            name: "notKeycard"
            when: root.keycardState === Onboarding.KeycardState.NotKeycard
            PropertyChanges {
                target: infoText
                color: Theme.palette.dangerColor1
                text: qsTr("Oops this isn’t a Keycard.<br>Remove card and insert a Keycard.")
            }
        },
        State {
            name: "wrongKeycard"
            when: root.keycardState === Onboarding.KeycardState.WrongKeycard ||
                  root.keycardState === Onboarding.KeycardState.MaxPairingSlotsReached
            PropertyChanges {
                target: infoText
                color: Theme.palette.dangerColor1
                text: qsTr("Wrong Keycard for this profile inserted.<br>Remove card and insert the correct one.")
            }
        },
        State {
            name: "noService"
            when: root.keycardState === Onboarding.KeycardState.NoPCSCService
            PropertyChanges {
                target: infoText
                color: Theme.palette.dangerColor1
                text: qsTr("Smartcard reader service unavailable")
            }
        },
        State {
            name: "blocked"
            when: root.keycardState === Onboarding.KeycardState.BlockedPIN ||
                  root.keycardState === Onboarding.KeycardState.BlockedPUK
            PropertyChanges {
                target: infoText
                color: Theme.palette.dangerColor1
                text: qsTr("Keycard blocked")
            }
            PropertyChanges {
                target: lockedButtons
                visible: true
            }
        },
        State {
            name: "empty"
            when: root.keycardState === Onboarding.KeycardState.Empty
            PropertyChanges {
                target: infoText
                color: Theme.palette.dangerColor1
                text: qsTr("The inserted Keycard is empty.<br>Remove card and insert the correct one.")
            }
        },
        State {
            name: "wrongPin"
            extend: "notEmpty"
            when: root.keycardState === Onboarding.KeycardState.NotEmpty && d.wrongPin
            PropertyChanges {
                target: infoText
                color: Theme.palette.dangerColor1
                text: qsTr("PIN incorrect. %n attempt(s) remaining.", "", root.keycardRemainingPinAttempts)
            }
        },
        // exit states
        State {
            name: "notEmpty"
            when: root.keycardState === Onboarding.KeycardState.NotEmpty && !d.wrongPin
            PropertyChanges {
                target: infoText
                text: qsTr("Enter Keycard PIN")
            }
            PropertyChanges {
                target: pinInputField
                visible: true
            }
            StateChangeScript {
                script: {
                    pinInputField.forceFocus()
                }
            }
            PropertyChanges {
                target: touchIdIcon
                visible: root.isBiometricsLogin
            }
        }
    ]
}
