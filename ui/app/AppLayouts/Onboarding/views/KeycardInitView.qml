import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared.popups.keycard.helpers 1.0

import utils 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    Timer {
        id: timer
        interval: 1000
        running: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardRecognizedKeycard
        onTriggered: {
            root.startupStore.currentStartupState.doPrimaryAction()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        height: Constants.keycard.general.onboardingHeight
        spacing: Style.current.padding

        KeycardImage {
            id: image
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Constants.keycard.general.imageHeight
            Layout.preferredWidth: Constants.keycard.general.imageWidth

            onAnimationCompleted: {
                if (root.startupStore.currentStartupState.stateType === Constants.startupState.keycardInsertedKeycard ||
                        root.startupStore.currentStartupState.stateType === Constants.startupState.keycardReadingKeycard) {
                    root.startupStore.currentStartupState.doPrimaryAction()
                }
            }
        }

        Row {
            spacing: Style.current.halfPadding
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: Constants.keycard.general.titleHeight

            StatusIcon {
                id: icon
                visible: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardRecognizedKeycard
                width: Style.current.padding
                height: Style.current.padding
                icon: "checkmark"
                color: Theme.palette.baseColor1
            }
            StatusLoadingIndicator {
                id: loading
                visible: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardReadingKeycard
            }
            StatusBaseText {
                id: title
                wrapMode: Text.WordWrap
            }
        }

        StatusBaseText {
            id: info
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
            name: Constants.startupState.keycardPluginReader
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardPluginReader
            PropertyChanges {
                target: title
                text: qsTr("Plug in Keycard reader...")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
                font.weight: Font.Bold
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/empty-reader")
                pattern: ""
            }
            PropertyChanges {
                target: info
                visible: false
            }
        },
        State {
            name: Constants.startupState.keycardInsertKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardInsertKeycard
            PropertyChanges {
                target: title
                text: qsTr("Insert your Keycard...")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
                font.weight: Font.Bold
            }
            PropertyChanges {
                target: image
                pattern: "keycard/card_insert/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 16
                duration: 1000
                loops: 1
            }
            PropertyChanges {
                target: info
                visible: root.startupStore.startupModuleInst.keycardData !== ""
                text: qsTr("Check the card, it might be wrongly inserted")
                font.pixelSize: Constants.keycard.general.fontSize3
                color: Theme.palette.baseColor1
            }
        },
        State {
            name: Constants.startupState.keycardInsertedKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardInsertedKeycard
            PropertyChanges {
                target: title
                text: qsTr("Keycard inserted...")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
                font.weight: Font.Bold
            }
            PropertyChanges {
                target: image
                pattern: "keycard/card_inserted/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 29
                duration: 1000
                loops: 1
            }
            PropertyChanges {
                target: info
                visible: false
            }
        },
        State {
            name: Constants.startupState.keycardReadingKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardReadingKeycard
            PropertyChanges {
                target: title
                text: qsTr("Reading Keycard...")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
                font.weight: Font.Bold
            }
            PropertyChanges {
                target: image
                pattern: "keycard/warning/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 55
                duration: 3000
                loops: 1
            }
            PropertyChanges {
                target: info
                visible: false
            }
        },
        State {
            name: Constants.startupState.keycardRecognizedKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardRecognizedKeycard
            PropertyChanges {
                target: title
                text: qsTr("Keycard recognized")
                font.pixelSize: Constants.keycard.general.fontSize2
                font.weight: Font.Normal
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: image
                pattern: "keycard/success/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 29
                duration: 1300
                loops: 1
            }
            PropertyChanges {
                target: info
                visible: false
            }
        }
    ]
}
