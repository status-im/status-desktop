import QtQuick 2.15
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet 1.0

import utils 1.0

/*!
   \qmltype TransactionAddress
   \inherits Item
   \inqmlmodule shared.controls
   \since shared.controls 1.0
   \brief It displays transaction address in depending on amount of data provided.

   The \c TransactionAddress should be used to display transaction activity data.

   \qml
        TransactionAddress {
            address: "0x29D7d1dd5B6f9C864d9db560D72a247c208aE86B"
        }
   \endqml
*/

Item {
    id: root

    /*!
       \qmlproperty string TransactionAddress::address
       This property holds wallet address.
    */
    property string address

    /* /internal Property hold reference to contacts store to refresh contact data on any change. */
    property var contactsStore

    /* /internal Property hold reference to root store to refresh wallet data on any change. */
    property var rootStore

    /*!
       \qmlproperty \l{StatusAssetSettings} TransactionAddress::asset
       Property holds asset settings for contact icon.
    */
    property StatusAssetSettings asset: StatusAssetSettings {
        id: statusAssetSettings
        width: 36
        height: 36
        color: d.isContact ? Utils.colorForPubkey(root.contactPubKey) : d.walletAddressColor
        name: {
            if (d.isContact) {
                return isImage ? d.contactData.displayIcon : nameText.text
            } else if (d.isWallet && !d.walletAddressEmoji) {
                return "filled-account"
            }
            return ""
        }
        isImage: d.isContact && statusAssetSettings.isImgSrc(d.contactData.displayIcon)
        emoji: d.isWallet && !!d.walletAddressEmoji ? d.walletAddressEmoji : ""
        isLetterIdenticon: d.isContact && !isImage
        charactersLen: 2
    }

    implicitHeight: Math.max(44, contentColumn.height) + 12

    QtObject {
        id: d

        property string contactPubKey: !!root.contactsStore ? root.contactsStore.getContactPublicKeyByAddress(root.address) : ""
        readonly property var prefixAndAddress: Utils.splitToChainPrefixAndAddress(root.address)
        readonly property bool isContact: contactData.isContact
        readonly property bool isWallet: !isContact && !!walletAddressName
        property var contactData
        property string savedAddressName
        property string walletAddressName
        property string walletAddressEmoji
        property string walletAddressColor

        Component.onCompleted: {
            refreshContactData()
            refreshSavedAddressName()
            refreshWalletAddress()
        }

        function refreshContactData() {
            d.contactData = Utils.getContactDetailsAsJson(d.contactPubKey)
        }

        function refreshSavedAddressName() {
            d.savedAddressName = !!root.rootStore ? root.rootStore.getNameForSavedWalletAddress(root.address) : ""
        }

        function refreshWalletAddress() {
            d.walletAddressName = !!root.rootStore ? root.rootStore.getNameForWalletAddress(root.address) : ""
            if (!d.walletAddressName)
                return // No need to query other if name not found
            d.walletAddressEmoji = !!root.rootStore ? root.rootStore.getEmojiForWalletAddress(root.address) : ""
            d.walletAddressColor = Utils.getColorForId(!!root.rootStore ? root.rootStore.getColorForWalletAddress(root.address) : "")
        }

        function getName() {
            let name = ""
            if (d.isContact) {
                name = ProfileUtils.displayName(d.contactData.localNickname, d.contactData.name, d.contactData.displayName, d.contactData.alias)
            }
            return name || d.walletAddressName || d.savedAddressName
        }

        readonly property Connections savedAccountsConnection: Connections {
            target: !!root.rootStore && !!root.rootStore.savedAddresses ? root.rootStore.savedAddresses.sourceModel ?? null : null
            function onItemChanged(address) {
                if (address === root.address)
                    d.refreshSavedAddressName()
            }
        }

        readonly property Connections walletAccountsConnection: Connections {
            target: !!root.rootStore ? root.rootStore.accounts ?? null : null
            function onItemChanged(address) {
                if (address === root.address)
                    d.refreshWalletAddress()
            }
        }

        readonly property Connections myContactsModelConnection: Connections {
            target: root.contactsStore.myContactsModel ?? null
            function onItemChanged(pubKey) {
                if (pubKey === root.contactPubKey)
                    d.refreshContactData()
            }
        }

        readonly property Connections receivedContactsReqModelConnection: Connections {
            target: root.contactsStore.receivedContactRequestsModel ?? null
            function onItemChanged(pubKey) {
                if (pubKey === root.contactPubKey)
                    d.refreshContactData()
            }
        }

        readonly property Connections sentContactReqModelConnection: Connections {
            target: root.contactsStore.sentContactRequestsModel ?? null
            function onItemChanged(pubKey) {
                if (pubKey === root.contactPubKey)
                    d.refreshContactData()
            }
        }
    }

    RowLayout {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right

        StatusSmartIdenticon {
            id: identicon
            Layout.alignment: Qt.AlignTop
            asset: root.asset
            name: nameText.text
            ringSettings {
                ringSpecModel: d.isContact ? Utils.getColorHashAsJson(d.contactData.publicKey) : []
                ringPxSize: asset.width / 24
            }
            visible: d.isContact || d.isWallet
        }

        ColumnLayout {
            id: contentColumn
            Layout.fillWidth: true
            spacing: 0

            StatusBaseText {
                id: nameText
                Layout.fillWidth: true
                font.pixelSize: 15
                color: Theme.palette.directColor1
                text: d.getName()
                visible: !!text
                elide: Text.ElideRight
            }
            StatusBaseText {
                Layout.fillWidth: true
                font.pixelSize: 15
                color: Theme.palette.directColor1
                wrapMode: Text.WrapAnywhere
                enabled: false // Set to false to disable hover for rich text
                text: {
                    if(!!root.address == false)
                        return ""
                    if (d.prefixAndAddress.prefix.length > 0) {
                        return WalletUtils.colorizedChainPrefix(d.prefixAndAddress.prefix) + d.prefixAndAddress.address
                    } else {
                        return d.prefixAndAddress.address
                    }
                }
                visible: !!root.address
                elide: Text.ElideRight
            }
        }
    }
}
