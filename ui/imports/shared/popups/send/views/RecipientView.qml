import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet 1.0

import shared.controls 1.0 as SharedControls
import shared.stores.send 1.0

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
    property int selectedRecipientType

    readonly property bool ready: (d.isAddressValid || !!resolvedENSAddress) && !d.isPending
    property string addressText
    property string resolvedENSAddress

    signal recalculateRoutesAndFees()
    signal isLoading()

    onAddressTextChanged: d.isPending = false

    onSelectedRecipientChanged: {
        root.isLoading()
        if(!!root.selectedRecipient && root.selectedRecipientType !== TabAddressSelectorView.Type.None) {
            let preferredChainIds = []
            switch(root.selectedRecipientType) {
            case TabAddressSelectorView.Type.Account: {
                root.addressText = root.selectedRecipient.address
                preferredChainIds = root.selectedRecipient.preferredSharingChainIds
                break
            }
            case TabAddressSelectorView.Type.SavedAddress: {
                root.addressText = root.selectedRecipient.address

                // Resolve before using
                if (!!root.selectedRecipient.ens && root.selectedRecipient.ens.length > 0) {
                    d.isPending = true
                    d.resolveENS(root.selectedRecipient.ens)
                }
                preferredChainIds = store.getShortChainIds(root.selectedRecipient.chainShortNames)
                break
            }
            case TabAddressSelectorView.Type.RecentsAddress: {
                let isIncoming = root.selectedRecipient.txType === Constants.TransactionType.Receive
                root.addressText = isIncoming ? root.selectedRecipient.sender : root.selectedRecipient.recipient
                root.item.input.text = root.addressText
                break
            }
            case TabAddressSelectorView.Type.Address: {
                root.addressText = root.selectedRecipient.address
                root.item.input.text = root.selectedRecipient.address
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
            root.selectedRecipientType = TabAddressSelectorView.Type.None
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
                if(!!root.item.input)
                    root.item.input.text = result.formattedText
            }
            root.recalculateRoutesAndFees()
        }
    }

    sourceComponent: root.selectedRecipientType === TabAddressSelectorView.Type.SavedAddress
        ? savedAddressRecipient
        : root.selectedRecipientType === TabAddressSelectorView.Type.Account
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
        StatusInput {
            id: recipientInput
            width: parent.width
            height: visible ? implicitHeight: 0
            visible: !root.isBridgeTx && !!root.selectedAsset

            placeholderText: qsTr("Enter an ENS name or address")
            input.background.color: Theme.palette.indirectColor1
            input.background.border.width: 0
            input.implicitHeight: 56
            input.clearable: root.interactive
            input.edit.readOnly: !root.interactive
            multiline: false
            input.edit.textFormat: TextEdit.RichText
            text: addressText

            input.rightComponent: RowLayout {
                StatusButton {
                    font.weight: Font.Normal
                    borderColor: Theme.palette.primaryColor1
                    size: StatusBaseButton.Size.Tiny
                    text: qsTr("Paste")
                    visible: !store.plainText(recipientInput.text)
                    onClicked: recipientInput.input.edit.paste()
                }
                StatusIcon {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    icon: "tiny/checkmark"
                    color: Theme.palette.primaryColor1
                    visible: root.ready
                }
                StatusClearButton {
                    visible: !!store.plainText(recipientInput.text)
                    onClicked: {
                        recipientInput.input.edit.clear()
                        d.clearValues()
                    }
                }
            }
            Keys.onTabPressed: event.accepted = true
            Keys.onReleased: {
                let plainText =  store.plainText(input.edit.text)
                if(!plainText) {
                    d.clearValues()
                }
                else {
                    root.isLoading()
                    if(Utils.isValidEns(plainText)) {
                        d.isPending = true
                        d.resolveENS(plainText)
                    }
                    else {
                        d.waitTimer.restart()
                    }
                }
            }
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

