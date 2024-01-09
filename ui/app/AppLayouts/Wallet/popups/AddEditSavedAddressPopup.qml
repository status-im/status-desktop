import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml.Models 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.controls 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1

import SortFilterProxyModel 0.2

import AppLayouts.stores 1.0

import "../stores"
import "../controls"
import ".."

StatusDialog {
    id: root

    property var allNetworks

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside    

    width: 477
    topPadding: 24 // (16 + 8 for Name, until we add it to the StatusInput component)
    bottomPadding: 28

    header: StatusDialogHeader {
        headline.title: d.editMode? qsTr("Edit saved address") : qsTr("Add new saved address")
        headline.subtitle: d.editMode? d.name : ""
        actions.closeButton.onClicked: root.close()
    }

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

        if (!!d.ens)
            addressInput.setPlainText(d.ens)
        else
            addressInput.setPlainText("%1%2"
                                      .arg(d.chainShortNames)
                                      .arg(d.address == Constants.zeroAddress? "" : d.address))

        nameInput.input.edit.forceActiveFocus(Qt.MouseFocusReason)
    }

    QtObject {
        id: d

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
        readonly property bool valid: addressInput.valid && nameInput.valid
        readonly property bool dirty: nameInput.input.dirty && (!d.editMode || d.storedName !== d.name)
                                      || chainShortNamesDirty && (!d.editMode || d.storedChainShortNames !== d.chainShortNames)
                                      || d.colorId.toUpperCase() !== d.storedColorId.toUpperCase()


        readonly property var chainPrefixRegexPattern: /[^:]+\:?|:/g
        readonly property bool addressInputIsENS: !!d.ens

        /// Ensures that the \c root.address and \c root.chainShortNames are not reset when the initial text is set
        property bool initialized: false

        function getPrefixArrayWithColumns(prefixStr) {
            return prefixStr.match(d.chainPrefixRegexPattern)
        }

        function resetAddressValues() {
            d.ens = ""
            d.address = Constants.zeroAddress
            d.chainShortNames = ""
            allNetworksModelCopy.setEnabledNetworks([])
        }

        function submit(event) {
            if (!d.valid
                || !d.dirty
                || event !== undefined && event.key !== Qt.Key_Return && event.key !== Qt.Key_Enter)
                return

            RootStore.createOrUpdateSavedAddress(d.name, d.address, d.ens, d.colorId, d.chainShortNames)
            root.close()
        }
    }

    Column {
        width: parent.width
        height: childrenRect.height

        spacing: Style.current.xlPadding

        StatusInput {
            id: nameInput
            implicitWidth: parent.width
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
                    name: "check-for-no-emojis"
                    validate: (value) => {
                                  return !Constants.regularExpressions.emoji.test(value)
                              }
                    errorMessage: Constants.errorMessages.emojRegExp
                },
                StatusRegularExpressionValidator {
                    regularExpression: Constants.regularExpressions.alphanumericalExpanded1
                    errorMessage: Constants.errorMessages.alphanumericalExpanded1RegExp
                },
                StatusValidator {
                    name: "check-saved-address-existence"
                    validate: (value) => {
                                  return !RootStore.savedAddressNameExists(value)
                                         || d.editMode && d.storedName == value
                              }
                    errorMessage: qsTr("Name already in use")
                }
            ]
            input.clearable: true
            input.rightPadding: 16

            onKeyPressed: {
                d.submit(event)
            }
        }

        StatusInput {
            id: addressInput
            implicitWidth: parent.width
            label: qsTr("Address")
            objectName: "savedAddressAddressInput"
            input.edit.objectName: "savedAddressAddressInputEdit"
            placeholderText: qsTr("Ethereum address")
            maximumHeight: 66
            input.implicitHeight: Math.min(Math.max(input.edit.contentHeight + topPadding + bottomPadding, minimumHeight), maximumHeight) // setting height instead does not work
            enabled: !(d.editMode || d.addAddress)
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: qsTr("Address must not be blank")
                },
                StatusValidator {
                    errorMessage: addressInput.plainText ? qsTr("Please enter a valid address or ENS name.") : ""
                    validate: function (t) {
                        return t !== Constants.zeroAddress && (Utils.isValidAddressWithChainPrefix(t) || Utils.isValidEns(t))
                            ? true : { actual: t }
                    }
                }
            ]

            input.edit.textFormat: TextEdit.RichText
            input.asset.name: addressInput.valid && !d.editMode ? "checkbox" : ""
            input.asset.color: enabled ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
            input.rightPadding: 16
            input.leftIcon: false

            multiline: true

            property string plainText: input.edit.getText(0, text.length)

            onTextChanged: {
                if (skipTextUpdate || !d.initialized)
                    return

                plainText = input.edit.getText(0, text.length)

                if (input.edit.previousText != plainText) {
                    let newText = plainText
                    const prefixAndAddress = Utils.splitToChainPrefixAndAddress(plainText)

                    if (!Utils.isLikelyEnsName(plainText)) {
                        newText = WalletUtils.colorizedChainPrefix(prefixAndAddress.prefix) +
                                  prefixAndAddress.address
                    }

                    setRichText(newText)

                    // Reset
                    if (plainText.length == 0) {
                        d.resetAddressValues()
                        return
                    }

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

                        let prefixArrWithColumn = d.getPrefixArrayWithColumns(prefixAndAddress.prefix)
                        if (!prefixArrWithColumn)
                            prefixArrWithColumn = []

                        allNetworksModelCopy.setEnabledNetworks(prefixArrWithColumn)
                    }
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
                let unknownPrefixes = prefixes.filter(e => {
                    for (let i = 0; i < allNetworksModelCopy.count; i++) {
                        if (e == allNetworksModelCopy.get(i).shortName)
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

        StatusColorSelectorGrid {
            id: colorSelection
            objectName: "addSavedAddressColor"
            width: parent.width
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
            title: "Network preference"
            implicitWidth: parent.width
            enabled: addressInput.valid && !d.addressInputIsENS
            defaultItemText: "Add networks"
            defaultItemImageSource: "add"
            rightButtonVisible: true

            property bool modelUpdateBlocked: false

            function blockModelUpdate(value) {
                modelUpdateBlocked = value
            }

            itemsModel: SortFilterProxyModel {
                sourceModel: allNetworksModelCopy
                filters: ValueFilter {
                    roleName: "isEnabled"
                    value: true
                }

                onCountChanged: {
                    if (!networkSelector.modelUpdateBlocked && d.initialized) {
                        // Initially source model is empty, filter proxy is also empty, but does
                        // extra work and mistakenly overwrites d.chainShortNames property
                        if (sourceModel.count != 0) {
                            const prefixAndAddress = Utils.splitToChainPrefixAndAddress(addressInput.plainText)
                            const syncedPrefix = addressInput.syncChainPrefixWithModel(prefixAndAddress.prefix, this)
                            d.chainShortNames = syncedPrefix
                            addressInput.setPlainText(syncedPrefix + prefixAndAddress.address)
                        }
                    }
                }
            }

            addButton.highlighted: networkSelectPopup.visible
            addButton.onClicked: {
                networkSelectPopup.openAtPosition(addButton.x, networkSelector.y + addButton.height + Style.current.xlPadding)
            }

            onItemClicked: function (item, index, mouse) {
                // Append first item
                if (index === 0 && defaultItem.visible)
                    networkSelectPopup.openAtPosition(defaultItem.x, networkSelector.y + defaultItem.height + Style.current.xlPadding)
            }

            onItemRightButtonClicked: function (item, index, mouse) {
                item.modelRef.isEnabled = !item.modelRef.isEnabled
                d.chainShortNamesDirty = true
            }
        }
    }

    NetworkSelectPopup {
        id: networkSelectPopup

        layer1Networks: SortFilterProxyModel {
            sourceModel: allNetworksModelCopy
            filters: ValueFilter {
                roleName: "layer"
                value: 1
            }
        }
        layer2Networks: SortFilterProxyModel {
            sourceModel: allNetworksModelCopy
            filters: ValueFilter {
                roleName: "layer"
                value: 2
            }
        }

        onToggleNetwork: (network) => {
            network.isEnabled = !network.isEnabled
            d.chainShortNamesDirty = true
        }

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        function openAtPosition(xPos, yPos) {
            x = xPos
            y = yPos
            open()
        }

        modal: true
        dim: false
    }

    footer: StatusDialogFooter {
        rightButtons:  ObjectModel {
            StatusButton {
                text: d.editMode? qsTr("Save") : qsTr("Add address")
                enabled: d.valid && d.dirty
                onClicked: {
                    d.submit()
                }
                objectName: "addSavedAddress"
            }
        }
    }

    CloneModel {
        id: allNetworksModelCopy

        sourceModel: root.allNetworks
        roles: ["layer", "chainId", "chainColor", "chainName","shortName", "iconUrl"]
        rolesOverride: [{ role: "isEnabled", transform: (modelData) => Boolean(false) }]

        function setEnabledNetworks(prefixArr) {
            networkSelector.blockModelUpdate(true)
            for (let i = 0; i < count; i++) {
                // Add only those chainShortNames to the model, that have column ":" at the end, making it a valid chain prefix
                setProperty(i, "isEnabled", prefixArr.includes(get(i).shortName + ":"))
            }
            networkSelector.blockModelUpdate(false)
        }
    }
}
