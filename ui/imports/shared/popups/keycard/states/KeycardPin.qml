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

    signal pinUpdated(string pin)

    onRemainingAttemptsChanged: {
        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin) {
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

    Component.onCompleted: timer.start()

    Timer {
        id: timer
        interval: 1000
        onTriggered: {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }
    }

    Component {
        id: keyPairComponent
        KeyPairItem {
            keyPairType:  root.sharedKeycardModule.selectedKeyPairItem.pairType
            keyPairPubKey: root.sharedKeycardModule.selectedKeyPairItem.pubKey
            keyPairName: root.sharedKeycardModule.selectedKeyPairItem.name
            keyPairIcon: root.sharedKeycardModule.selectedKeyPairItem.icon
            keyPairImage: root.sharedKeycardModule.selectedKeyPairItem.image
            keyPairDerivedFrom: root.sharedKeycardModule.selectedKeyPairItem.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.selectedKeyPairItem.accounts
        }
    }

    Component {
        id: keyPairForAuthenticationComponent
        KeyPairItem {
            keyPairType:  root.sharedKeycardModule.keyPairForAuthentication.pairType
            keyPairPubKey: root.sharedKeycardModule.keyPairForAuthentication.pubKey
            keyPairName: root.sharedKeycardModule.keyPairForAuthentication.name
            keyPairIcon: root.sharedKeycardModule.keyPairForAuthentication.icon
            keyPairImage: root.sharedKeycardModule.keyPairForAuthentication.image
            keyPairDerivedFrom: root.sharedKeycardModule.keyPairForAuthentication.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.keyPairForAuthentication.accounts
            keyPairCardLocked: root.sharedKeycardModule.keyPairForAuthentication.locked
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.halfPadding

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
            Layout.fillHeight: !info.visble && !message.visible? true : false
            validator: StatusIntValidator{bottom: 0; top: 999999;}
            pinLen: Constants.keycard.general.keycardPinLength
            enabled: root.sharedKeycardModule.currentState.stateType !== Constants.keycardSharedState.pinSet &&
                     root.sharedKeycardModule.currentState.stateType !== Constants.keycardSharedState.pinVerified

            onPinInputChanged: {
                root.pinUpdated(pinInput)
                if (root.state !== Constants.keycardSharedState.wrongPin ||
                        root.state === Constants.keycardSharedState.wrongKeychainPin) {
                    image.source = Style.png("keycard/enter-pin-%1".arg(pinInput.length))
                }
                if(pinInput.length == 0) {
                    return
                }
                if(root.state === Constants.keycardSharedState.createPin ||
                        root.state === Constants.keycardSharedState.enterPin ||
                        root.state === Constants.keycardSharedState.wrongPin ||
                        root.state === Constants.keycardSharedState.wrongKeychainPin) {
                    root.sharedKeycardModule.setPin(pinInput)
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication)
                        return
                    root.sharedKeycardModule.currentState.doTertiaryAction()
                }
                else if(root.state === Constants.keycardSharedState.repeatPin) {
                    let pinsMatch = root.sharedKeycardModule.checkRepeatedKeycardPinWhileTyping(pinInput)
                    if (pinsMatch) {
                        info.text = qsTr("It is very important that you do not lose this PIN")
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
            Layout.fillHeight: info.visble && !message.visible? true : false
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        StatusBaseText {
            id: message
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: message.visible? true : false
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        Loader {
            Layout.preferredWidth: parent.width
            active: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
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
                        return keyPairComponent
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin) {
                        return keyPairForAuthenticationComponent
                    }
                }

                return undefined
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
                text: qsTr("Choose a Keycard PIN")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: subTitle
                text: ""
            }
            PropertyChanges {
                target: info
                text: qsTr("It is very important that you do not lose this PIN")
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
                target: subTitle
                text: ""
            }
            PropertyChanges {
                target: info
                text: qsTr("It is very important that you do not lose this PIN")
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
