import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Profile.popups 1.0

import shared.controls 1.0
import shared.popups 1.0
import shared.panels 1.0
import utils 1.0

import SortFilterProxyModel 0.2

import "../../controls"

ColumnLayout {
    id: root

    signal goBack
    signal runRenameKeypairFlow()
    signal runRemoveKeypairFlow()
    signal runImportMissingKeypairFlow()
    signal runMoveKeypairToKeycardFlow()
    signal runStopUsingKeycardFlow()
    signal updateWatchAccountHiddenFromTotalBalance(string address, bool hideFromTotalBalance)

    property var account
    property var keyPair
    property var walletStore
    property var emojiPopup
    property string userProfilePublicKey

    QtObject {
        id: d
        readonly property bool watchOnlyAccount: !!root.keyPair? root.keyPair.pairType === Constants.keypair.type.watchOnly: false
        readonly property bool privateKeyAccount: !!root.keyPair? root.keyPair.pairType === Constants.keypair.type.privateKeyImport: false
        readonly property bool seedImport: !!root.keyPair? root.keyPair.pairType === Constants.keypair.type.seedImport: false
        readonly property string preferredSharingNetworks: !!root.account? root.account.preferredSharingChainIds: ""
        property var preferredSharingNetworksArray: preferredSharingNetworks.split(":").filter(Boolean)
        property string preferredSharingNetworkShortNames: walletStore.getNetworkShortNames(preferredSharingNetworks)
     	onPreferredSharingNetworksChanged: {
            preferredSharingNetworksArray = preferredSharingNetworks.split(":")
            preferredSharingNetworkShortNames = walletStore.getNetworkShortNames(preferredSharingNetworks)
        }
    }

    spacing: 0

    RowLayout {
        Layout.preferredWidth: parent.width
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.current.smallPadding
            StatusBaseText {
                id: accountName
                objectName: "walletAccountViewAccountName"
                Layout.alignment: Qt.AlignLeft
                text: !!root.account? root.account.name : ""
                font.weight: Font.Bold
                font.pixelSize: 28
                color: !!root.account? Utils.getColorForId(root.account.colorId) : Theme.palette.directColor1
            }
            StatusEmoji {
                id: accountImage
                objectName: "walletAccountViewAccountImage"
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                emojiId: StatusQUtils.Emoji.iconId(!!root.account && root.account.emoji ? root.account.emoji : "", StatusQUtils.Emoji.size.big) || ""
            }
        }
        StatusButton {
            Layout.alignment: Qt.AlignRight
            objectName: "walletAccountViewEditAccountButton"
            text: d.watchOnlyAccount ? qsTr("Edit watched address") : qsTr("Edit account")
            icon.name: "edit_pencil"
            onClicked: Global.openPopup(renameAccountModalComponent)
        }
    }

    ImportKeypairInfo {
        Layout.fillWidth: true
        Layout.topMargin: Style.current.bigPadding
        Layout.preferredHeight: childrenRect.height
        visible: !!root.keyPair && root.keyPair.operability === Constants.keypair.operability.nonOperable

        onRunImport: {
            root.runImportMissingKeypairFlow()
        }
    }

    StatusBaseText {
        objectName: "AccountDetails_TextLabel"
        Layout.topMargin: Style.current.bigPadding
        text: qsTr("Account details")
        font.pixelSize: 15
        color: Theme.palette.baseColor1
    }

    Rectangle {
        Layout.topMargin: Style.current.halfPadding
        Layout.fillWidth: true
        Layout.preferredHeight: childrenRect.height
        radius: Style.current.radius
        border.width: 1
        border.color: Theme.palette.directColor8
        color: Theme.palette.transparent

        ColumnLayout {
            width: parent.width
            spacing: 0
            WalletAccountDetailsListItem {
                objectName: "Balance_ListItem"
                Layout.fillWidth: true
                title: qsTr("Balance")
                subTitle: !!root.account && root.account.balance ? LocaleUtils.currencyAmountToLocaleString(root.account.balance): ""
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
            }
            WalletAccountDetailsListItem {
                objectName: "Address_ListItem"
                Layout.fillWidth: true
                isInteractive: true
                moreButtonEnabled: true
                title: qsTr("Address")
                subTitle: {
                    let address = !!root.account && root.account.address ? root.account.address: ""
                    return WalletUtils.colorizedChainPrefix(d.preferredSharingNetworkShortNames) + address
                }
                onButtonClicked: addressMenu.openMenu(this)
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
            }
            StatusBaseText {
                objectName: "Keypair_TextLabel"
                text: qsTr("Keypair")
                Layout.leftMargin: 16
                Layout.topMargin: 12
                font.pixelSize: 13
                color: Theme.palette.baseColor1
                visible: !d.watchOnlyAccount
            }
            WalletAccountDetailsKeypairItem {
                objectName: "KeyPair_Item"
                Layout.fillWidth: true
                keyPair: root.keyPair
                visible: !d.watchOnlyAccount
                onButtonClicked: keycardMenu.popup(this, this.width - 40, this.height / 2 + 20)
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
                visible: !d.watchOnlyAccount
            }
            WalletAccountDetailsListItem {
                objectName: "Origin_ListItem"
                Layout.fillWidth: true
                title: qsTr("Origin")
                subTitle: {
                    if(!!root.keyPair) {
                        switch(root.keyPair.pairType) {
                        case Constants.keypair.type.profile:
                            return qsTr("Derived from your default Status keypair")
                        case Constants.keypair.type.seedImport:
                            return qsTr("Imported from seed phrase")
                        case Constants.keypair.type.privateKeyImport:
                            return qsTr("Imported from private key")
                        case Constants.keypair.type.watchOnly:
                            return qsTr("Watched address")
                        default:
                            return ""
                        }
                    }
                    return ""
                }
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
            }
            WalletAccountDetailsListItem {
                objectName: "DerivationPath_ListItem"
                id: derivationPath
                Layout.fillWidth: true
                isInteractive: true
                copyButtonEnabled: true
                title: qsTr("Derivation Path")
                subTitle: !!root.account? Utils.getPathForDisplay(root.account.path) : ""
                onCopyClicked: root.walletStore.copyToClipboard(!!root.account? root.account.path : "")
                visible: !!subTitle && !d.privateKeyAccount && !d.watchOnlyAccount
            }
            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.palette.baseColor2
                visible: derivationPath.visible
            }
            WalletAccountDetailsListItem {
                objectName: "Stored_ListItem"
                Layout.fillWidth: true
                title: qsTr("Stored")
                subTitle: Utils.getKeypairLocation(root.keyPair, true)
                visible: !!subTitle
                statusListItemSubTitle.color: Utils.getKeypairLocationColor(root.keyPair)
            }
        }
    }

    Separator {
        Layout.topMargin: 40
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Theme.palette.baseColor2
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Include in total balance")
        objectName: "includeTotalBalanceListItem"
        visible: d.watchOnlyAccount
        color: Theme.palette.transparent
        components: [
            StatusSwitch {
                checked: !!root.account && !account.hideFromTotalBalance
                onToggled: root.updateWatchAccountHiddenFromTotalBalance(account.address, !checked)
            }
        ]
    }

    Separator {
        visible: d.watchOnlyAccount
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Theme.palette.baseColor2
    }

    StatusListItem {
        objectName: "PreferredNetworks_ListItem"
        Layout.fillWidth: true
        Layout.topMargin: Style.current.halfPadding
        title: qsTr("Preferred networks when sharing this address")
        color: Theme.palette.transparent
        components: [
            NetworkFilter {
                layer1Networks: SortFilterProxyModel {
                    sourceModel: root.walletStore.networks
                    filters: ValueFilter { roleName: "layer"; value: 1; }
                }
                layer2Networks: SortFilterProxyModel {
                    sourceModel: root.walletStore.networks
                    filters: ValueFilter { roleName: "layer"; value: 2; }
                }
                allNetworks: root.walletStore.networks
                enabledNetworks: SortFilterProxyModel {
                    sourceModel: root.walletStore.networks
                    filters:  ExpressionFilter {
                        expression: d.preferredSharingNetworksArray.includes(model.chainId.toString())
                    }
                }
                preferredNetworksMode: true
                preferredSharingNetworks: d.preferredSharingNetworksArray
                onToggleNetwork: (network) => {
                                     d.preferredSharingNetworksArray = root.walletStore.processPreferredSharingNetworkToggle(d.preferredSharingNetworksArray, network)
                                 }
                control.popup.onClosed: {
                    if (!!root.account) {
                        root.walletStore.updateWalletAccountPreferredChains(root.account.address, d.preferredSharingNetworksArray.join(":"))
                    }
                }
            }
        ]
    }

    Separator {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Theme.palette.baseColor2
    }

    StatusButton {
        Layout.topMargin: 20
        Layout.fillWidth: true
        objectName: "deleteAccountButton"
        visible: !!root.account && !root.account.isDefaultAccount
        text:  d.watchOnlyAccount ? qsTr("Remove watched address") : qsTr("Remove account")
        icon.name: "delete"
        type: StatusBaseButton.Type.Danger
        onClicked: confirmationPopup.open()

        RemoveAccountConfirmationPopup {
            id: confirmationPopup
            accountType: {
                if (d.watchOnlyAccount) {
                    return Constants.watchWalletType
                } else if (d.privateKeyAccount) {
                    return Constants.keyWalletType
                } else if (d.seedImport){
                    return Constants.seedWalletType
                } else {
                    return Constants.generatedWalletType
                }
            }
            accountName: !!root.account ? root.account.name : ""
            accountAddress: !!root.account ? root.account.address : ""
            accountDerivationPath: !!root.account ? root.account.path : ""
            preferredSharingNetworkShortNames: d.preferredSharingNetworkShortNames
            emoji: !!root.account ? root.account.emoji : ""
            color: !!root.account ? Utils.getColorForId(root.account.colorId) : ""

            onRemoveAccount: {
                root.walletStore.deleteAccount(root.account.address)
                close()
                root.goBack()
            }
        }
    }

    Component {
        id: renameAccountModalComponent
        RenameAccontModal {
            account: root.account
            anchors.centerIn: parent
            onClosed: destroy()
            walletStore: root.walletStore
            emojiPopup: root.emojiPopup
        }
    }

    WalletAddressMenu {
        id: addressMenu
        selectedAddress: !!root.account ? root.account.address: ""
        areTestNetworksEnabled: root.walletStore.areTestNetworksEnabled
        isSepoliaEnabled: root.walletStore.isSepoliaEnabled
        preferredSharingNetworks: d.preferredSharingNetworkShortNames
        preferredSharingNetworksArray: d.preferredSharingNetworksArray
        onCopyToClipboard: root.walletStore.copyToClipboard(address)
    }

    WalletKeypairAccountMenu {
        id: keycardMenu
        keyPair: root.keyPair
        hasPairedDevices: root.walletStore.walletModule.hasPairedDevices
        onRunRenameKeypairFlow: root.runRenameKeypairFlow()
        onRunRemoveKeypairFlow: root.runRemoveKeypairFlow()
        onRunMoveKeypairToKeycardFlow: root.runMoveKeypairToKeycardFlow()
        onRunStopUsingKeycardFlow: root.runStopUsingKeycardFlow()
    }
}
