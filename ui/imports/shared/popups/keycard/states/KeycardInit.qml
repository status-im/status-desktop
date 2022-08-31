import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

///////// Remove Later////////////
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
//////////////////////////////////

import utils 1.0

import "../helpers"

Item {
    id: root

    property var sharedKeycardModule

    Component.onCompleted: {
        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair) {
            passwordPopup.open()
        }
    }

    QtObject {
        id: d

        property bool hideKeyPair: root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.hideKeyPair
    }

    Timer {
        id: timer
        interval: 1000
        running: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard
        onTriggered: {
            root.sharedKeycardModule.currentState.doSecondaryAction()
        }
    }

    ///////// Remove Later////////////
    StatusModal {
        id: passwordPopup
        width: 300
        height: 200
        anchors.centerIn: parent
        header.title: qsTr("Temporary Popup")
        closePolicy: Popup.NoAutoClose
        contentItem: Item {
            StatusInput {
                id: password
                width: parent.width - Style.current.padding * 2
                anchors.centerIn: parent
                input.clearable: true
                placeholderText: qsTr("Enter password...")
            }
        }
        rightButtons: [
            StatusButton {
                id: primaryButton
                text: qsTr("Next")
                onClicked: {
                    root.sharedKeycardModule.setPassword(password.text)
                    passwordPopup.close()
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }
        ]
    }
    //////////////////////////////////

    Component {
        id: keyPairComponent
        KeyPairItem {
            keyPairPubKey: root.sharedKeycardModule.selectedKeyPairItem.pubKey
            keyPairName: root.sharedKeycardModule.selectedKeyPairItem.name
            keyPairIcon: root.sharedKeycardModule.selectedKeyPairItem.icon
            keyPairImage: root.sharedKeycardModule.selectedKeyPairItem.image
            keyPairDerivedFrom: root.sharedKeycardModule.selectedKeyPairItem.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.selectedKeyPairItem.accounts
        }
    }

    Component {
        id: knownKeyPairComponent
        KeyPairItem {
            keyPairPubKey: root.sharedKeycardModule.keyPairStoredOnKeycard.pubKey
            keyPairName: root.sharedKeycardModule.keyPairStoredOnKeycard.name
            keyPairIcon: root.sharedKeycardModule.keyPairStoredOnKeycard.icon
            keyPairImage: root.sharedKeycardModule.keyPairStoredOnKeycard.image
            keyPairDerivedFrom: root.sharedKeycardModule.keyPairStoredOnKeycard.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.keyPairStoredOnKeycard.accounts
        }
    }

    Component {
        id: unknownKeyPairCompontnt
        KeyPairUnknownItem {
            keyPairPubKey: root.sharedKeycardModule.keyPairStoredOnKeycard.pubKey
            keyPairName: root.sharedKeycardModule.keyPairStoredOnKeycard.name
            keyPairIcon: root.sharedKeycardModule.keyPairStoredOnKeycard.icon
            keyPairImage: root.sharedKeycardModule.keyPairStoredOnKeycard.image
            keyPairDerivedFrom: root.sharedKeycardModule.keyPairStoredOnKeycard.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.keyPairStoredOnKeycard.accounts
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.padding
        clip: true

        KeycardImage {
            id: image
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Constants.keycard.shared.imageHeight
            Layout.preferredWidth: Constants.keycard.shared.imageWidth

            onAnimationCompleted: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard) {
                    root.sharedKeycardModule.currentState.doSecondaryAction()
                }
            }
        }

        Row {
            spacing: Style.current.halfPadding
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: Constants.keycard.general.titleHeight

            StatusIcon {
                id: icon
                visible: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard
                width: Style.current.padding
                height: Style.current.padding
                icon: "checkmark"
                color: Theme.palette.baseColor1
            }
            StatusLoadingIndicator {
                id: loading
                visible: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair
            }
            StatusBaseText {
                id: title
                wrapMode: Text.WordWrap
            }
        }

        StatusBaseText {
            id: message
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: Constants.keycard.general.messageHeight
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Loader {
            id: loader
            Layout.preferredWidth: parent.width
            active: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if((root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard && !d.hideKeyPair) ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return true
                    }
                }
                return false
            }

            sourceComponent: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return knownKeyPairComponent
                        }
                        return unknownKeyPairCompontnt
                    }
                    if ((root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard && !d.hideKeyPair) ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure) {
                        return keyPairComponent
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return knownKeyPairComponent
                        }
                        return unknownKeyPairCompontnt
                    }
                }
            }
        }

        Item {
            visible: !loader.active
            Layout.fillWidth: true
            Layout.fillHeight: this.visible? true : false
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.pluginReader
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader
            PropertyChanges {
                target: title
                text: qsTr("Plug in Keycard reader...")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/empty-reader")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.insertKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard
            PropertyChanges {
                target: title
                text: qsTr("Insert Keycard...")
                font.weight: Font.Bold
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
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
                target: message
                text: root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.wronglyInsertedCard?
                          qsTr("Check the card, it might be wrongly inserted") :
                          ""
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keycardInserted
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted
            PropertyChanges {
                target: title
                text: qsTr("Keycard inserted...")
                font.weight: Font.Bold
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
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
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.readingKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard
            PropertyChanges {
                target: title
                text: qsTr("Reading Keycard...")
                font.pixelSize: Constants.keycard.general.fontSize2
                font.weight: Font.Bold
                color: Theme.palette.baseColor1
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
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.notKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard
            PropertyChanges {
                target: title
                text: qsTr("This is not a Keycard")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.dangerColor1
            }
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
                target: message
                text: qsTr("The card inserted is not a recognised Keycard,\nplease remove and try and again")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.maxPinRetriesReached
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.dangerColor1
            }
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
                target: message
                text: qsTr("Pin entered incorrectly too many times")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keycardEmptyMetadata
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata
            PropertyChanges {
                target: title
                text: qsTr("This Keycard has empty metadata")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: qsTr("This Keycard already stores keys\nbut doesn't store any metadata")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keycardEmpty
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty
            PropertyChanges {
                target: title
                text: qsTr("Keycard is empty")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-empty")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: qsTr("There is no key pair on this Keycard")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keycardNotEmpty
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty
            PropertyChanges {
                target: title
                text: qsTr("This Keycard already stores keys")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard?
                          qsTr("To migrate %1 on to this Keycard, you\nwill need to perform a factory reset first")
                          .arg(root.sharedKeycardModule.selectedKeyPairItem.name) :
                          ""
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycardSharedState.recognizedKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard
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
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.factoryResetSuccess
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess
            PropertyChanges {
                target: title
                text: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard?
                          qsTr("Your Keycard has been reset") :
                          qsTr("Keycard successfully factory reset")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: "keycard/strong_success/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 20
                duration: 1000
                loops: 1
            }
            PropertyChanges {
                target: message
                text: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard?
                          qsTr("You can now create a new key pair on this Keycard") :
                          qsTr("You can now use this Keycard as if it\nwas a brand new empty Keycard")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycardSharedState.migratingKeyPair
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair
            PropertyChanges {
                target: title
                text: qsTr("Migrating key pair to Keycard")
                font.pixelSize: Constants.keycard.general.fontSize2
                font.weight: Font.Bold
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: image
                pattern: "keycard/warning/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 55
                duration: 3000
                loops: -1
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.keyPairMigrateSuccess
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess
            PropertyChanges {
                target: title
                text: qsTr("Key pair successfully migrated")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: "keycard/strong_success/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 20
                duration: 1000
                loops: 1
            }
            PropertyChanges {
                target: message
                text: qsTr("To complete migration close Status and log in with your new Keycard")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keyPairMigrateFailure
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure
            PropertyChanges {
                target: title
                text: qsTr("Key pair failed to migrated")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: "keycard/strong_error/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 18
                endImgIndex: 29
                duration: 1300
                loops: 1
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.keycardMetadataDisplay
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay
            PropertyChanges {
                target: title
                text: qsTr("Accounts on this Keycard")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        }
    ]
}
