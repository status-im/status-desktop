import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.controls 1.0

import utils 1.0

KeycardBasePage {
    id: root

    signal keycardPinCreated(string pin)

    pageClassName: "KeycardCreatePinPage"
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
            text: qsTr("PINs don’t match")
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.dangerColor1
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
            name: "success"
            extend: "repeating"
            when: !!d.pin && !!d.pin2 && d.pin === d.pin2
            PropertyChanges {
                target: root
                title: qsTr("Keycard PIN set")
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
                    pinInput.setPin(d.pin)
                    root.keycardPinCreated(d.pin)
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
