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

    closePolicy: Popup.CloseOnEscape

    property bool edit: false
    property bool addAddress: false
    property string address: Constants.zeroAddress // Setting as zero address since we don't have the address yet
    property string chainShortNames
    property string ens

    property alias name: nameInput.text
    property bool favourite: false
    property var contactsStore
    property var store

    signal save(string name, string address, string chainShortNames, string ens)

    QtObject {
        id: d
        readonly property int validationMode: root.edit ?
                                         StatusInput.ValidationMode.Always
                                       : StatusInput.ValidationMode.OnlyWhenDirty
        readonly property bool valid: addressInput.valid && nameInput.valid
        property bool chainShortNamesDirty: false
        readonly property bool dirty: nameInput.input.dirty || chainShortNamesDirty

        readonly property var chainPrefixRegexPattern: /[^:]+\:?|:/g
        readonly property string visibleAddress: root.address == Constants.zeroAddress ? "" : root.address
        readonly property bool addressInputIsENS: !!root.ens

        /// Ensures that the \c root.address and \c root.chainShortNames are not reset when the initial text is set
        property bool initialized: false

        function getPrefixArrayWithColumns(prefixStr) {
            return prefixStr.match(d.chainPrefixRegexPattern)
        }

        function resetAddressValues() {
            root.ens = ""
            root.address = Constants.zeroAddress
            root.chainShortNames = ""
            allNetworksModelCopy.setEnabledNetworks([])
        }
    }

    width: 574
    height: 490

    header: StatusDialogHeader {
        headline.title: edit ? qsTr("Edit saved address") : qsTr("Add saved address")
        headline.subtitle: edit ? name : ""
        actions.closeButton.onClicked: root.close()
    }

    onOpened: {
        d.initialized = true

        if(edit || addAddress) {
            if (root.ens)
                addressInput.setPlainText(root.ens)
            else
                addressInput.setPlainText(root.chainShortNames + d.visibleAddress)
        }
        nameInput.input.edit.forceActiveFocus(Qt.MouseFocusReason)
    }

    Column {
        width: parent.width
        height: childrenRect.height
        topPadding: Style.current.bigPadding

        spacing: Style.current.bigPadding

        StatusInput {
            id: nameInput
            implicitWidth: parent.width
            input.edit.objectName: "savedAddressNameInput"
            placeholderText: qsTr("Address name")
            label: qsTr("Name")
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: qsTr("Name must not be blank")
                },
                StatusRegularExpressionValidator {
                    regularExpression: /^[^<>]+$/
                    errorMessage: qsTr("This is not a valid account name")
                }
            ]
            input.clearable: true
            input.rightPadding: 16
            validationMode: d.validationMode
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
            enabled: !(root.edit || root.addAddress)
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
            validationMode: d.validationMode

            input.edit.textFormat: TextEdit.RichText
            input.asset.name: addressInput.valid && !root.edit ? "checkbox" : ""
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
                        root.ens = plainText
                        root.address = Constants.zeroAddress
                        root.chainShortNames = ""
                    }
                    else {
                        root.ens = ""
                        root.address = prefixAndAddress.address
                        root.chainShortNames = prefixAndAddress.prefix

                        let prefixArrWithColumn = d.getPrefixArrayWithColumns(prefixAndAddress.prefix)
                        if (!prefixArrWithColumn)
                            prefixArrWithColumn = []

                        allNetworksModelCopy.setEnabledNetworks(prefixArrWithColumn)
                    }
                }
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

        StatusNetworkSelector {
            id: networkSelector
            objectName: "addSavedAddressNetworkSelector"
            title: "Network preference"
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
                        // extra work and mistakenly overwrites root.chainShortNames property
                        if (sourceModel.count != 0) {
                            const prefixAndAddress = Utils.splitToChainPrefixAndAddress(addressInput.plainText)
                            const syncedPrefix = addressInput.syncChainPrefixWithModel(prefixAndAddress.prefix, this)
                            root.chainShortNames = syncedPrefix
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
                text: root.edit ? qsTr("Save") : qsTr("Add address")
                enabled: d.valid && d.dirty
                onClicked: root.save(name, address, chainShortNames, ens)
                objectName: "addSavedAddress"
            }
        }
    }

    CloneModel {
        id: allNetworksModelCopy

        sourceModel: store.allNetworks
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
