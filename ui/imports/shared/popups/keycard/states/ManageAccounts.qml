import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared.popups 1.0
import shared.stores 1.0 as SharedStore

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
        property string observedImportingAccountShortAddress: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard?
                                                                  StatusQUtils.Utils.elideText(root.sharedKeycardModule.keyPairHelper.observedAccount.address, 6, 4)
                                                                : ""

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
            accountName.input.edit.forceActiveFocus()
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
                 root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase ||
                 root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard

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

        StatusStepper {
            id: stepper
            Layout.preferredWidth: Constants.keycard.general.keycardNameInputWidth
            Layout.alignment: Qt.AlignCenter
            titleFontSize: Constants.keycard.general.fontSize2
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignCenter
            font.weight: Font.Bold
        }

        Rectangle {
            id: accountDetails
            Layout.preferredWidth: Constants.keycard.general.keycardNameInputWidth
            Layout.alignment: Qt.AlignCenter
            height: Style.current.xlPadding * 2
            color: "transparent"
            border.color: Theme.palette.baseColor2
            border.width: 1
            radius: Style.current.halfPadding

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding

                ColumnLayout {
                    StatusBaseText {
                        text: d.observedImportingAccountShortAddress
                        wrapMode: Text.WordWrap
                        font.pixelSize: Constants.keycard.general.fontSize2
                        color: Theme.palette.baseColor1
                    }

                    StatusBaseText {
                        text: root.sharedKeycardModule.keyPairHelper.observedAccount.path
                        wrapMode: Text.WordWrap
                        font.pixelSize: Constants.keycard.general.fontSize2
                        color: Theme.palette.baseColor1
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                }

                ColumnLayout {
                    StatusBaseText {
                        text: {
                            return qsTr("Balance: %1").arg(LocaleUtils.currencyAmountToLocaleString({
                                        amount: parseFloat(root.sharedKeycardModule.keyPairHelper.observedAccount.balance),
                                        symbol: SharedStore.RootStore.currencyStore.currentCurrencySymbol,
                                        displayDecimals: 2}))
                        }
                        wrapMode: Text.WordWrap
                        font.pixelSize: Constants.keycard.general.fontSize2
                        color: Theme.palette.baseColor1
                    }

                    Row {
                        padding: 0

                        StatusBaseText {
                            text: qsTr("View on Etherscan")
                            wrapMode: Text.WordWrap
                            font.pixelSize: Constants.keycard.general.fontSize2
                            color: Theme.palette.baseColor1
                        }

                        StatusFlatRoundButton {
                            height: 20
                            width: 20
                            icon.name: "external"
                            icon.width: 16
                            icon.height: 16
                            onClicked: {
                                Qt.openUrlExternally("https://etherscan.io/address/%1".arg(root.sharedKeycardModule.keyPairHelper.observedAccount.address))
                            }
                        }
                    }
                }
            }
        }

        StatusInput {
            id: accountName
            Layout.preferredWidth: Constants.keycard.general.keycardNameInputWidth
            Layout.alignment: Qt.AlignCenter
            charLimit: Constants.keycard.general.keycardNameLength
            placeholderText: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard) {
                    return qsTr("What name should account %1 have?").arg(d.observedImportingAccountShortAddress)
                }

                return qsTr("What would you like this account to be called?")
            }
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

        StatusBaseText {
            Layout.alignment: Qt.AlignLeft
            text: qsTr("Preview")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.baseColor1
        }

        KeyPairItem {
            Layout.preferredWidth: parent.width
            tagClickable: true
            tagDisplayRemoveAccountButton: root.sharedKeycardModule.currentState.flowType !== Constants.keycardSharedFlow.importFromKeycard
            keyPairType: root.sharedKeycardModule.keyPairForProcessing.pairType
            keyPairKeyUid: root.sharedKeycardModule.keyPairForProcessing.keyUid
            keyPairName: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard?
                             root.sharedKeycardModule.keyPairHelper.name
                           : root.sharedKeycardModule.keyPairForProcessing.name
            keyPairIcon: root.sharedKeycardModule.keyPairForProcessing.icon
            keyPairImage: root.sharedKeycardModule.keyPairForProcessing.image
            keyPairDerivedFrom: root.sharedKeycardModule.keyPairForProcessing.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.keyPairForProcessing.accounts
            keyPairCardLocked: root.sharedKeycardModule.keyPairForProcessing.locked

            onRemoveAccount: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard)
                    return
                d.accountIndexToBeRemoved = index
                d.accountNameToBeRemoved = name
                confirmationPopup.open()
            }

            onAccountClicked: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard) {
                    root.sharedKeycardModule.keyPairHelper.setAccountAtIndexAsObservedAccount(index)
                }
                root.sharedKeycardModule.keyPairForProcessing.setAccountAtIndexAsObservedAccount(index)
            }
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.manageKeycardAccounts
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.manageKeycardAccounts
            PropertyChanges {
                target: stepper
                visible: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard &&
                         root.sharedKeycardModule.keyPairHelper.accounts.count > 1
                totalSteps: root.sharedKeycardModule.keyPairHelper.accounts.count
                completedSteps: root.sharedKeycardModule.keyPairForProcessing.accounts.count
                title: qsTr("Account %1 of %2").arg(completedSteps).arg(totalSteps)
            }
            PropertyChanges {
                target: title
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard) {
                        return qsTr("Name account %1").arg(d.observedImportingAccountShortAddress)
                    }

                    return qsTr("Name accounts")
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: accountDetails
                visible: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard &&
                         root.sharedKeycardModule.keyPairHelper.accounts.count > 1
            }
        }
    ]
}
