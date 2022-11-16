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

    signal pukUpdated(string puk)

    onRemainingAttemptsChanged: {
        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPuk) {
            pukInputField.statesInitialization()
            pukInputField.forceFocus()
        }
    }

    onStateChanged: {
        pukInputField.statesInitialization()
        pukInputField.forceFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.padding

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
            id: pukInputField
            Layout.alignment: Qt.AlignHCenter
            validator: StatusRegularExpressionValidator { regularExpression: /[0-9]+/ }
            pinLen: Constants.keycard.general.keycardPukLength
            additionalSpacing: Constants.keycard.general.keycardPukAdditionalSpacing
            additionalSpacingOnEveryNItems: Constants.keycard.general.keycardPukAdditionalSpacingOnEvery4Items

            onPinInputChanged: {
                root.pukUpdated(pinInput)
                if (root.sharedKeycardModule.currentState.stateType !== Constants.keycardSharedState.enterPuk &&
                        root.sharedKeycardModule.currentState.stateType !== Constants.keycardSharedState.wrongPuk) {
                    image.source = Style.png("keycard/card-inserted")
                }
                if(pinInput.length == 0) {
                    return
                }
                if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPuk ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPuk ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPuk) {
                    root.sharedKeycardModule.setPuk(pinInput)
                    root.sharedKeycardModule.currentState.doSecondaryAction()
                }
                else if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPuk) {
                    let pukMatch = root.sharedKeycardModule.checkRepeatedKeycardPukWhileTyping(pinInput)
                    if (pukMatch) {
                        info.text = ""
                        root.sharedKeycardModule.currentState.doSecondaryAction()
                    } else {
                        info.text = qsTr("The PUK doesn’t match")
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
            id: spacer
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.enterPuk
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPuk
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Enter PUK")
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
            name: Constants.keycardSharedState.wrongPuk
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPuk
            PropertyChanges {
                target: image
                source: Style.png("keycard/plain-error")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Enter PUK")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: info
                text: qsTr("The PUK is incorrect, try entering it again")
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
            name: Constants.keycardSharedState.createPuk
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPuk
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Choose a Keycard PUK")
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
            name: Constants.keycardSharedState.repeatPuk
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPuk
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Repeat your Keycard PUK")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: info
                text: ""
                color: Theme.palette.dangerColor1
                font.pixelSize: Constants.keycard.general.fontSize3
            }
            PropertyChanges {
                target: message
                text: ""
            }
        }
    ]
}
