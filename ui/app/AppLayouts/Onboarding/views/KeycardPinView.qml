import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property KeycardStore keycardStore

    onStateChanged: {
        if(state === Constants.keycard.state.keycardPinSetState) {
            pinInputField.setPin("123456") // we are free to set fake pin in this case
        } else {
            pinInputField.statesInitialization()
            pinInputField.forceFocus()
        }
    }

    Timer {
        id: timer
        interval: 4000
        running: keycardStore.keycardModule.flowState === Constants.keycard.state.keycardPinSetState
        onTriggered: {
            keycardStore.nextState()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.current.padding

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: sourceSize.height
            Layout.preferredWidth: sourceSize.width
            fillMode: Image.PreserveAspectFit
            antialiasing: true
            source: keycardStore.keycardModule.flowState === Constants.keycard.state.keycardPinSetState?
                        Style.svg("keycard/card-success3@2x") :
                        Style.svg("keycard/card3@2x")
            mipmap: true
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Bold
            font.pixelSize: Constants.keycard.general.titleFontSize1
            color: Theme.palette.directColor1
        }

        StatusPinInput {
            id: pinInputField
            Layout.alignment: Qt.AlignHCenter
            validator: StatusIntValidator{bottom: 0; top: 999999;}
            pinLen: Constants.keycard.general.keycardPinLength
            enabled: keycardStore.keycardModule.flowState !== Constants.keycard.state.keycardPinSetState

            onPinInputChanged: {
                if(root.state === Constants.keycard.state.createKeycardPinState) {
                    if(keycardStore.checkKeycardPin(pinInput)) {
                        keycardStore.nextState()
                    }
                }
                else if(root.state === Constants.keycard.state.repeatKeycardPinState) {
                    let pinsMatch = keycardStore.checkRepeatedKeycardPinCurrent(pinInput)
                    if (pinsMatch) {
                        info.text = qsTr("It is very important that you do not loose this PIN")
                        if(keycardStore.checkRepeatedKeycardPin(pinInput)) {
                            keycardStore.nextState()
                        }
                    } else {
                        info.text = qsTr("PINs don't match")
                    }
                }
            }
        }

        StatusBaseText {
            id: info
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Constants.keycard.general.infoFontSize
            color: Theme.palette.dangerColor1
            wrapMode: Text.WordWrap
        }
    }

    states: [
        State {
            name: Constants.keycard.state.createKeycardPinState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.createKeycardPinState
            PropertyChanges {
                target: title
                text: qsTr("Create new Keycard PIN")
            }
            PropertyChanges {
                target: info
                text: qsTr("It is very important that you do not loose this PIN")
            }
        },
        State {
            name: Constants.keycard.state.repeatKeycardPinState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.repeatKeycardPinState
            PropertyChanges {
                target: title
                text: qsTr("Repeat Keycard PIN")
            }
            PropertyChanges {
                target: info
                text: qsTr("It is very important that you do not loose this PIN")
            }
        },
        State {
            name: Constants.keycard.state.keycardPinSetState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.keycardPinSetState
            PropertyChanges {
                target: title
                text: qsTr("Keycard PIN set")
            }
            PropertyChanges {
                target: info
                text: ""
            }
        }
    ]
}
