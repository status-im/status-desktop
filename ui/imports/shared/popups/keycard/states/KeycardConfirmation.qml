import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../helpers"

Item {
    id: root

    property var sharedKeycardModule

    signal confirmationUpdated(bool value)

    Component {
        id: knownKeyPairComponent
        KeyPairItem {
            keyPairType:  root.sharedKeycardModule.keyPairStoredOnKeycard.pairType
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
            pattern: Constants.keycardAnimations.strongError.pattern
            source: ""
            startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
            startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
            endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
            duration: Constants.keycardAnimations.strongError.duration
            loops: Constants.keycardAnimations.strongError.loops
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredHeight: Constants.keycard.general.titleHeight
            wrapMode: Text.WordWrap
            text: qsTr("A factory reset will delete the key on this Keycard.\nAre you sure you want to do this?")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.dangerColor1
        }

        StatusCheckBox {
            id: confirmation
            Layout.preferredHeight: Constants.keycard.general.messageHeight
            Layout.alignment: Qt.AlignCenter
            leftSide: false
            spacing: Style.current.smallPadding
            font.pixelSize: Constants.keycard.general.fontSize2
            text: qsTr("I understand the key pair on this Keycard will be deleted")

            onCheckedChanged: {
                root.confirmationUpdated(checked)
            }
        }

        Loader {
            id: loader
            Layout.preferredWidth: parent.width
            active: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        return true
                    }
                }
                return false
            }

            sourceComponent: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return knownKeyPairComponent
                        }
                        return unknownKeyPairCompontnt
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
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
            Layout.fillHeight: visible
        }
    }
}
