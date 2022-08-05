import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

Item {
    id: root

    property var sharedKeycardModule

    Timer {
        id: timer
        interval: 1000
        running: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard
        onTriggered: {
            root.sharedKeycardModule.currentState.doSecondaryAction()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.current.padding

        Image {
            id: image
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Constants.keycard.shared.imageHeight
            Layout.preferredWidth: Constants.keycard.shared.imageWidth
            fillMode: Image.PreserveAspectFit
            antialiasing: true
            mipmap: true
        }

        Row {
            spacing: Style.current.halfPadding
            Layout.alignment: Qt.AlignCenter

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
                visible: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard
            }
            StatusBaseText {
                id: title
                wrapMode: Text.WordWrap
            }
        }

        StatusBaseText {
            id: message
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
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
                source: Style.png("keycard/popup_card_reader@2x")
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
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
                source: Style.png("keycard/popup_insert_card@2x")
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
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
                source: Style.png("keycard/popup_card_yellow@2x")
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.keycardSharedState.notKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard
            PropertyChanges {
                target: title
                text: qsTr("This is not a Keycard")
                font.pixelSize: Constants.keycard.general.fontSize2
                font.weight: Font.Bold
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/popup_card_red_wrong@2x")
            }
            PropertyChanges {
                target: message
                text: qsTr("The card inserted is not a recognised Keycard,\nplease remove and try and again")
                font.pixelSize: Constants.keycard.general.fontSize3
                color: Theme.palette.dangerColor1
                visible: true
            }
        },
        State {
            name: Constants.keycardSharedState.keycardEmpty
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty
            PropertyChanges {
                target: title
                text: qsTr("Keycard is empty")
                font.pixelSize: Constants.keycard.general.fontSize2
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/popup_card_dark@2x")
            }
            PropertyChanges {
                target: message
                text: qsTr("There is no key pair on this Keycard")
                font.pixelSize: Constants.keycard.general.fontSize3
                color: Theme.palette.directColor1
                visible: true
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
                source: Style.png("keycard/popup_card_green@2x")
            }
            PropertyChanges {
                target: message
                text: ""
                visible: false
            }
        },
        State {
            name: Constants.keycardSharedState.factoryResetSuccess
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess
            PropertyChanges {
                target: title
                text: qsTr("Keycard successfully factory reset")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/popup_card_green_checked@2x")
            }
            PropertyChanges {
                target: message
                text: qsTr("You can now use this Keycard as if it\nwas a brand new empty Keycard")
                font.pixelSize: Constants.keycard.general.fontSize3
                color: Theme.palette.directColor1
                visible: true
            }
        }
    ]
}
