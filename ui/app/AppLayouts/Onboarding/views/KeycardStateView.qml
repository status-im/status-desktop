import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    Item {
        anchors.top: parent.top
        anchors.bottom: footerWrapper.top
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Style.current.padding

            Image {
                id: image
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
                fillMode: Image.PreserveAspectFit
                antialiasing: true
                mipmap: true
            }

            StatusBaseText {
                id: title
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
            }

            StatusBaseText {
                id: info
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.fontSize3
                wrapMode: Text.WordWrap
            }
        }
    }

    Item {
        id: footerWrapper
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Constants.keycard.general.footerWrapperHeight

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.current.bigPadding

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
        }
    }

    states: [
        State {
            name: Constants.startupState.keycardNotEmpty
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardNotEmpty
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card3@2x")
            }
            PropertyChanges {
                target: title
                text: qsTr("This Keycard already stores keys")
            }
            PropertyChanges {
                target: info
                text: qsTr("To generate new keys, you will need to perform a factory reset first")
                color: Theme.palette.directColor1
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
        },
        State {
            name: Constants.startupState.keycardEmpty
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardEmpty
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: ""
            }
            PropertyChanges {
                target: info
                text: qsTr("The keycard is empty")
                color: Theme.palette.dangerColor1
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
        },
        State {
            name: Constants.startupState.keycardLocked
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardLocked
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked and already stores keys")
            }
            PropertyChanges {
                target: info
                text: qsTr("The Keycard you have inserted is locked, you will need to factory reset it before proceeding")
                color: Theme.palette.directColor1
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
        },
        State {
            name: Constants.startupState.keycardMaxPairingSlotsReached
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPairingSlotsReached
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: info
                text: qsTr("Max pairing slots reached for this keycard")
                color: Theme.palette.dangerColor1
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
        },
        State {
            name: Constants.startupState.keycardMaxPukRetriesReached
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPukRetriesReached
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: info
                text: qsTr("Max PUK retries reached for this keycard")
                color: Theme.palette.dangerColor1
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
        },
        State {
            name: Constants.startupState.keycardMaxPinRetriesReached
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardMaxPinRetriesReached
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
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
        },
        State {
            name: Constants.startupState.keycardRecover
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardRecover
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: qsTr("Recover your Keycard")
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
        }
    ]
}
