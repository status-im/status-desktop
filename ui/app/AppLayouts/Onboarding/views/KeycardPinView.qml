import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import shared.popups.keycard.helpers 1.0

import utils 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    property int remainingAttempts: root.startupStore.startupModuleInst.remainingAttempts

    onRemainingAttemptsChanged: {
        if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardWrongPin) {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }
    }

    onStateChanged: {
        if(state === Constants.startupState.keycardPinSet) {
            pinInputField.setPin("123456") // we are free to set fake pin in this case
        } else {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }
    }

    Timer {
        id: timer
        interval: 1000
        running: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardPinSet
        onTriggered: {
            root.startupStore.doPrimaryAction()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        height: Constants.onboarding.loginHeight
        spacing: Style.current.bigPadding

        KeycardImage {
            id: image
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Constants.keycard.general.imageHeight
            Layout.preferredWidth: Constants.keycard.general.imageWidth
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Bold
            font.pixelSize: Constants.keycard.general.fontSize1
            color: Theme.palette.directColor1
        }

        StatusPinInput {
            id: pinInputField
            Layout.alignment: Qt.AlignHCenter
            validator: StatusIntValidator{bottom: 0; top: 999999;}
            pinLen: Constants.keycard.general.keycardPinLength
            enabled: root.startupStore.currentStartupState.stateType !== Constants.startupState.keycardPinSet

            onPinInputChanged: {
                if (root.state !== Constants.startupState.keycardWrongPin) {
                    image.source = Style.png("keycard/enter-pin-%1".arg(pinInput.length))
                }
                if(pinInput.length == 0)
                    return
                if(root.state === Constants.startupState.keycardCreatePin ||
                        root.state === Constants.startupState.keycardEnterPin ||
                        root.state === Constants.startupState.keycardWrongPin) {
                    root.startupStore.setPin(pinInput)
                    root.startupStore.doPrimaryAction()
                }
                else if(root.state === Constants.startupState.keycardRepeatPin) {
                    let pinsMatch = root.startupStore.checkRepeatedKeycardPinWhileTyping(pinInput)
                    if (pinsMatch) {
                        info.text = qsTr("It is very important that you do not lose this PIN")
                        root.startupStore.doPrimaryAction()
                    } else {
                        info.text = qsTr("PINs don't match")
                        image.source = Style.png("keycard/plain-error")
                    }
                }
            }
        }

        StatusBaseText {
            id: info
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Constants.keycard.general.fontSize3
            wrapMode: Text.WordWrap
        }

        StatusBaseText {
            id: message
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Constants.keycard.general.fontSize3
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    states: [
        State {
            name: Constants.startupState.keycardCreatePin
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardCreatePin
            PropertyChanges {
                target: image
                source: Style.png("keycard/enter-pin-0")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Create new Keycard PIN")
            }
            PropertyChanges {
                target: info
                text: qsTr("It is very important that you do not lose this PIN")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardRepeatPin
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardRepeatPin
            PropertyChanges {
                target: image
                source: Style.png("keycard/enter-pin-0")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Repeat Keycard PIN")
            }
            PropertyChanges {
                target: info
                text: qsTr("It is very important that you do not lose this PIN")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardPinSet
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardPinSet
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongSuccess.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongSuccess.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongSuccess.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongSuccess.endImgIndex
                duration: Constants.keycardAnimations.strongSuccess.duration
                loops: Constants.keycardAnimations.strongSuccess.loops
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard PIN set")
            }
            PropertyChanges {
                target: info
                text: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardEnterPin
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardEnterPin
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-empty")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Enter Keycard PIN")
            }
            PropertyChanges {
                target: info
                text: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardWrongPin
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardWrongPin
            PropertyChanges {
                target: image
                source: Style.png("keycard/plain-error")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Enter Keycard PIN")
            }
            PropertyChanges {
                target: info
                text: qsTr("PIN incorrect")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                text: qsTr("%n attempt(s) remaining", "", root.remainingAttempts)
                color: root.remainingAttempts === 1?
                           Theme.palette.dangerColor1 :
                           Theme.palette.baseColor1
            }
        }
    ]
}
