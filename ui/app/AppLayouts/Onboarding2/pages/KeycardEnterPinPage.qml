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

    required property string existingPin
    required property int remainingAttempts

    signal keycardPinEntered(string pin)
    signal reloadKeycardRequested()
    signal keycardFactoryResetRequested()
    signal keycardLocked()

    image.source: Theme.png("onboarding/keycard/reading")

    QtObject {
        id: d
        property string tempPin
        property int remainingAttempts: root.remainingAttempts
    }

    buttons: [
        StatusPinInput {
            id: pinInput
            anchors.horizontalCenter: parent.horizontalCenter
            validator: StatusIntValidator { bottom: 0; top: 999999 }
            onPinInputChanged: {
                if (pinInput.pinInput.length === pinInput.pinLen) {
                    d.tempPin = pinInput.pinInput
                    if (d.tempPin !== root.existingPin) {
                        pinInput.statesInitialization()
                        d.remainingAttempts--
                    }
                }
            }
        },
        StatusBaseText {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("%n attempt(s) remaining", "", d.remainingAttempts)
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.dangerColor1
            visible: false
        },
        StatusButton {
            id: btnFactoryReset
            width: 320
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.halfPadding
            visible: false
            text: qsTr("Factory reset Keycard")
            onClicked: root.keycardFactoryResetRequested()
        },
        StatusButton {
            id: btnReload
            width: 320
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            text: qsTr("I’ve inserted a Keycard")
            normalColor: "transparent"
            borderWidth: 1
            borderColor: Theme.palette.baseColor2
            onClicked: root.reloadKeycardRequested()
        }
    ]

    state: "entering"

    states: [
        State {
            name: "locked"
            when: d.remainingAttempts <= 0
            PropertyChanges {
                target: root
                title: "<font color='%1'>".arg(Theme.palette.dangerColor1) + qsTr("Keycard locked") + "</font>"
            }
            PropertyChanges {
                target: pinInput
                enabled: false
            }
            PropertyChanges {
                target: root
                image.source: Theme.png("onboarding/keycard/error")
            }
            PropertyChanges {
                target: btnFactoryReset
                visible: true
            }
            PropertyChanges {
                target: btnReload
                visible: true
            }
            StateChangeScript {
                script: {
                    pinInput.clearPin()
                    root.keycardLocked()
                }
            }
        },
        State {
            name: "incorrect"
            when: !!d.tempPin && d.tempPin !== root.existingPin
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
            when: pinInput.pinInput === root.existingPin
            PropertyChanges {
                target: root
                title: qsTr("PIN correct")
            }
            PropertyChanges {
                target: pinInput
                enabled: false
            }
            StateChangeScript {
                script: {
                    root.keycardPinEntered(pinInput.pinInput)
                }
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
                    d.remainingAttempts = root.remainingAttempts
                }
            }
        }
    ]
}
