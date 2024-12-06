import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet 1.0

import shared.controls 1.0 as SharedControls
import shared.stores.send 1.0
import shared.popups.send.panels 1.0
import shared.popups.send 1.0
import shared.popups.send.controls 1.0

import utils 1.0

Loader {
    id: root

    required property var savedAddressesModel
    required property var myAccountsModel

    property string selectedRecipientAddress
    property int selectedRecipientType: Helpers.RecipientAddressObjectType.Address
    property bool interactive: true

    signal resolveENS(string ensName, string uuid)

    function ensNameResolved(resolvedPubKey, resolvedAddress, uuid) {
        if(uuid !== d.uuid) {
            return
        }
        root.selectedRecipientAddress = resolvedAddress
    }

    QtObject {
        id: d

        property bool isValidAddress: true
        property bool isBeingEvaluated: false

        property string uuid

        readonly property var validateInput: Backpressure.debounce(root, 500, function (address) {
            d.isValidAddress = Utils.isValidAddress(address)
            const isENSName = Utils.isValidEns(address)

            if(d.isValidAddress) {
                root.selectedRecipientAddress = address
                d.isBeingEvaluated = false
            }
            else if(isENSName) {
                d.uuid = Utils.uuid()
                return root.resolveENS(address, uuid)
            } else {
                root.selectedRecipientAddress = ""
                d.isBeingEvaluated = false
            }
        })

        readonly property var accountsSelectedEntry: ModelEntry {
            sourceModel: root.myAccountsModel
            key: "address"
            value: root.selectedRecipientAddress
        }

        readonly property var savedAddrSelectedEntry: ModelEntry {
            sourceModel: root.savedAddressesModel
            key: "address"
            value: root.selectedRecipientAddress

        }

        function clearValues() {
            root.selectedRecipientAddress = ""
            root.selectedRecipientType = Helpers.RecipientAddressObjectType.Address
        }
    }

    sourceComponent: root.selectedRecipientType === Helpers.RecipientAddressObjectType.SavedAddress ?
                         savedAddressRecipient:
                         root.selectedRecipientType === Helpers.RecipientAddressObjectType.Account ?
                             myAccountRecipient:
                             root.selectedRecipientType === Helpers.RecipientAddressObjectType.RecentsAddress ?
                                 recentsRecipient : addressRecipient

    Component {
        id: savedAddressRecipient
        SavedAddressListItem {
            implicitWidth: parent.width
            modelData: d.savedAddrSelectedEntry.item
            radius: 8
            clearVisible: true
            color: Theme.palette.indirectColor1
            sensor.enabled: false
            subTitle:  {
                if(!!modelData) {
                    if (!!modelData && !!modelData.ens && modelData.ens.length > 0)
                        return Utils.richColorText(modelData.ens, Theme.palette.directColor1)
                    else
                        return StatusQUtils.Utils.elideText(modelData.address,6,4)
                }
                return ""
            }
            onCleared: d.clearValues()
        }
    }

    Component {
        id: myAccountRecipient
        SharedControls.WalletAccountListItem {
            id: accountItem
            readonly property var modelData: d.accountsSelectedEntry.item

            name: !!modelData ? modelData.name : ""
            address: !!modelData ? modelData.address : ""
            emoji: !!modelData ? modelData.emoji : ""
            walletColor: !!modelData ? Utils.getColorForId(modelData.colorId): ""
            currencyBalance: !!modelData ? modelData.currencyBalance : ""
            walletType: !!modelData ? modelData.walletType : ""
            migratedToKeycard: !!modelData ? modelData.migratedToKeycard ?? false : false
            accountBalance: !!modelData ? modelData.accountBalance : null

            width: parent.width
            radius: 8
            clearVisible: true
            color: Theme.palette.indirectColor1
            sensor.enabled: false
            subTitle: {
                if(!!modelData) {
                    return StatusQUtils.Utils.elideAndFormatWalletAddress(modelData.address)
                }
                return ""
            }
            onCleared: d.clearValues()
        }
    }

    Component {
        id: recentsRecipient

        SendRecipientInput {
            width: parent.width
            height: visible ? implicitHeight: 0

            interactive: root.interactive
            input.edit.enabled: false
            input.edit.textFormat: Text.AutoText
            text: root.selectedRecipientAddress

            onClearClicked: d.clearValues()
        }
    }

    Component {
        id: addressRecipient

        SendRecipientInput {
            function validateInput() {
                const plainText = StatusQUtils.StringUtils.plainText(text)
                d.isBeingEvaluated = true
                d.validateInput(plainText)
            }

            width: parent.width
            height: visible ? implicitHeight: 0

            interactive: root.interactive
            checkMarkVisible: !d.isBeingEvaluated && d.isValidAddress
            loading: d.isBeingEvaluated
            input.edit.textFormat: Text.AutoText

            text: {
                if(!!root.selectedRecipientAddress ) {
                    return root.selectedRecipientAddress
                }
                return text
            }

            onTextChanged: Qt.callLater(() => validateInput())
            onClearClicked: {
                text = ""
                d.clearValues()
            }
            onValidateInputRequested: Qt.callLater(() => validateInput())
        }
    }
}

