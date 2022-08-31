import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import "../helpers"

Item {
    id: root

    property var sharedKeycardModule

    property int remainingAttempts: parseInt(root.sharedKeycardModule.keycardData, 10)

    onRemainingAttemptsChanged: {
        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }
    }

    onStateChanged: {
        if(state === Constants.keycardSharedState.pinSet ||
                state === Constants.keycardSharedState.pinVerified) {
            pinInputField.setPin("123456") // we are free to set fake pin in this case
        } else {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
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
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignCenter
            font.weight: Font.Bold
        }

        StatusPinInput {
            id: pinInputField
            Layout.alignment: Qt.AlignHCenter
            validator: StatusIntValidator{bottom: 0; top: 999999;}
            pinLen: Constants.keycard.general.keycardPinLength
            enabled: root.sharedKeycardModule.currentState.stateType !== Constants.keycardSharedState.pinSet &&
                     root.sharedKeycardModule.currentState.stateType !== Constants.keycardSharedState.pinVerified

            onPinInputChanged: {
                if (root.state !== Constants.keycardSharedState.wrongPin) {
                    image.source = Style.png("keycard/enter-pin-%1".arg(pinInput.length))
                }
                if(pinInput.length == 0) {
                    return
                }
                if(root.state === Constants.keycardSharedState.createPin ||
                        root.state === Constants.keycardSharedState.enterPin ||
                        root.state === Constants.keycardSharedState.wrongPin) {
                    root.sharedKeycardModule.setPin(pinInput)
                    root.sharedKeycardModule.currentState.doTertiaryAction()
                }
                else if(root.state === Constants.keycardSharedState.repeatPin) {
                    let pinsMatch = root.sharedKeycardModule.checkRepeatedKeycardPinWhileTyping(pinInput)
                    if (pinsMatch) {
                        info.text = qsTr("It is very important that you do not loose this PIN")
                        root.sharedKeycardModule.currentState.doTertiaryAction()
                    } else {
                        info.text = qsTr("PINs don't match")
                        image.source = Style.png("keycard/plain-error")
                    }
                }
            }
        }

        StatusBaseText {
            id: info
            Layout.alignment: Qt.AlignCenter
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        StatusBaseText {
            id: message
            Layout.alignment: Qt.AlignCenter
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Loader {
            Layout.preferredWidth: parent.width
            active: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard &&
                    (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                     root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                     root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet)

            sourceComponent: KeyPairItem {
                keyPairPubKey: root.sharedKeycardModule.selectedKeyPairItem.pubKey
                keyPairName: root.sharedKeycardModule.selectedKeyPairItem.name
                keyPairIcon: root.sharedKeycardModule.selectedKeyPairItem.icon
                keyPairImage: root.sharedKeycardModule.selectedKeyPairItem.image
                keyPairDerivedFrom: root.sharedKeycardModule.selectedKeyPairItem.derivedFrom
                keyPairAccounts: root.sharedKeycardModule.selectedKeyPairItem.accounts
            }
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.enterPin
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-empty")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Enter this Keycard’s PIN")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
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
            name: Constants.keycardSharedState.wrongPin
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin
            PropertyChanges {
                target: image
                source: Style.png("keycard/plain-error")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Enter Keycard PIN")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: info
                text: qsTr("PIN incorrect")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize3
            }
            PropertyChanges {
                target: message
                text: qsTr("%n attempt(s) remaining", "", root.remainingAttempts)
                color: root.remainingAttempts === 1?
                           Theme.palette.dangerColor1 :
                           Theme.palette.baseColor1
                font.pixelSize: Constants.keycard.general.fontSize3
            }
        },
        State {
            name: Constants.keycardSharedState.createPin
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin
            PropertyChanges {
                target: image
                source: Style.png("keycard/enter-pin-0")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Choose a Keycard PIN")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: info
                text: qsTr("It is very important that you do not loose this PIN")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize3
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.repeatPin
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin
            PropertyChanges {
                target: image
                source: Style.png("keycard/enter-pin-0")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Repeat Keycard PIN")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: info
                text: qsTr("It is very important that you do not loose this PIN")
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize3
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.pinSet
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet
            PropertyChanges {
                target: image
                pattern: "keycard/strong_success/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 20
                duration: 1300
                loops: 1
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard PIN set")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
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
            name: Constants.keycardSharedState.pinVerified
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified
            PropertyChanges {
                target: image
                pattern: "keycard/strong_success/img-%1"
                source: ""
                startImgIndexForTheFirstLoop: 0
                startImgIndexForOtherLoops: 0
                endImgIndex: 20
                duration: 1300
                loops: 1
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard PIN verified!")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: info
                text: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        }
    ]
}
