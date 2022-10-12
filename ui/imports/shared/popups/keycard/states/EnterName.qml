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

    signal validation(bool result)

    QtObject {
        id: d
        property bool entryValid: false

        function updateValidity() {
            d.entryValid = keycardName.text.trim().length > 0 && keycardName.text !== root.sharedKeycardModule.keyPairStoredOnKeycard.name
            root.validation(d.entryValid)
        }
    }

    Component.onCompleted: {
        keycardName.input.edit.forceActiveFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.padding

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignCenter
            font.weight: Font.Bold
        }

        StatusInput {
            id: keycardName
            Layout.preferredWidth: Constants.keycard.general.keycardNameInputWidth
            Layout.alignment: Qt.AlignCenter
            charLimit: Constants.keycard.general.keycardNameLength
            placeholderText: qsTr("Keycard name")
            text: root.sharedKeycardModule.keyPairStoredOnKeycard.name
            input.acceptReturn: true

            onTextChanged: {
                d.updateValidity()
                if (d.entryValid) {
                    root.sharedKeycardModule.setKeycarName(text)
                }
            }

            onKeyPressed: {
                if (d.entryValid &&
                        (input.edit.keyEvent === Qt.Key_Return ||
                         input.edit.keyEvent === Qt.Key_Enter)) {
                    event.accepted = true
                    root.sharedKeycardModule.currentState.doPrimaryAction()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignLeft
            text: qsTr("Preview")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.baseColor1
        }

        KeyPairItem {
            Layout.preferredWidth: parent.width
            keyPairType:  root.sharedKeycardModule.keyPairStoredOnKeycard.pairType
            keyPairPubKey: root.sharedKeycardModule.keyPairStoredOnKeycard.pubKey
            keyPairName: keycardName.text
            keyPairIcon: root.sharedKeycardModule.keyPairStoredOnKeycard.icon
            keyPairImage: root.sharedKeycardModule.keyPairStoredOnKeycard.image
            keyPairDerivedFrom: root.sharedKeycardModule.keyPairStoredOnKeycard.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.keyPairStoredOnKeycard.accounts
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.enterKeycardName
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterKeycardName
            PropertyChanges {
                target: title
                text: qsTr("Rename this Keycard")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
        }
    ]
}
