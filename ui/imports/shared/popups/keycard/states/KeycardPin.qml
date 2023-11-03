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

    property int remainingAttempts: root.sharedKeycardModule.remainingAttempts

    signal pinUpdated(string pin)

    onRemainingAttemptsChanged: {
        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin) {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }
    }

    onStateChanged: {
        if(d.useFakePin) {
            pinInputField.setPin("123456") // we are free to set fake pin in this case
        } else {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }
    }

    Component.onCompleted: {
        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication ||
                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.sign ||
                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
            timer.start()
        }
    }

    Timer {
        id: timer
        interval: 500
        onTriggered: {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }
    }

    QtObject {
        id: d
        readonly property bool useFakePin: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet ||
                                           root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                                           root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinSuccess ||
                                           root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinFailure
        readonly property string message1: qsTr("It is very important that you do not lose this PIN")
        readonly property string message2: qsTr("Don’t lose your PIN! If you do, you may lose\naccess to your funds.")
    }

    Component {
        id: keyPairForProcessingComponent
        KeyPairItem {
            keyPairType:  root.sharedKeycardModule.keyPairForProcessing.pairType
            keyPairKeyUid: root.sharedKeycardModule.keyPairForProcessing.keyUid
            keyPairName: root.sharedKeycardModule.keyPairForProcessing.name
            keyPairIcon: root.sharedKeycardModule.keyPairForProcessing.icon
            keyPairImage: root.sharedKeycardModule.keyPairForProcessing.image
            keyPairDerivedFrom: root.sharedKeycardModule.keyPairForProcessing.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.keyPairForProcessing.accounts
            keyPairCardLocked: root.sharedKeycardModule.keyPairForProcessing.locked
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication ||
                 root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.sign?
                     Style.current.halfPadding : Style.current.padding

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

        StatusBaseText {
            id: subTitle
            Layout.alignment: Qt.AlignCenter
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        StatusPinInput {
            id: pinInputField
            Layout.alignment: Qt.AlignHCenter
            validator: StatusIntValidator{bottom: 0; top: 999999;}
            pinLen: Constants.keycard.general.keycardPinLength
            enabled: !d.useFakePin
            onPinInputChanged: {
                root.pinUpdated(pinInput)
                if (root.sharedKeycardModule.currentState.stateType !== Constants.keycardSharedState.wrongPin &&
                        root.sharedKeycardModule.currentState.stateType !== Constants.keycardSharedState.wrongKeychainPin) {
                    image.source = Style.png("keycard/enter-pin-%1".arg(pinInput.length))
                }
                if(pinInput.length == 0) {
                    return
                }
                if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin) {
                    root.sharedKeycardModule.setPin(pinInput)
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication ||
                            root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.sign)
                        return
                    root.sharedKeycardModule.currentState.doSecondaryAction()
                }
                else if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin) {
                    let pinsMatch = root.sharedKeycardModule.checkRepeatedKeycardPinWhileTyping(pinInput)
                    if (pinsMatch) {
                        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin)
                            info.text = d.message2
                        else
                            info.text = d.message1
                        root.sharedKeycardModule.currentState.doSecondaryAction()
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
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        StatusBaseText {
            id: message
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        Loader {
            id: loader
            Layout.preferredWidth: parent.width
            active: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication ||
                        root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.sign) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin) {
                        return true
                    }
                }

                return false
            }

            sourceComponent: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet) {
                        return keyPairForProcessingComponent
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication ||
                        root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.sign) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin) {
                        return keyPairForProcessingComponent
                    }
                }

                return undefined
            }
        }

        Item {
            id: spacer
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !loader.active
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
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin) {
                        return qsTr("Enter the Keycard PIN")
                    }
                    return qsTr("Enter this Keycard’s PIN")
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: subTitle
                text: ""
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
                target: subTitle
                text: ""
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
            name: Constants.keycardSharedState.wrongKeychainPin
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin
            PropertyChanges {
                target: image
                source: Style.png("keycard/plain-error")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Your saved PIN is out of date")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: subTitle
                text: qsTr("Enter your new PIN to proceed")
                font.pixelSize: Constants.keycard.general.fontSize3
                color: Theme.palette.baseColor1
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
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin) {
                        return qsTr("Enter new Keycard PIN")
                    }
                    return qsTr("Choose a Keycard PIN")
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: subTitle
                text: ""
            }
            PropertyChanges {
                target: info
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin) {
                        return d.message2
                    }
                    return d.message1
                }
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
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin) {
                        return qsTr("Repeat new Keycard PIN")
                    }
                    return qsTr("Repeat Keycard PIN")
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: subTitle
                text: ""
            }
            PropertyChanges {
                target: info
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin) {
                        return d.message2
                    }
                    return d.message1
                }
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize3
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: "success-state"
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinSuccess
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
                text: {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet) {
                        return qsTr("Keycard PIN set")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified) {
                        return qsTr("Keycard PIN verified!")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinSuccess) {
                        return qsTr("PIN successfully changed")
                    }
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: subTitle
                text: ""
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
            name: "error-state"
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinFailure
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
                text: {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPinFailure) {
                        return qsTr("Changing PIN failed")
                    }
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: subTitle
                text: ""
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
