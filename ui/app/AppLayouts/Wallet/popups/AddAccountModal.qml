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
    readonly property int marginBetweenInputs: Style.dp(38)
    readonly property alias passwordValidationError: d.passwordValidationError

    property var emojiPopup: null

    header.title: qsTr("Generate an account")
    closePolicy: Popup.CloseOnEscape

    signal afterAddAccount()

    Timer {
        id: waitTimer

        interval: 1000
        running: false
        onTriggered: d.getDerivedAddressList()
    }

    Connections {
        target: emojiPopup
        enabled: root.opened

        function onEmojiSelected (emojiText, atCursor) {
            accountNameInput.input.icon.emoji = emojiText
        }
    }

    Connections {
        target: RootStore
        enabled: root.opened

        function onDerivedAddressesListChanged() {
            d.isPasswordCorrect = RootStore.derivedAddressesError.length === 0
        }

        function onDerivedAddressesErrorChanged() {
            if(Utils.isInvalidPasswordMessage(RootStore.derivedAddressesError))
                d.passwordValidationError = qsTr("Password must be at least %n character(s) long", "", root.minPswLen);

        }
    }

    QtObject {
        id: d

        readonly property int numOfItems: 100
        readonly property int pageNumber: 1

        property string passwordValidationError: ""
        property bool isPasswordCorrect: false

        function getDerivedAddressList() {
            if(advancedSelection.expandableItem.addAccountType === SelectGeneratedAccount.AddAccountType.ImportSeedPhrase
                    && !!advancedSelection.expandableItem.path
                    && !!advancedSelection.expandableItem.mnemonicText) {
                RootStore.getDerivedAddressListForMnemonic(advancedSelection.expandableItem.mnemonicText,
                                                           advancedSelection.expandableItem.path, numOfItems, pageNumber)
            } else if(!!advancedSelection.expandableItem.path && !!advancedSelection.expandableItem.derivedFromAddress
                      && (passwordInput.text.length > 0)) {
                RootStore.getDerivedAddressList(passwordInput.text, advancedSelection.expandableItem.derivedFromAddress,
                                                advancedSelection.expandableItem.path, numOfItems, pageNumber)
            }
        }

        function showPasswordError(errMessage) {
            if (errMessage) {
                if (Utils.isInvalidPasswordMessage(errMessage)) {
                    d.passwordValidationError = qsTr("Wrong password")
                    scroll.contentY = -scroll.padding
                } else {
                    console.warn(`Unhandled error case. Status-go message: ${errMessage}`)
                }
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

            switch(advancedSelection.expandableItem.addAccountType) {
            case SelectGeneratedAccount.AddAccountType.GenerateNew:
                errMessage = RootStore.generateNewAccount(passwordInput.text, accountNameInput.text, colorSelectionGrid.selectedColor,
                                                          accountNameInput.input.asset.emoji, advancedSelection.expandableItem.completePath,
                                                          advancedSelection.expandableItem.derivedFromAddress)
                break
            case SelectGeneratedAccount.AddAccountType.ImportSeedPhrase:
                errMessage = RootStore.addAccountsFromSeed(advancedSelection.expandableItem.mnemonicText, passwordInput.text,
                                                           accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.asset.emoji,
                                                           advancedSelection.expandableItem.completePath)
                break
            case SelectGeneratedAccount.AddAccountType.ImportPrivateKey:
                errMessage = RootStore.addAccountsFromPrivateKey(advancedSelection.expandableItem.privateKey, passwordInput.text,
                                                                 accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.asset.emoji)
                break
            case SelectGeneratedAccount.AddAccountType.WatchOnly:
                errMessage = RootStore.addWatchOnlyAccount(advancedSelection.expandableItem.watchAddress, accountNameInput.text,
                                                           colorSelectionGrid.selectedColor, accountNameInput.input.asset.emoji)
                break
            }

            nextButton.loading = false

            if (errMessage) {
                d.showPasswordError(errMessage)
            } else {
                root.afterAddAccount()
                root.close()
            }
        }
    }

    onOpened: {
        accountNameInput.input.asset.emoji = StatusQUtils.Emoji.getRandomEmoji(StatusQUtils.Emoji.size.verySmall)
        colorSelectionGrid.selectedColorIndex = Math.floor(Math.random() * colorSelectionGrid.model.length)
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    onClosed: {
        d.passwordValidationError = ""
        passwordInput.text = ""
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
        height: Style.dp(400)
        objectName: "AddAccountModalContent"

        Column {
            property alias accountNameInput: accountNameInput
            width: scroll.availableWidth
            spacing: Style.current.halfPadding
            topPadding: Style.dp(20)

            // To-Do Password hidden option not supported in StatusQ StatusInput
            Item {
                width: parent.width
                height: passwordInput.height
                visible: advancedSelection.expandableItem.addAccountType !== SelectGeneratedAccount.AddAccountType.WatchOnly
                Input {
                    id: passwordInput
                    anchors.fill: parent

                    placeholderText: qsTr("Enter your password...")
                    label: qsTr("Password")
                    textField.echoMode: TextInput.Password
                    validationError: d.passwordValidationError
                    textField.objectName: "accountModalPassword"
                    inputLabel.font.pixelSize: 15
                    inputLabel.font.weight: Font.Normal
                    onTextChanged: {
                        d.isPasswordCorrect = false
                        d.passwordValidationError = ""
                        waitTimer.restart()
                    }
                    onKeyPressed: {
                        if(event.key === Qt.Key_Tab) {
                            accountNameInput.input.edit.forceActiveFocus(Qt.MouseFocusReason)
                            event.accepted = true
                        }
                    }
                }
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
                    Component.onCompleted: advancedSelection.isValid = Qt.binding(() => isValid)
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: nextButton

            text: loading ? qsTr("Loading...") : qsTr("Add account")

            enabled: {
                if (loading) {
                    return false
                }

                return (advancedSelection.expandableItem.addAccountType === SelectGeneratedAccount.AddAccountType.WatchOnly || d.isPasswordCorrect)
                        && accountNameInput.text !== "" && advancedSelection.isValid
            }

            highlighted: focus

            Keys.onReturnPressed: d.generateNewAccount()
            onClicked : d.generateNewAccount()
        }
    ]
}
