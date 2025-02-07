import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.controls 1.0
import AppLayouts.Onboarding.enums 1.0

import utils 1.0

KeycardBasePage {
    id: root

    required property int authorizationState
    required property int remainingAttempts
    required property bool unblockWithPukAvailable

    signal authorizationRequested(string pin)
    signal unblockWithSeedphraseRequested
    signal unblockWithPukRequested
    signal keycardFactoryResetRequested

    QtObject {
        id: d
        property string tempPin
    }

    StateGroup {
        //state: "entering"

        states: [
            State {
                name: "entering"
                when: root.authorizationState === Onboarding.ProgressState.Idle
                      && root.remainingAttempts > 0

                PropertyChanges {
                    target: root
                    title: qsTr("Enter Keycard PIN")
                }
                StateChangeScript {
                    script: {
                        pinInput.statesInitialization()
                        pinInput.forceFocus()
                    }
                }

                PropertyChanges {
                    target: image
                    source: Theme.png("onboarding/keycard/reading")
                }
            },
            State {
                name: "incorrect"
                when: root.authorizationState === Onboarding.ProgressState.Failed
                      && root.remainingAttempts > 0

                PropertyChanges {
                    target: root
                    title: qsTr("PIN incorrect")
                }
                PropertyChanges {
                    target: errorText
                    visible: true
                }
                StateChangeScript {
                    script: {
                        Backpressure.debounce(root, 100, function() {
                            pinInput.clearPin()
                        })()
                    }
                }
                PropertyChanges {
                    target: image
                    source: Theme.png("onboarding/keycard/error")
                }
            },
            State {
                name: "authorizing"
                when: root.authorizationState === Onboarding.ProgressState.InProgress
                      && root.remainingAttempts > 0

                PropertyChanges {
                    target: root
                    title: qsTr("Authorizing")
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
                    target: image
                    source: Theme.png("onboarding/keycard/reading")
                }
            },
            State {
                name: "pinSuccess"
                when: root.authorizationState === Onboarding.ProgressState.Success
                      && root.remainingAttempts > 0

                PropertyChanges {
                    target: root
                    title: qsTr("PIN correct")
                }
                PropertyChanges {
                    target: pinInput
                    enabled: false
                }

                PropertyChanges {
                    target: image
                    source: Theme.png("onboarding/keycard/success")
                }
            },
            State {
                name: "blocked"
                when: root.remainingAttempts <= 0

                PropertyChanges {
                    target: root

                    title: `<font color='${Theme.palette.dangerColor1}'>`
                           + `${qsTr("Keycard blocked")}</font>`
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
                StateChangeScript {
                    script: {
                        Backpressure.debounce(root, 100, function() {
                            pinInput.clearPin()
                        })()
                    }
                }
            }
        ]
    }

    buttons: [
        StatusPinInput {
            id: pinInput

            anchors.horizontalCenter: parent.horizontalCenter
            pinLen: Constants.keycard.general.keycardPinLength
            validator: StatusIntValidator { bottom: 0; top: 999999 }
            onPinInputChanged: {
                if (pinInput.pinInput.length === pinInput.pinLen)
                    root.authorizationRequested(pinInput.pinInput)
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
        StatusBaseText {
            id: errorExportingText

            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Error exporting the keys, please try again")
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.dangerColor1
            visible: false
        },
        StatusLoadingIndicator {
            id: loadingIndicator

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.halfPadding
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
        }
    ]
}
