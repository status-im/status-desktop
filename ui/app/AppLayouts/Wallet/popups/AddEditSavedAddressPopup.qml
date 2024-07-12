import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0
import shared.stores 1.0 as SharedStores

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Popups 0.1

import SortFilterProxyModel 0.2

import AppLayouts.stores 1.0

import "../stores"
import "../controls"
import ".."

StatusModal {
    id: root

    property var flatNetworks

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    width: 477

    headerSettings.title: d.editMode? qsTr("Edit saved address") : qsTr("Add new saved address")
    headerSettings.subTitle: d.editMode? d.name : ""

    property var store: RootStore

    function initWithParams(params = {}) {
        d.storedName = params.name?? ""
        d.storedColorId = params.colorId?? ""
        d.storedChainShortNames = params.chainShortNames?? ""

        d.editMode = params.edit?? false
        d.addAddress = params.addAddress?? false
        d.name = d.storedName
        nameInput.input.dirty = false
        d.address = params.address?? Constants.zeroAddress
        d.ens = params.ens?? ""
        d.colorId = d.storedColorId
        d.chainShortNames = d.storedChainShortNames

        d.initialized = true

        if (d.colorId === "") {
            colorSelection.selectedColorIndex = Math.floor(Math.random() * colorSelection.model.length)
        }
        else {
            let ind = Utils.getColorIndexForId(d.colorId)
            colorSelection.selectedColorIndex = ind
        }

        if (d.addressInputIsENS)
            addressInput.setPlainText(d.ens)
        else
            addressInput.setPlainText("%1%2"
                                      .arg(d.chainShortNames)
                                      .arg(d.address == Constants.zeroAddress? "" : d.address))

        nameInput.input.edit.forceActiveFocus()
    }

    enum CardType {
        Contact,
        WalletAccount,
        SavedAddress
    }

    QtObject {
        id: d

        readonly property int componentWidth: 445

        property bool editMode: false
        property bool addAddress: false
        property alias name: nameInput.text
        property string address: Constants.zeroAddress // Setting as zero address since we don't have the address yet
        property string ens: ""
        property string colorId: ""
        property string chainShortNames: ""

        property string storedName: ""
        property string storedColorId: ""
        property string storedChainShortNames: ""

        property bool chainShortNamesDirty: false
        property var networkSelection: []

        onNetworkSelectionChanged: { 
            if (d.networkSelection !== networkSelectPopup.selection) {
                networkSelectPopup.selection = d.networkSelection
            }
        }

        property bool addressInputValid: d.editMode ||
                                         addressInput.input.dirty &&
                                         d.addressInputIsAddress &&
                                         !d.minAddressLengthRequestError &&
                                         !d.addressAlreadyAddedToWalletError &&
                                         !d.addressAlreadyAddedToSavedAddressesError
        readonly property bool valid: d.addressInputValid && nameInput.valid
        readonly property bool dirty: nameInput.input.dirty && (!d.editMode || d.storedName !== d.name)
                                      || chainShortNamesDirty && (!d.editMode || d.storedChainShortNames !== d.chainShortNames)
                                      || d.colorId.toUpperCase() !== d.storedColorId.toUpperCase()


        readonly property var chainPrefixRegexPattern: /[^:]+\:?|:/g
        readonly property bool addressInputIsENS: !!d.ens &&
                                                  Utils.isValidEns(d.ens)
        readonly property bool addressInputIsAddress: !!d.address &&
                                                      d.address != Constants.zeroAddress &&
                                                      (Utils.isAddress(d.address) || Utils.isValidAddressWithChainPrefix(d.address))
        readonly property bool addressInputHasError: !!addressInput.errorMessageCmp.text
        onAddressInputHasErrorChanged: addressInput.input.valid = !addressInputHasError // can't use binding because valid is overwritten in StatusInput
        readonly property string networksHiddenState: "networksHidden"

        property ListModel cardsModel: ListModel {}

        // possible errors/warnings
        readonly property int minAddressLen: 1
        property bool minAddressLengthRequestError: false
        property bool addressAlreadyAddedToWalletError: false
        property bool addressAlreadyAddedToSavedAddressesError: false
        property bool checkingContactsAddressInProgress: false
        property int contactsWithSameAddress: 0

        function checkIfAddressIsAlreadyAddedToWallet(address) {
            let account = root.store.getWalletAccount(address)
            d.cardsModel.clear()
            d.addressAlreadyAddedToWalletError = !!account.name
            if (!d.addressAlreadyAddedToWalletError) {
                return
            }
            d.cardsModel.append({
                                    type: AddEditSavedAddressPopup.CardType.WalletAccount,
                                    address: account.mixedcaseAddress,
                                    title: account.name,
                                    icon: "",
                                    emoji: account.emoji,
                                    color: Utils.getColorForId(account.colorId).toString().toUpperCase()
                                })
        }

        function checkIfAddressIsAlreadyAddedToSavedAddresses(address) {
            let savedAddress = root.store.getSavedAddress(address)
            d.cardsModel.clear()
            d.addressAlreadyAddedToSavedAddressesError = !!savedAddress.address
            if (!d.addressAlreadyAddedToSavedAddressesError) {
                return
            }
            d.cardsModel.append({
                                    type: AddEditSavedAddressPopup.CardType.SavedAddress,
                                    address: savedAddress.ens || savedAddress.address,
                                    title: savedAddress.name,
                                    icon: "",
                                    emoji: "",
                                    color: Utils.getColorForId(savedAddress.colorId).toString().toUpperCase()
                                })
        }

        property bool resolvingEnsNameInProgress: false
        readonly property string uuid: Utils.uuid()
        readonly property var validateEnsAsync: Backpressure.debounce(root, 500, function (value) {
            var name = value.startsWith("@") ? value.substring(1) : value
            mainModule.resolveENS(name, d.uuid)
        });

        property var contactsModuleInst: SharedStores.RootStore.profileSectionModuleInst.contactsModule

        /// Ensures that the \c root.address and \c root.chainShortNames are not reset when the initial text is set
        property bool initialized: false

        function getPrefixArrayWithColumns(prefixStr) {
            return prefixStr.match(d.chainPrefixRegexPattern)
        }

        function resetAddressValues(fullReset) {
            if (fullReset) {
                d.ens = ""
                d.address = Constants.zeroAddress
                d.chainShortNames = ""
                d.networkSelection = []
            }

            d.cardsModel.clear()
            d.resolvingEnsNameInProgress = false
            d.checkingContactsAddressInProgress = false
        }

        function checkForAddressInputOwningErrorsWarnings() {
            d.addressAlreadyAddedToWalletError = false
            d.addressAlreadyAddedToSavedAddressesError = false

            if (d.addressInputIsAddress) {
                d.checkIfAddressIsAlreadyAddedToWallet(d.address)
                if (d.addressAlreadyAddedToWalletError) {
                    addressInput.errorMessageCmp.text = qsTr("You cannot add your own account as a saved address")
                    addressInput.errorMessageCmp.visible = true
                    return
                }
                d.checkIfAddressIsAlreadyAddedToSavedAddresses(d.address)
                if (d.addressAlreadyAddedToSavedAddressesError) {
                    addressInput.errorMessageCmp.text = qsTr("This address is already saved")
                    addressInput.errorMessageCmp.visible = true
                    return
                }

                d.checkingContactsAddressInProgress = true
                d.contactsWithSameAddress = 0
                d.contactsModuleInst.fetchProfileShowcaseAccountsByAddress(d.address)
                return
            }

            addressInput.errorMessageCmp.text = qsTr("Not registered ens address")
            addressInput.errorMessageCmp.visible = true
        }

        function checkForAddressInputErrorsWarnings() {
            addressInput.errorMessageCmp.visible = false
            addressInput.errorMessageCmp.color = Theme.palette.dangerColor1
            addressInput.errorMessageCmp.text = ""

            d.minAddressLengthRequestError = false

            if (d.editMode || !addressInput.input.dirty) {
                return
            }

            if (d.addressInputIsENS || d.addressInputIsAddress) {
                let value = d.ens || d.address
                if (value.trim().length < d.minAddressLen) {
                    d.minAddressLengthRequestError = true
                    addressInput.errorMessageCmp.text = qsTr("Please enter an ethereum address")
                    addressInput.errorMessageCmp.visible = true
                    return
                }
            }

            if (d.addressInputIsENS) {
                d.resolvingEnsNameInProgress = true
                d.validateEnsAsync(d.ens)
                return
            }

            networkSelector.state = ""
            if (d.addressInputIsAddress) {
                d.checkForAddressInputOwningErrorsWarnings()
                return
            }

            addressInput.errorMessageCmp.text = qsTr("Ethereum address invalid")
            addressInput.errorMessageCmp.visible = true
        }

        function submit(event) {
            if (!d.valid
                    || !d.dirty
                    || event !== undefined && event.key !== Qt.Key_Return && event.key !== Qt.Key_Enter)
                return

            root.store.createOrUpdateSavedAddress(d.name, d.address, d.ens, d.colorId, d.chainShortNames)
            root.close()
        }
    }

    Connections {
        target: mainModule
        function onResolvedENS(resolvedPubKey: string, resolvedAddress: string, uuid: string) {
            if (uuid !== d.uuid) {
                return
            }

            d.resolvingEnsNameInProgress = false
            d.address = resolvedAddress
            try { // allows to avoid issues in storybook without much refactoring
                d.checkForAddressInputOwningErrorsWarnings()
            }
            catch (e) {
            }

            if (!d.addressInputHasError)
                networkSelector.state = d.networksHiddenState
            else
                networkSelector.state = ""
        }
    }

    Connections {
        target: d.contactsModuleInst
        function onProfileShowcaseAccountsByAddressFetched(accounts: string) {
            d.cardsModel.clear()
            d.checkingContactsAddressInProgress = false
            try {
                let accountsJson = JSON.parse(accounts)
                d.contactsWithSameAddress = accountsJson.length
                addressInput.errorMessageCmp.visible = d.contactsWithSameAddress > 0
                addressInput.errorMessageCmp.color = Theme.palette.warningColor1
                addressInput.errorMessageCmp.text = ""
                if (d.contactsWithSameAddress === 1)
                    addressInput.errorMessageCmp.text = qsTr("This address belongs to a contact")
                if (d.contactsWithSameAddress > 1)
                    addressInput.errorMessageCmp.text = qsTr("This address belongs to the following contacts")

                for (let i = 0; i < accountsJson.length; ++i) {
                    let contact = Utils.getContactDetailsAsJson(accountsJson[i].contactId, true, true, true)
                    d.cardsModel.append({
                                            type: AddEditSavedAddressPopup.CardType.Contact,
                                            address: accountsJson[i].address,
                                            title: ProfileUtils.displayName(contact.localNickname, contact.name, contact.displayName, contact.alias),
                                            icon: contact.icon,
                                            emoji: "",
                                            color: Utils.colorForColorId(contact.colorId),
                                            onlineStatus: contact.onlineStatus,
                                            colorHash: contact.colorHash
                                        })

                }
            }
            catch (e) {
                console.warn("error parsing fetched accounts for contact: ", e.message)
            }
        }
    }

    StatusScrollView {
        id: scrollView

        anchors.fill: parent
        padding: 0
        contentWidth: availableWidth

        Column {
            id: column

            width: scrollView.availableWidth
            height: childrenRect.height

            topPadding: 24 // (16 + 8 for Name, until we add it to the StatusInput component)
            bottomPadding: 28

            spacing: Style.current.xlPadding

            StatusInput {
                id: nameInput
                implicitWidth: d.componentWidth
                anchors.horizontalCenter: parent.horizontalCenter
                charLimit: 24
                input.edit.objectName: "savedAddressNameInput"
                placeholderText: qsTr("Address name")
                label: qsTr("Name")
                validators: [
                    StatusMinLengthValidator {
                        minLength: 1
                        errorMessage: qsTr("Please name your saved address")
                    },
                    StatusValidator {
                        property bool isEmoji: false

                        name: "check-for-no-emojis"
                        validate: (value) => {
                                      if (!value) {
                                          return true
                                      }

                                      isEmoji = Constants.regularExpressions.emoji.test(value)
                                      if (isEmoji){
                                          return false
                                      }

                                      return Constants.regularExpressions.alphanumericalExpanded1.test(value)
                                  }
                        errorMessage: isEmoji?
                                          Constants.errorMessages.emojRegExp
                                        : Constants.errorMessages.alphanumericalExpanded1RegExp
                    },
                    StatusValidator {
                        name: "check-saved-address-existence"
                        validate: (value) => {
                                      return !root.store.savedAddressNameExists(value)
                                      || d.editMode && d.storedName == value
                                  }
                        errorMessage: qsTr("Name already in use")
                    }
                ]
                input.clearable: true
                input.rightPadding: 16
                input.tabNavItem: addressInput

                onKeyPressed: {
                    d.submit(event)
                }
            }

            StatusInput {
                id: addressInput
                implicitWidth: d.componentWidth
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Address")
                objectName: "savedAddressAddressInput"
                input.edit.objectName: "savedAddressAddressInputEdit"
                placeholderText: qsTr("Ethereum address")
                maximumHeight: 66
                input.implicitHeight: Math.min(Math.max(input.edit.contentHeight + topPadding + bottomPadding, minimumHeight), maximumHeight) // setting height instead does not work
                enabled: !(d.editMode || d.addAddress)
                input.edit.textFormat: TextEdit.RichText
                input.rightComponent: (d.resolvingEnsNameInProgress || d.checkingContactsAddressInProgress) ?
                    loadingIndicator : null
                input.asset.name: d.addressInputValid && !d.editMode ? "checkbox" : ""
                input.asset.color: enabled ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                input.asset.width: 17
                input.asset.height: 17
                input.rightPadding: 16
                input.leftIcon: false
                input.tabNavItem: nameInput

                multiline: true

                property string plainText: input.edit.getText(0, text.length).trim()

                Component {
                    id: loadingIndicator

                    StatusLoadingIndicator {}
                }

                onTextChanged: {
                    if (skipTextUpdate || !d.initialized)
                        return

                    plainText = input.edit.getText(0, text.length).trim()

                    if (input.edit.previousText != plainText) {
                        let newText = plainText
                        const prefixAndAddress = Utils.splitToChainPrefixAndAddress(plainText)

                        if (!Utils.isLikelyEnsName(plainText)) {
                            newText = WalletUtils.colorizedChainPrefix(prefixAndAddress.prefix) +
                                    prefixAndAddress.address
                        }

                        setRichText(newText)

                        // Reset
                        d.resetAddressValues(plainText.length == 0)

                        if (plainText.length > 0) {
                            // Update root values
                            if (Utils.isLikelyEnsName(plainText)) {
                                d.ens = plainText
                                d.address = Constants.zeroAddress
                                d.chainShortNames = ""
                            }
                            else {
                                d.ens = ""
                                d.address = prefixAndAddress.address
                                d.chainShortNames = prefixAndAddress.prefix
                                
                                Qt.callLater(()=> {
                                    // Sync chain short names with model. This could result in removing networks from this text
                                    // Call it later to avoid binding loop warnings
                                    d.networkSelection = store.getNetworkIds(d.chainShortNames).split(":").filter(Boolean).map(Number)
                            })
                            }
                        }

                        d.checkForAddressInputErrorsWarnings()
                    }
                }

                onKeyPressed: {
                    d.submit(event)
                }

                property bool skipTextUpdate: false

                function setPlainText(newText) {
                    text = newText
                }

                function setRichText(val) {
                    skipTextUpdate = true
                    input.edit.previousText = plainText
                    const curPos = input.cursorPosition
                    setPlainText(val)
                    input.cursorPosition = curPos
                    skipTextUpdate = false
                }

                function getUnknownPrefixes(prefixes) {
                    const networksCount = root.flatNetworks.rowCount()
                    let unknownPrefixes = prefixes.filter(e => {
                                                              for (let i = 0; i < networksCount; i++) {
                                                                  if (e == StatusQUtils.ModelUtils.get(root.flatNetworks, i).shortName)
                                                                  return false
                                                              }
                                                              return true
                                                          })

                    return unknownPrefixes
                }

                // Add all chain short names from model, while keeping existing
                function syncChainPrefixWithModel(prefix, model) {
                    let prefixes = prefix.split(":").filter(Boolean)
                    let prefixStr = ""

                    // Keep unknown prefixes from user input, the rest must be taken
                    // from the model
                    for (let i = 0; i < model.count; i++) {
                        const item = model.get(i)
                        prefixStr += item.shortName + ":"
                        // Remove all added prefixes from initial array
                        prefixes = prefixes.filter(e => e !== item.shortName)
                    }

                    const unknownPrefixes = getUnknownPrefixes(prefixes)
                    if (unknownPrefixes.length > 0) {
                        prefixStr += unknownPrefixes.join(":") + ":"
                    }

                    return prefixStr
                }
            }

            Column {
                width: scrollView.availableWidth
                visible: d.cardsModel.count > 0

                spacing: Style.current.halfPadding

                Repeater {
                    model: d.cardsModel

                    StatusListItem {
                        width: d.componentWidth
                        border.width: 1
                        border.color: Theme.palette.baseColor2
                        anchors.horizontalCenter: parent.horizontalCenter
                        title: model.title
                        subTitle: model.address
                        statusListItemSubTitle.font.pixelSize: 12
                        sensor.hoverEnabled: false
                        statusListItemIcon.badge.visible: model.type === AddEditSavedAddressPopup.CardType.Contact
                        statusListItemIcon.badge.color: model.type === AddEditSavedAddressPopup.CardType.Contact && model.onlineStatus === 1?
                                                            Theme.palette.successColor1
                                                          : Theme.palette.baseColor1
                        statusListItemIcon.hoverEnabled: false
                        ringSettings.ringSpecModel: model.type === AddEditSavedAddressPopup.CardType.Contact? model.colorHash : ""

                        asset {
                            width: 40
                            height: 40
                            name: model.icon
                            isImage: model.icon !== ""
                            emoji: model.emoji
                            color: model.color
                            isLetterIdenticon: !model.icon
                            letterIdenticonBgWithAlpha: model.type === AddEditSavedAddressPopup.CardType.SavedAddress
                            charactersLen: 2
                        }
                    }
                }
            }

            StatusColorSelectorGrid {
                id: colorSelection
                objectName: "addSavedAddressColor"
                width: d.componentWidth
                anchors.horizontalCenter: parent.horizontalCenter
                model: Theme.palette.customisationColorsArray
                title.color: Theme.palette.directColor1
                title.font.pixelSize: Constants.addAccountPopup.labelFontSize1
                title.text: qsTr("Colour")
                selectedColorIndex: -1

                onSelectedColorChanged: {
                    d.colorId = Utils.getIdForColor(selectedColor)
                }
            }

            StatusNetworkSelector {
                id: networkSelector

                objectName: "addSavedAddressNetworkSelector"
                title: qsTr("Network preference")
                implicitWidth: d.componentWidth
                anchors.horizontalCenter: parent.horizontalCenter

                enabled: d.addressInputValid && !d.addressInputIsENS
                visible: !(d.editMode && d.addressInputIsENS)
                defaultItemText: qsTr("Add networks")
                defaultItemImageSource: "add"
                rightButtonVisible: true

                itemsModel: SortFilterProxyModel {
                    sourceModel: root.flatNetworks
                    filters: FastExpressionFilter {
                        readonly property var filteredNetworks: d.networkSelection
                        expression: {
                            return filteredNetworks.length > 0 && filteredNetworks.includes(model.chainId)
                        }
                        expectedRoles: ["chainId"]
                    }

                    onCountChanged: {
                        if (d.initialized) {
                            // Initially source model is empty, filter proxy is also empty, but does
                            // extra work and mistakenly overwrites d.chainShortNames property
                            if (sourceModel.count != 0) {
                                const prefixAndAddress = Utils.splitToChainPrefixAndAddress(addressInput.plainText)
                                const syncedPrefix = addressInput.syncChainPrefixWithModel(prefixAndAddress.prefix, this)
                                if (addressInput.text !== syncedPrefix + prefixAndAddress.address)
                                    addressInput.setPlainText(syncedPrefix + prefixAndAddress.address)
                            }
                        }
                    }
                }

                addButton.highlighted: networkSelectPopup.visible
                addButton.onClicked: {
                    networkSelectPopup.openAtPosition(addButton.x, addButton.height + Style.current.xlPadding)
                }

                onItemClicked: function (item, index, mouse) {
                    // Append first item
                    if (index === 0 && defaultItem.visible)
                        networkSelectPopup.openAtPosition(defaultItem.x, defaultItem.height + Style.current.xlPadding)
                }

                onItemRightButtonClicked: function (item, index, mouse) {
                    let networkSelection = [...d.networkSelection]
                    d.networkSelection = networkSelection.filter(n => n !== item.modelRef.chainId)
                    d.chainShortNamesDirty = true
                }

                readonly property int animationDuration: 350
                states: [
                    // As when networks seclector becomes invisible, spacing before it disappears as well, we see jumping height
                    // To overcome this, we animate bottom padding to 0 and when spacing disappears, reset bottom padding to spacing to compensate it
                    State {
                        name: d.networksHiddenState
                        PropertyChanges { target: networkSelector; height: 0 }
                        PropertyChanges { target: networkSelector;  opacity: 0 }
                        PropertyChanges { target: column; bottomPadding: 0 }
                    }
                ]
                transitions: [
                    Transition {
                        NumberAnimation { property: "height"; duration: networkSelector.animationDuration; easing.type: Easing.OutCirc }
                        NumberAnimation { property: "opacity"; duration: networkSelector.animationDuration; easing.type: Easing.OutCirc}
                        SequentialAnimation {
                            NumberAnimation { property: "bottomPadding"; duration: networkSelector.animationDuration; easing.type: Easing.OutCirc }
                            PropertyAction { target: column; property: "bottomPadding"; value: column.spacing }
                        }
                    }
                ]

                NetworkSelectPopup {
                    id: networkSelectPopup

                    function openAtPosition(x, y) {
                        networkSelectPopup.x = x
                        networkSelectPopup.y = y
                        networkSelectPopup.open()
                    }

                    flatNetworks: root.flatNetworks
                    selection: d.networkSelection
                    multiSelection: true

                    onSelectionChanged: {
                        if (d.networkSelection !== networkSelectPopup.selection) {
                            d.networkSelection = networkSelectPopup.selection
                            d.chainShortNamesDirty = true
                        }
                    }

                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                    modal: true
                    dim: false
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            text: d.editMode? qsTr("Save") : qsTr("Add address")
            enabled: d.valid && d.dirty
            onClicked: {
                d.submit()
            }
            objectName: "addSavedAddress"
        }
    ]
}
