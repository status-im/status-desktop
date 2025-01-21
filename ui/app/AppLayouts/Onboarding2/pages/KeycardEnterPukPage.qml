import QtQuick 2.15

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

    property var tryToSetPukFunction: (puk) => { console.error("tryToSetPukFunction: IMPLEMENT ME"); return false }
    required property int remainingAttempts

    signal keycardPukEntered(string puk)
    signal keycardFactoryResetRequested()

    image.source: Theme.png("onboarding/keycard/reading")

    QtObject {
        id: d
        readonly property int pukLen: Constants.keycard.general.keycardPukLength
        property string tempPuk
        property bool pukValid
    }

    buttons: [
        StatusPinInput {
            id: pukInput
            anchors.horizontalCenter: parent.horizontalCenter
            validator: StatusRegularExpressionValidator { regularExpression: new RegExp(`\\d{${d.pukLen}}`) }
            pinLen: d.pukLen
            additionalSpacingOnEveryNItems: 4
            additionalSpacing: Theme.xlPadding
            onPinInputChanged: {
                if (pinInput.length === pinLen) { // we have the full length PUK now
                    d.tempPuk = pinInput
                    d.pukValid = root.tryToSetPukFunction(d.tempPuk)
                    if (!d.pukValid) {
                        pukInput.statesInitialization()
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
        StatusButton {
            id: btnFactoryReset
            width: 320
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.halfPadding
            visible: false
            text: qsTr("Factory reset Keycard")
            onClicked: root.keycardFactoryResetRequested()
        }
    ]

    state: "entering"

    states: [
        State {
            name: "locked"
            when: root.remainingAttempts <= 0
            PropertyChanges {
                target: root
                title: "<font color='%1'>".arg(Theme.palette.dangerColor1) + qsTr("Keycard locked") + "</font>"
            }
            PropertyChanges {
                target: pukInput
                enabled: false
            }
            PropertyChanges {
                target: image
                source: Theme.png("onboarding/keycard/error")
            }
            PropertyChanges {
                target: btnFactoryReset
                visible: true
            }
            StateChangeScript {
                script: {
                    Backpressure.debounce(root, 100, function() {
                        pukInput.clearPin()
                    })()
                }
            }
        },
        State {
            name: "incorrect"
            when: !!d.tempPuk && !d.pukValid
            PropertyChanges {
                target: root
                title: qsTr("PUK incorrect")
            }
            PropertyChanges {
                target: errorText
                visible: true
            }
        },
        State {
            name: "success"
            when: d.pukValid
            PropertyChanges {
                target: root
                title: qsTr("PUK correct")
            }
            PropertyChanges {
                target: pukInput
                enabled: false
            }
            StateChangeScript {
                script: root.keycardPukEntered(pukInput.pinInput)
            }
        },
        State {
            name: "entering"
            PropertyChanges {
                target: root
                title: qsTr("Enter Keycard PUK")
            }
            StateChangeScript {
                script: {
                    pukInput.statesInitialization()
                    pukInput.forceFocus()
                    d.tempPuk = ""
                    d.pukValid = false
                }
            }
        }
    ]
}
