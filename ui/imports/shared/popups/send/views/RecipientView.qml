import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet 1.0

import shared.controls 1.0 as SharedControls
import shared.stores.send 1.0
import shared.popups.send.panels 1.0
import shared.popups.send 1.0

import utils 1.0

import "../controls"

Loader {
    id: root

    property TransactionStore store
    property bool isCollectiblesTransfer
    property bool isBridgeTx: false
    property bool interactive: true
    property var selectedAsset
    property var selectedRecipient: null
    property int selectedRecipientType: Helpers.RecipientAddressObjectType.Address

    readonly property bool ready: (d.isAddressValid || !!resolvedENSAddress) && !d.isPending
    property string addressText
    property string resolvedENSAddress

    signal recalculateRoutesAndFees()
    signal isLoading()

    onAddressTextChanged: d.isPending = false

    onSelectedRecipientChanged: {
        root.isLoading()
        if(!!root.selectedRecipient) {
            let preferredChainIds = []
            switch(root.selectedRecipientType) {
            case Helpers.RecipientAddressObjectType.Account: {
                root.addressText = root.selectedRecipient.address
                preferredChainIds = root.selectedRecipient.preferredSharingChainIds
                break
            }
            case Helpers.RecipientAddressObjectType.SavedAddress: {
                root.addressText = root.selectedRecipient.address

                // Resolve before using
                if (!!root.selectedRecipient.ens && root.selectedRecipient.ens.length > 0) {
                    d.isPending = true
                    d.resolveENS(root.selectedRecipient.ens)
                }
                preferredChainIds = store.getShortChainIds(root.selectedRecipient.chainShortNames)
                break
            }
            case Helpers.RecipientAddressObjectType.RecentsAddress: {
                let isIncoming = root.selectedRecipient.txType === Constants.TransactionType.Receive
                root.addressText = isIncoming ? root.selectedRecipient.sender : root.selectedRecipient.recipient
                root.item.input.text = root.addressText
                break
            }
            case Helpers.RecipientAddressObjectType.Address: {
                root.addressText = root.selectedRecipient
                root.item.input.text = root.addressText
                break
            }
            }

            // set preferred chains
            if(!isCollectiblesTransfer) {
                if(root.isBridgeTx)
                    root.store.setAllNetworksAsRoutePreferredChains()
                else
                    root.store.updateRoutePreferredChains(preferredChainIds)
            }

            recalculateRoutesAndFees()
        }
    }

    QtObject {
        id: d
        property bool isAddressValid: Utils.isValidAddress(root.addressText)
        readonly property var resolveENS: Backpressure.debounce(root, 1500, function (ensName) {
            store.resolveENS(ensName)
        })
        property bool isPending: false
        function clearValues() {
            root.addressText = ""
            root.resolvedENSAddress = ""
            root.selectedRecipientType = Helpers.RecipientAddressObjectType.Address
            root.selectedRecipient = null
        }
        property Timer waitTimer: Timer {
            interval: 1500
            onTriggered: d.evaluateAndSetPreferredChains()
        }

        function evaluateAndSetPreferredChains() {
            let address = !!root.item.input && !!root.store.plainText(root.item.input.text) ? root.store.plainText(root.item.input.text): ""
            let result = store.splitAndFormatAddressPrefix(address, !root.isBridgeTx && !isCollectiblesTransfer)
            if(!!result.address) {
                root.addressText = result.address
                if(!!root.item.input) {
                    root.item.input.text = result.formattedText
                    root.item.input.edit.cursorPosition = root.item.input.edit.length
                }
            }
            root.recalculateRoutesAndFees()
        }
    }

    sourceComponent: root.selectedRecipientType === Helpers.RecipientAddressObjectType.SavedAddress
        ? savedAddressRecipient
        : root.selectedRecipientType === Helpers.RecipientAddressObjectType.Account
            ? myAccountRecipient : addressRecipient

    Component {
        id: savedAddressRecipient
        SavedAddressListItem {
            property string chainShortNames: !!modelData ? modelData.chainShortNames: ""
            implicitWidth: parent.width
            modelData: root.selectedRecipient
            radius: 8
            clearVisible: true
            color: Theme.palette.indirectColor1
            sensor.enabled: false
            subTitle:  {
                if(!!modelData) {
                    if (!!modelData && !!modelData.ens && modelData.ens.length > 0)
                        return Utils.richColorText(modelData.ens, Theme.palette.directColor1)
                    else
                        return WalletUtils.colorizedChainPrefix(modelData.chainShortNames) + StatusQUtils.Utils.elideText(modelData.address,6,4)
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
            readonly property var modelData: root.selectedRecipient

            name: !!modelData ? modelData.name : ""
            address: !!modelData ? modelData.address : ""
            chainShortNames: !!modelData ? store.getNetworkShortNames(modelData.preferredSharingChainIds) : ""
            emoji: !!modelData ? modelData.emoji : ""
            walletColor: !!modelData ? Utils.getColorForId(modelData.colorId): ""
            currencyBalance: !!modelData ? modelData.currencyBalance : ""
            walletType: !!modelData ? modelData.walletType : ""
            migratedToKeycard: !!modelData ? modelData.migratedToKeycard ?? false : false
            accountBalance: !!modelData ? modelData.accountBalance : null

            implicitWidth: parent.width
            radius: 8
            clearVisible: true
            color: Theme.palette.indirectColor1
            sensor.enabled: false
            subTitle: {
                if(!!modelData) {
                    const elidedAddress = StatusQUtils.Utils.elideAndFormatWalletAddress(modelData.address)
                    return WalletUtils.colorizedChainPrefix(accountItem.chainShortNames) + elidedAddress
                }
                return ""
            }
            onCleared: d.clearValues()
        }
    }

    Component {
        id: addressRecipient
        SendRecipientInput {
            width: parent.width
            height: visible ? implicitHeight: 0
            visible: !root.isBridgeTx && !!root.selectedAsset
            text: root.addressText

            function validateInput() {
                const plainText = store.plainText(text)
                root.isLoading()
                if (Utils.isValidEns(plainText)) {
                    d.isPending = true
                    d.resolveENS(plainText)
                } else {
                    d.waitTimer.restart()
                }
            }

            interactive: root.interactive
            checkMarkVisible: root.ready
            onClearClicked: d.clearValues()
            onValidateInputRequested: validateInput()
        }
    }

    Connections {
        target: store.mainModuleInst
        function onResolvedENS(resolvedPubKey: string, resolvedAddress: string, uuid: string) {
            d.isPending = false
            if(Utils.isValidAddress(resolvedAddress)) {
                root.resolvedENSAddress = resolvedAddress
                root.addressText = root.resolvedENSAddress
                if(!!root.item.input)
                    root.item.input.text = root.resolvedENSAddress
                d.evaluateAndSetPreferredChains()
            }
        }
    }
}

