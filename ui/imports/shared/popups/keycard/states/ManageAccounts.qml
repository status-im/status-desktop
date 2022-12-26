import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1

import utils 1.0
import shared.popups 1.0

import "../helpers"

Item {
    id: root

    property var sharedKeycardModule
    property var emojiPopup

    signal validation(bool result)

    QtObject {
        id: d
        property var observedAccount: root.sharedKeycardModule.keyPairForProcessing.observedAccount
        property bool entryValid: false
        property string emptyName: "      "
        property string accountNameToBeRemoved: ""
        property int accountIndexToBeRemoved: -1

        onObservedAccountChanged: {
            if (d.observedAccount.name.trim().length > 0) {
                accountName.text = d.observedAccount.name
            }
            else {
                accountName.text = ""
                d.observedAccount.name = d.emptyName
            }

            if (d.observedAccount.color.length === 0) {
                let color = Constants.preDefinedWalletAccountColors[Math.floor(Math.random() * Constants.preDefinedWalletAccountColors.length)]
                let emoji = StatusQUtils.Emoji.getRandomEmoji(StatusQUtils.Emoji.size.verySmall)
                d.observedAccount.color = color
                d.observedAccount.emoji = emoji
            }

            let ind = d.evaluateColorIndex(d.observedAccount.color)
            colorSelection.selectedColorIndex = ind
            d.updateValidity()
        }

        function updateValidity() {
            d.entryValid = d.observedAccount.name.trim().length > 0
            root.validation(d.entryValid)
        }

        function evaluateColorIndex(color) {
            for (let i = 0; i < Constants.preDefinedWalletAccountColors.length; i++) {
                if(Constants.preDefinedWalletAccountColors[i] === color) {
                    return i
                }
            }
            return 0
        }
    }

    Component.onCompleted: {
        d.updateValidity()
        accountName.input.edit.forceActiveFocus()
    }

    Connections {
        target: root.emojiPopup
        enabled: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase ||
                 root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase

        function onEmojiSelected (emojiText, atCursor) {
            d.observedAccount.emoji = emojiText
        }
    }

    ConfirmationDialog {
        id: confirmationPopup
        header.title: qsTr("Remove account")
        confirmationText: d.accountNameToBeRemoved.length > 0?
                              qsTr("Do you want to delete the %1 account?").arg(d.accountNameToBeRemoved)
                            : qsTr("Do you want to delete the last account?")
        confirmButtonLabel: qsTr("Yes, delete this account")
        onConfirmButtonClicked: {
            confirmationPopup.close();
            root.sharedKeycardModule.keyPairForProcessing.removeAccountAtIndex(d.accountIndexToBeRemoved)
        }
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
            id: accountName
            Layout.preferredWidth: Constants.keycard.general.keycardNameInputWidth
            Layout.alignment: Qt.AlignCenter
            charLimit: Constants.keycard.general.keycardNameLength
            placeholderText: qsTr("What would you like this account to be called?")
            input.acceptReturn: true
            input.isIconSelectable: true
            input.leftPadding: Style.current.padding
            input.asset.color: d.observedAccount.color
            input.asset.emoji: d.observedAccount.emoji

            onTextChanged: {
                d.observedAccount.name = text.trim().length > 0? text : d.emptyName
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

            onIconClicked: {
                let inputCoords = accountName.mapToItem(appMain, 0, 0)
                root.emojiPopup.open()
                root.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall
                root.emojiPopup.x = inputCoords.x
                root.emojiPopup.y = inputCoords.y + accountName.height + Style.current.halfPadding
            }
        }

        StatusColorSelectorGrid {
            id: colorSelection
            Layout.alignment: Qt.AlignCenter
            title.text: qsTr("Colour")
            title.font.pixelSize: Constants.keycard.general.fontSize2
            model: Constants.preDefinedWalletAccountColors

            onSelectedColorChanged: {
                d.observedAccount.color = selectedColor
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
            tagClickable: true
            tagDisplayRemoveAccountButton: true
            keyPairType: root.sharedKeycardModule.keyPairForProcessing.pairType
            keyPairPubKey: root.sharedKeycardModule.keyPairForProcessing.pubKey
            keyPairName: root.sharedKeycardModule.keyPairForProcessing.name
            keyPairIcon: root.sharedKeycardModule.keyPairForProcessing.icon
            keyPairImage: root.sharedKeycardModule.keyPairForProcessing.image
            keyPairDerivedFrom: root.sharedKeycardModule.keyPairForProcessing.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.keyPairForProcessing.accounts
            keyPairCardLocked: root.sharedKeycardModule.keyPairForProcessing.locked

            onRemoveAccount: {
                d.accountIndexToBeRemoved = index
                d.accountNameToBeRemoved = name
                confirmationPopup.open()
            }

            onAccountClicked: {
                root.sharedKeycardModule.keyPairForProcessing.setAccountAtIndexAsObservedAccount(index)
            }
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.manageKeycardAccounts
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.manageKeycardAccounts
            PropertyChanges {
                target: title
                text: qsTr("Name accounts")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
        }
    ]
}
