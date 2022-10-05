import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import shared.controls 1.0

import "../stores"
import "../views"
import "../panels"

StatusModal {
    id: root

    property int minPswLen: 10
    readonly property int marginBetweenInputs: 38
    property var emojiPopup: null

    header.title: qsTr("Generate an account")
    closePolicy: Popup.CloseOnEscape

    signal afterAddAccount()

    Connections {
        target: emojiPopup
        enabled: root.opened

        function onEmojiSelected (emojiText, atCursor) {
            accountNameInput.input.asset.emoji = emojiText
        }
    }

    Connections {
        target: walletSectionAccounts
        onUserAuthenticationSuccess: {
            validationError.text = ""
            d.password = password
            d.getDerivedAddressList()
        }
        onUserAuthentiactionFail: {
            d.password = ""
            validationError.text = qsTr("An authentication failed")
        }
    }

    QtObject {
        id: d

        readonly property int numOfItems: 100
        readonly property int pageNumber: 1

        property string password: ""
        property int selectedAccountType: SelectGeneratedAccount.AddAccountType.GenerateNew
        readonly property bool authenticationNeeded: d.selectedAccountType !== SelectGeneratedAccount.AddAccountType.WatchOnly &&
                                                     d.password === ""
        property string addAccountIcon: ""




        function getDerivedAddressList() {
            if(d.selectedAccountType === SelectGeneratedAccount.AddAccountType.ImportSeedPhrase
                    && !!advancedSelection.expandableItem.path
                    && !!advancedSelection.expandableItem.mnemonicText) {
                RootStore.getDerivedAddressListForMnemonic(advancedSelection.expandableItem.mnemonicText,
                                                           advancedSelection.expandableItem.path, numOfItems, pageNumber)
            } else if(!!advancedSelection.expandableItem.path && !!advancedSelection.expandableItem.derivedFromAddress
                      && (d.password.length > 0)) {
                RootStore.getDerivedAddressList(d.password, advancedSelection.expandableItem.derivedFromAddress,
                                                advancedSelection.expandableItem.path, numOfItems, pageNumber)
            }
        }

        function generateNewAccount() {
            // TODO the loading doesn't work because the function freezes the view. Might need to use threads
            nextButton.loading = true
            if (!advancedSelection.validate()) {
                Global.playErrorSound()
                return nextButton.loading = false
            }

            let errMessage = ""

            switch(d.selectedAccountType) {
            case SelectGeneratedAccount.AddAccountType.GenerateNew:
                errMessage = RootStore.generateNewAccount(d.password, accountNameInput.text, colorSelectionGrid.selectedColor,
                                                          accountNameInput.input.asset.emoji, advancedSelection.expandableItem.completePath,
                                                          advancedSelection.expandableItem.derivedFromAddress)
                break
            case SelectGeneratedAccount.AddAccountType.ImportSeedPhrase:
                errMessage = RootStore.addAccountsFromSeed(advancedSelection.expandableItem.mnemonicText, d.password,
                                                           accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.asset.emoji,
                                                           advancedSelection.expandableItem.completePath)
                break
            case SelectGeneratedAccount.AddAccountType.ImportPrivateKey:
                errMessage = RootStore.addAccountsFromPrivateKey(advancedSelection.expandableItem.privateKey, d.password,
                                                                 accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.asset.emoji)
                break
            case SelectGeneratedAccount.AddAccountType.WatchOnly:
                errMessage = RootStore.addWatchOnlyAccount(advancedSelection.expandableItem.watchAddress, accountNameInput.text,
                                                           colorSelectionGrid.selectedColor, accountNameInput.input.asset.emoji)
                break
            }

            nextButton.loading = false

            if (errMessage) {
                console.warn(`Unhandled error case. Status-go message: ${errMessage}`)
            } else {
                root.afterAddAccount()
                root.close()
            }
        }

        function nextButtonClicked() {
            if (d.authenticationNeeded) {
                d.password = ""
                RootStore.authenticateUser()
            }
            else {
                d.generateNewAccount()
            }
        }
    }

    onOpened: {
        d.addAccountIcon = "password"
        if (RootStore.loggedInUserUsesBiometricLogin()) {
            d.addAccountIcon = "touch-id"
        }
        else if (RootStore.loggedInUserIsKeycardUser()) {
            d.addAccountIcon =  "keycard"
        }

        accountNameInput.input.asset.emoji = StatusQUtils.Emoji.getRandomEmoji(StatusQUtils.Emoji.size.verySmall)
        colorSelectionGrid.selectedColorIndex = Math.floor(Math.random() * colorSelectionGrid.model.length)
        accountNameInput.input.edit.forceActiveFocus()
    }

    onClosed: {
        d.password = ""
        validationError.text = ""
        accountNameInput.reset()
        advancedSelection.expanded = false
        advancedSelection.reset()
    }

    contentItem: StatusScrollView {
        id: scroll
        width: popup.width
        topPadding: Style.current.halfPadding
        bottomPadding: Style.current.halfPadding
        leftPadding: Style.current.padding
        rightPadding: Style.current.padding
        height: 400
        objectName: "AddAccountModalContent"

        Column {
            property alias accountNameInput: accountNameInput
            width: scroll.availableWidth
            spacing: Style.current.halfPadding
            topPadding: 20

            StatusBaseText {
                id: validationError
                visible: text !== ""
                width: parent.width
                height: 16
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 12
                color: Style.current.danger
                wrapMode: TextEdit.Wrap
            }

            StatusInput {
                id: accountNameInput
                placeholderText: qsTr("Enter an account name...")
                label: qsTr("Account name")
                input.isIconSelectable: true
                input.asset.color: colorSelectionGrid.selectedColor ? colorSelectionGrid.selectedColor : Theme.palette.directColor1
                input.leftPadding: Style.current.padding
                onIconClicked: {
                    root.emojiPopup.open()
                    root.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall
                    root.emojiPopup.x = root.x + accountNameInput.x + Style.current.padding
                    root.emojiPopup.y = root.y + contentItem.y + accountNameInput.y + accountNameInput.height +  Style.current.halfPadding
                }
                validators: [
                    StatusMinLengthValidator {
                        errorMessage: qsTr("You need to enter an account name")
                        minLength: 1
                    }
                ]
                onKeyPressed: {
                    if(event.key === Qt.Key_Tab) {
                        if (nextButton.enabled) {
                            nextButton.forceActiveFocus(Qt.MouseFocusReason)
                            event.accepted = true
                        }
                    }
                }
            }

            StatusColorSelectorGrid {
                id: colorSelectionGrid
                anchors.horizontalCenter: parent.horizontalCenter
                titleText: qsTr("color").toUpperCase()
            }

            StatusExpandableItem {
                id: advancedSelection

                property bool isValid: true

                function validate() {
                    return !!expandableItem && expandableItem.validate()
                }

                function reset() {
                    return !!expandableItem && expandableItem.reset()
                }

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width

                primaryText: qsTr("Advanced")
                type: StatusExpandableItem.Type.Tertiary
                expandable: true
                expandableComponent: AdvancedAddAccountView {
                    width: parent.width
                    onCalculateDerivedPath: d.getDerivedAddressList()
                    onEnterPressed: {
                        if (nextButton.enabled) {
                            nextButton.clicked(null)
                            return
                        }
                    }

                    onAddAccountTypeChanged: {
                        d.selectedAccountType = addAccountType
                    }

                    Component.onCompleted: {
                        d.selectedAccountType = addAccountType
                        advancedSelection.isValid = Qt.binding(() => isValid)
                    }
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: nextButton

            text: {
                if (d.authenticationNeeded) {
                    return qsTr("Authenticate")
                }
                if (loading) {
                    return qsTr("Loading...")
                }
                return qsTr("Add account")
            }


            enabled: {
                if (d.authenticationNeeded) {
                    return true
                }
                if (loading) {
                    return false
                }
                return accountNameInput.text !== "" && advancedSelection.isValid
            }

            icon.name: d.authenticationNeeded? d.addAccountIcon : ""
            highlighted: focus

            Keys.onReturnPressed: d.nextButtonClicked()
            onClicked : d.nextButtonClicked()
        }
    ]
}
