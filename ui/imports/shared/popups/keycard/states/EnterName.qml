import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
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
            d.entryValid = root.sharedKeycardModule.keyPairForProcessing.name.trim().length > 0
            if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.renameKeycard) {
                d.entryValid = d.entryValid && root.sharedKeycardModule.keyPairForProcessing.name !== root.sharedKeycardModule.getNameFromKeycard()
            }
            root.validation(d.entryValid)
        }
    }

    Component.onCompleted: {
        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase ||
                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase) {
            if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterKeycardName) {
                if (root.sharedKeycardModule.keyPairForProcessing.name.trim() !== "") {
                    d.updateValidity()
                    return
                }

                let color = Constants.preDefinedWalletAccountColors[Math.floor(Math.random() * Constants.preDefinedWalletAccountColors.length)]
                let emoji = StatusQUtils.Emoji.getRandomEmoji(StatusQUtils.Emoji.size.verySmall)
                root.sharedKeycardModule.keyPairForProcessing.observedAccount.name = "      "
                root.sharedKeycardModule.keyPairForProcessing.observedAccount.color = color
                root.sharedKeycardModule.keyPairForProcessing.observedAccount.emoji = emoji
            }
        }

        d.updateValidity()
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
            text: root.sharedKeycardModule.keyPairForProcessing.name
            input.acceptReturn: true

            onTextChanged: {
                root.sharedKeycardModule.keyPairForProcessing.name = text
                d.updateValidity()
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
            keyPairType: root.sharedKeycardModule.keyPairForProcessing.pairType
            keyPairKeyUid: root.sharedKeycardModule.keyPairForProcessing.keyUid
            keyPairName: root.sharedKeycardModule.keyPairForProcessing.name
            keyPairIcon: root.sharedKeycardModule.keyPairForProcessing.icon
            keyPairImage: root.sharedKeycardModule.keyPairForProcessing.image
            keyPairDerivedFrom: root.sharedKeycardModule.keyPairForProcessing.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.keyPairForProcessing.accounts
            keyPairCardLocked: root.sharedKeycardModule.keyPairForProcessing.locked
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.enterKeycardName
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterKeycardName
            PropertyChanges {
                target: title
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.renameKeycard) {
                        qsTr("Rename this Keycard")
                    }

                    return qsTr("Name this Keycard")
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: keycardName
                placeholderText: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.renameKeycard) {
                        return qsTr("Keycard name")
                    }

                    return qsTr("What would you like this Keycard to be called?")
                }
            }
        }
    ]
}
