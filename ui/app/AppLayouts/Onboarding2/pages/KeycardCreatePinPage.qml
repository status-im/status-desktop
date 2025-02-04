import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Backpressure 0.1

import AppLayouts.Onboarding2.controls 1.0
import AppLayouts.Onboarding.enums 1.0

import utils 1.0

KeycardBasePage {
    id: root

    property int keycardPinInfoPageDelay: 1000
    required property int pinSettingState
    required property int authorizationState

    signal keycardPinCreated(string pin)
    signal keycardPinSuccessfullySet()
    signal keycardAuthorized()

    image.source: Theme.png("onboarding/keycard/reading")

    QtObject {
        id: d
        property string pin
        property string pin2

        function setPins() {
            if (pinInput.valid) {
                if (root.state === "creating")
                    d.pin = pinInput.pinInput
                else if (root.state === "repeating" || root.state === "mismatch")
                    d.pin2 = pinInput.pinInput

                if (root.state === "mismatch")
                    pinInput.statesInitialization()
            }
        }
    }

    buttons: [
        StatusPinInput {
            id: pinInput
            anchors.horizontalCenter: parent.horizontalCenter
            validator: StatusIntValidator { bottom: 0; top: 999999 }
            Component.onCompleted: {
                statesInitialization()
                forceFocus()
            }
            onPinInputChanged: {
                Qt.callLater(d.setPins)
            }
        },
        StatusBaseText {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("PINs don't match")
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.dangerColor1
            visible: false
        },
        StatusLoadingIndicator {
            id: loadingIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.halfPadding
            visible: false
        }
    ]

    state: "creating"

    states: [
        State {
            name: "creating"
            PropertyChanges {
                target: root
                title: qsTr("Create new Keycard PIN")
            }
        },
        State {
            name: "mismatch"
            extend: "repeating"
            when: !!d.pin && !!d.pin2 && d.pin !== d.pin2
            PropertyChanges {
                target: errorText
                visible: true
            }
            PropertyChanges {
                target: root
                image.source: Theme.png("onboarding/keycard/error")
            }
        },
        State {
            name: "error"
            when: root.pinSettingState === Onboarding.ProgressState.Failed || root.authorizationState === Onboarding.ProgressState.Failed
            PropertyChanges {
                target: errorText
                visible: true
                text: qsTr("Error setting pin")
            }
            PropertyChanges {
                target: root
                image.source: Theme.png("onboarding/keycard/error")
            }
        },
        State {
            name: "authorized"
            when: root.authorizationState === Onboarding.ProgressState.Success
            PropertyChanges {
                target: root
                title: qsTr("PIN set")
            }
            PropertyChanges {
                target: pinInput
                enabled: false
            }
            PropertyChanges {
                target: root
                image.source: Theme.png("onboarding/keycard/success")
            }
            StateChangeScript {
                script: {
                    Backpressure.debounce(root, keycardPinInfoPageDelay, function() {
                        root.keycardAuthorized()
                    })()
                }
            }
        },
        State {
            name: "success"
            when: root.pinSettingState === Onboarding.ProgressState.Success
            PropertyChanges {
                target: root
                title: qsTr("PIN set")
            }
            PropertyChanges {
                target: pinInput
                enabled: false
            }
            PropertyChanges {
                target: root
                image.source: Theme.png("onboarding/keycard/success")
            }
            StateChangeScript {
                script: {
                    root.keycardPinSuccessfullySet()
                }
            }
        },
        State {
            name: "settingPin"
            extend: "repeating"
            when: !!d.pin && !!d.pin2 && d.pin === d.pin2 && (root.pinSettingState === Onboarding.ProgressState.Idle || root.pinSettingState === Onboarding.ProgressState.InProgress)
            PropertyChanges {
                target: root
                title: qsTr("Setting Keycard PIN")
            }
            PropertyChanges {
                target: pinInput
                enabled: false
            }
            PropertyChanges {
                target: loadingIndicator
                visible: true
            }
            PropertyChanges {
                target: root
                image.source: Theme.png("onboarding/keycard/success")
            }
            StateChangeScript {
                script: {
                    Backpressure.debounce(root, keycardPinInfoPageDelay, function() {
                        pinInput.setPin(d.pin)
                        root.keycardPinCreated(d.pin)
                    })()
                }
            }
        },
        State {
            name: "repeating"
            when: d.pin !== ""
            PropertyChanges {
                target: root
                title: qsTr("Repeat Keycard PIN")
            }
            StateChangeScript {
                script: {
                    pinInput.statesInitialization()
                }
            }
        }
    ]
}
