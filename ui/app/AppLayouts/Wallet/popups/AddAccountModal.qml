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

    readonly property int marginBetweenInputs: 38
    property var emojiPopup: null

    header.title: qsTr("Generate an account")
    closePolicy: nextButton.loading? Popup.NoAutoClose : Popup.CloseOnEscape
    hasCloseButton: !nextButton.loading

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
        function onUserAuthenticationSuccess(password: string) {
            validationError.text = ""
            d.password = password
            RootStore.loggedInUserAuthenticated = true
            if (d.selectedAccountType === Constants.AddAccountType.ImportPrivateKey) {
                d.generateNewAccount()
            }
            else {
                if (!d.selectedKeyUidMigratedToKeycard) {
                    d.getDerivedAddressList()
                }
            }
        }
        function onUserAuthentiactionFail() {
            d.password = ""
            RootStore.loggedInUserAuthenticated = false
            validationError.text = qsTr("An authentication failed")
            nextButton.loading = false
        }
    }

    QtObject {
        id: d

        readonly property int numOfItems: 100
        readonly property int pageNumber: 1

        property string password: ""
        property int selectedAccountType: Constants.AddAccountType.GenerateNew
        property string selectedAccountDerivedFromAddress: ""
        property string selectedKeyUid: RootStore.defaultSelectedKeyUid
        property bool selectedKeyUidMigratedToKeycard: RootStore.defaultSelectedKeyUidMigratedToKeycard
        property string selectedPath: ""
        property string selectedAddress: ""
        property bool selectedAddressAvailable: true

        readonly property bool authenticationNeeded: d.selectedAccountType !== Constants.AddAccountType.WatchOnly &&
                                                     d.password === ""
        property string addAccountIcon: ""

        property bool isLoading: RootStore.derivedAddressesLoading
        onIsLoadingChanged:  {
            if(!isLoading && nextButton.loading) {
                d.generateNewAccount()
            }
        }

        function getDerivedAddressList() {
            if(d.selectedAccountType === Constants.AddAccountType.ImportSeedPhrase
                    && !!advancedSelection.expandableItem.path
                    && !!advancedSelection.expandableItem.mnemonicText) {
                RootStore.getDerivedAddressListForMnemonic(advancedSelection.expandableItem.mnemonicText,
                                                           advancedSelection.expandableItem.path, numOfItems, pageNumber)
            } else if(!!d.selectedPath && !!d.selectedAccountDerivedFromAddress
                      && (d.password.length > 0)) {
                RootStore.getDerivedAddressList(d.password, d.selectedAccountDerivedFromAddress,
                                                d.selectedPath, numOfItems, pageNumber,
                                                !(d.selectedKeyUidMigratedToKeycard || userProfile.isKeycardUser))
            }
        }

        function generateNewAccount() {
            // TODO the loading doesn't work because the function freezes the view. Might need to use threads
            if (!advancedSelection.validate()) {
                Global.playErrorSound()
                return nextButton.loading = false
            }

            let errMessage = ""

            switch(d.selectedAccountType) {
            case Constants.AddAccountType.GenerateNew:
                if (d.selectedKeyUidMigratedToKeycard) {
                    errMessage = RootStore.addNewWalletAccountGeneratedFromKeycard(Constants.generatedWalletType,
                                                                                   accountNameInput.text,
                                                                                   colorSelectionGrid.selectedColor,
                                                                                   accountNameInput.input.asset.emoji)
                }
                else {
                errMessage = RootStore.generateNewAccount(d.password, accountNameInput.text, colorSelectionGrid.selectedColor,
                                                          accountNameInput.input.asset.emoji, advancedSelection.expandableItem.completePath,
                                                          advancedSelection.expandableItem.derivedFromAddress)
                }
                break
            case Constants.AddAccountType.ImportSeedPhrase:
                errMessage = RootStore.addAccountsFromSeed(advancedSelection.expandableItem.mnemonicText, d.password,
                                                           accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.asset.emoji,
                                                           advancedSelection.expandableItem.completePath)
                break
            case Constants.AddAccountType.ImportPrivateKey:
                errMessage = RootStore.addAccountsFromPrivateKey(advancedSelection.expandableItem.privateKey, d.password,
                                                                 accountNameInput.text, colorSelectionGrid.selectedColor, accountNameInput.input.asset.emoji)
                break
            case Constants.AddAccountType.WatchOnly:
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
            nextButton.loading = true
            if (d.authenticationNeeded) {
                d.password = ""
                if (d.selectedKeyUidMigratedToKeycard &&
                        d.selectedAccountType === Constants.AddAccountType.GenerateNew) {
                    RootStore.authenticateUserAndDeriveAddressOnKeycardForPath(d.selectedKeyUid, d.selectedPath)
                }
                else {
                    RootStore.authenticateUser()
                }
            }
            else {
                d.generateNewAccount()
            }
        }
    }

    onOpened: {
        RootStore.loggedInUserAuthenticated = false
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
        RootStore.loggedInUserAuthenticated = false
        d.password = ""
        validationError.text = ""
        accountNameInput.reset()
        advancedSelection.expanded = false
        advancedSelection.reset()
    }

    contentItem: StatusScrollView {
        id: scroll
        width: root.width
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
                enabled: accountNameInput.valid
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
                    onCalculateDerivedPath: {
                        if (d.selectedKeyUidMigratedToKeycard) {
                            d.password = ""
                            validationError.text = ""
                            RootStore.loggedInUserAuthenticated = false
                        }
                        else{
                            d.getDerivedAddressList()
                        }
                    }
                    onEnterPressed: {
                        if (nextButton.enabled) {
                            nextButton.clicked(null)
                            return
                        }
                    }

                    Component.onCompleted: {
                        d.selectedAccountType = Qt.binding(() => addAccountType)
                        d.selectedAccountDerivedFromAddress = Qt.binding(() => derivedFromAddress)
                        d.selectedKeyUid = Qt.binding(() => selectedKeyUid)
                        d.selectedKeyUidMigratedToKeycard = Qt.binding(() => selectedKeyUidMigratedToKeycard)
                        d.selectedPath = Qt.binding(() => path)
                        d.selectedAddress = Qt.binding(() => selectedAddress)
                        d.selectedAddressAvailable = Qt.binding(() => selectedAddressAvailable)
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
                if (loading) {
                    return qsTr("Loading...")
                }
                return qsTr("Add account")
            }


            enabled: {
                if (!accountNameInput.valid) {
                    return false
                }
                if (loading) {
                    return false
                }
                return advancedSelection.isValid
            }

            icon.name: d.authenticationNeeded? d.addAccountIcon : ""
            highlighted: focus

            onClicked : d.nextButtonClicked()
        }
    ]
}
