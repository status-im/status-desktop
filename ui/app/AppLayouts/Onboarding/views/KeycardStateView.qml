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
        height: Constants.keycard.general.onboardingHeight
        spacing: Style.current.padding

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
            Layout.alignment: Qt.AlignHCenter
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
                text: ""
            }
            PropertyChanges {
                target: info
                text: qsTr("The keycard is empty")
                color: Theme.palette.dangerColor1
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
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: -1
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
            name: Constants.startupState.keycardNotKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardNotKeycard
            PropertyChanges {
                target: image
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: -1
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
            name: Constants.startupState.keycardMaxPairingSlotsReached
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPairingSlotsReached
            PropertyChanges {
                target: image
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: -1
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: qsTr("Max pairing slots reached for this keycard")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
            PropertyChanges {
                target: button
                text: qsTr("Factory reset")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: qsTr("Insert another Keycard")
                color: Theme.palette.primaryColor1
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardMaxPukRetriesReached
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPukRetriesReached
            PropertyChanges {
                target: image
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: -1
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: qsTr("Max PUK retries reached for this keycard")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize2
            }
            PropertyChanges {
                target: button
                text: qsTr("Factory reset")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: qsTr("Insert another Keycard")
                color: Theme.palette.primaryColor1
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.startupState.keycardMaxPinRetriesReached
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPinRetriesReached
            PropertyChanges {
                target: image
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: -1
            }
            PropertyChanges {
                target: title
                text: ""
            }
            PropertyChanges {
                target: info
                text: qsTr("Keycard locked")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: button
                text: qsTr("Recover your Keycard")
                type: StatusBaseButton.Type.Danger
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
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: -1
            }
            PropertyChanges {
                target: title
                text: qsTr("Recover your Keycard")
                color: Theme.palette.directColor1
                font.pixelSize: Constants.keycard.general.fontSize1
            }
            PropertyChanges {
                target: info
                text: ""
            }
            PropertyChanges {
                target: button
                text: qsTr("Recover with seed phrase")
                type: StatusBaseButton.Type.Danger
            }
            PropertyChanges {
                target: link
                text: qsTr("Recover with PUK")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                text: ""
            }
        }
    ]
}
