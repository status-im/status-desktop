import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Backpressure 0.1

import AppLayouts.Onboarding2.controls 1.0

import utils 1.0

KeycardBasePage {
    id: root

    property var tryToSetPinFunction: (pin) => { console.error("tryToSetPinFunction: IMPLEMENT ME"); return false }
    required property int remainingAttempts
    property bool unblockWithPukAvailable

    signal keycardPinEntered(string pin)
    signal reloadKeycardRequested
    signal unblockWithSeedphraseRequested
    signal unblockWithPukRequested
    signal keycardFactoryResetRequested

    image.source: Theme.png("onboarding/keycard/reading")

    QtObject {
        id: d
        property string tempPin
        property bool pinValid
    }

    buttons: [
        StatusPinInput {
            id: pinInput
            anchors.horizontalCenter: parent.horizontalCenter
            pinLen: Constants.keycard.general.keycardPinLength
            validator: StatusIntValidator { bottom: 0; top: 999999 }
            onPinInputChanged: {
                if (pinInput.pinInput.length === pinInput.pinLen) { // we have the full length PIN now
                    d.tempPin = pinInput.pinInput
                    d.pinValid = root.tryToSetPinFunction(d.tempPin)
                    if (!d.pinValid) {
                        pinInput.statesInitialization()
                    }
                }
            }
        },
        StatusBaseText {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("%n attempt(s) remaining", "", root.remainingAttempts)
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.dangerColor1
            visible: false
        },
        MaybeOutlineButton {
            id: btnUnblockWithPuk
            visible: false
            isOutline: false
            text: qsTr("Unblock using PUK")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.unblockWithPukRequested()
        },
        MaybeOutlineButton {
            id: btnUnblockWithSeedphrase
            visible: false
            isOutline: btnUnblockWithPuk.visible
            text: qsTr("Unblock with recovery phrase")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.unblockWithSeedphraseRequested()
        },
        MaybeOutlineButton {
            id: btnReload
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            text: qsTr("I've inserted a different Keycard")
            normalColor: "transparent"
            borderWidth: 1
            borderColor: Theme.palette.baseColor2
            onClicked: root.reloadKeycardRequested()
        }
    ]

    state: "entering"

    states: [
        State {
            name: "blocked"
            when: root.remainingAttempts <= 0
            PropertyChanges {
                target: root
                title: "<font color='%1'>".arg(Theme.palette.dangerColor1) + qsTr("Keycard blocked") + "</font>"
            }
            PropertyChanges {
                target: pinInput
                enabled: false
            }
            PropertyChanges {
                target: image
                source: Theme.png("onboarding/keycard/error")
            }
            PropertyChanges {
                target: btnUnblockWithSeedphrase
                visible: true
            }
            PropertyChanges {
                target: btnUnblockWithPuk
                visible: root.unblockWithPukAvailable
            }
            PropertyChanges {
                target: btnReload
                visible: true
            }
            StateChangeScript {
                script: {
                    Backpressure.debounce(root, 100, function() {
                        pinInput.clearPin()
                    })()
                }
            }
        },
        State {
            name: "incorrect"
            when: !!d.tempPin && !d.pinValid
            PropertyChanges {
                target: root
                title: qsTr("PIN incorrect")
            }
            PropertyChanges {
                target: errorText
                visible: true
            }
        },
        State {
            name: "success"
            when: d.pinValid
            PropertyChanges {
                target: root
                title: qsTr("PIN correct")
            }
            PropertyChanges {
                target: pinInput
                enabled: false
            }
            StateChangeScript {
                script: root.keycardPinEntered(pinInput.pinInput)
            }
        },
        State {
            name: "entering"
            PropertyChanges {
                target: root
                title: qsTr("Enter Keycard PIN")
            }
            StateChangeScript {
                script: {
                    pinInput.statesInitialization()
                    pinInput.forceFocus()
                    d.tempPin = ""
                    d.pinValid = false
                }
            }
        }
    ]
}
