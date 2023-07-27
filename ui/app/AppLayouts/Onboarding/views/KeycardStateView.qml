import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import shared.popups.keycard.helpers 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

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
        }

        StatusBaseText {
            id: info
            visible: text.length > 0
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        StatusButton {
            id: button
            visible: text.length > 0
            Layout.alignment: Qt.AlignHCenter
            focus: true
            onClicked: {
                root.startupStore.doPrimaryAction()
            }
        }

        StatusBaseText {
            id: link
            visible: text.length > 0
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Constants.keycard.general.buttonFontSize
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    parent.font.underline = true
                }
                onExited: {
                    parent.font.underline = false
                }
                onClicked: {
                    root.startupStore.doSecondaryAction()
                }
            }
        }

        StatusBaseText {
            id: message
            visible: text.length > 0
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    states: [
        State {
            name: Constants.startupState.keycardNotEmpty
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardNotEmpty
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("This Keycard already stores keys")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: qsTr("To generate new keys, you will need to perform a factory reset first")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
            PropertyChanges {
                target: button
                text: qsTr("Factory reset")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: ""
            }
            PropertyChanges {
                target: message
                text: qsTr("Or remove Keycard and insert another Keycard and try again")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
        },
        State {
            name: Constants.startupState.keycardEmpty
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardEmpty
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-empty")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard is empty")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: qsTr("There is no key pair on this Keycard")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
            PropertyChanges {
                target: button
                text: qsTr("Generate new keys for this Keycard")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardLocked
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardLocked
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked and already stores keys")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: qsTr("The Keycard you have inserted is locked, you will need to factory reset it before proceeding")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
            PropertyChanges {
                target: button
                text: qsTr("Factory reset")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: ""
            }
            PropertyChanges {
                target: message
                text: qsTr("Or remove Keycard and insert another Keycard and try again")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
        },
        State {
            name: Constants.startupState.keycardNoPCSCService
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardNoPCSCService
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: title
                text: qsTr("PCSC not available")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: qsTr("The Smartcard reader (PCSC service), required\nfor using Keycard, is not currently working.\nEnsure PCSC is installed and running and try again")
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: button
                text: qsTr("Retry")
            }
            PropertyChanges {
                target: link
                text: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardNotKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardNotKeycard
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: title
                text: qsTr("This is not a Keycard")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: qsTr("The card inserted is not a recognised Keycard, please remove and try and again")
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: button
                text: ""
            }
            PropertyChanges {
                target: link
                text: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: "lockedState"
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPinRetriesReached ||
                  root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPukRetriesReached ||
                  root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPairingSlotsReached

            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: {
                    let t = qsTr("You will need to unlock it before proceeding")
                    if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPinRetriesReached)
                        t += qsTr("\nMax PIN retries reached for this keycard")
                    if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPukRetriesReached)
                        t += qsTr("\nMax PUK retries reached for this keycard")
                    if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPairingSlotsReached)
                        t += qsTr("\nMax pairing slots reached for this keycard")
                    return t
                }
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
            PropertyChanges {
                target: button
                text: qsTr("Unlock Keycard")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardRecover
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardRecover
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: title
                text: qsTr("Unlock this Keycard")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: ""
            }
            PropertyChanges {
                target: button
                text: qsTr("Unlock using seed phrase")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: qsTr("Unlock using PUK")
                enabled: !(root.startupStore.startupModuleInst.keycardData & Constants.predefinedKeycardData.maxPUKReached ||
                           root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunOldUserKeycardImport &&
                           root.startupStore.startupModuleInst.keycardData & Constants.predefinedKeycardData.maxPairingSlotsReached)
                color: !enabled? Theme.palette.baseColor1 : Theme.palette.primaryColor1
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardWrongKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardWrongKeycard
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: title
                text: qsTr("Wrong Keycard inserted")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: qsTr("The card inserted is not linked to your profile.")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
            PropertyChanges {
                target: button
                text: ""
            }
            PropertyChanges {
                target: link
                text: ""
            }
            PropertyChanges {
                target: message
                text: qsTr("Go back, remove Keycard and try again")
                color: Theme.palette.baseColor1
                font.pixelSize: Constants.keycard.general.fontSize3
            }
        },
        State {
            name: Constants.startupState.userProfileWrongSeedPhrase
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.userProfileWrongSeedPhrase
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: title
                text: qsTr("Seed phrase doesn’t match any user")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: qsTr("The seed phrase you enter needs to match the seed phrase of an existing user on this device")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
            PropertyChanges {
                target: button
                text: qsTr("Try entering seed phrase again")
            }
            PropertyChanges {
                target: link
                text: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        }
    ]
}
