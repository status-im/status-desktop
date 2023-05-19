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
            addressName: "Test Name"
            contactPubKey: "zQ3shWU7xpM5YoG19KP5JDRiSs1AdWtjpnrWEerMkxfQnYo8x"
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
    /*!
       \qmlproperty string TransactionAddress::addressName
       This property holds wallet address name.
       If contact public key is not provided this name will be used for display.
    */
    property string addressName
    /*!
       \qmlproperty string TransactionAddress::contactPubKey
       This property hold contact public key used to identify contact wallet.
       Contact icon will be displayed. Display name take place of \l{addressName}.
    */
    property string contactPubKey

    /* /internal Property hold reference to contacts store to refresh contact data on any change. */
    property var contactsStore

    /*!
       \qmlproperty \l{StatusAssetSettings} TransactionAddress::asset
       Property holds asset settings for contact icon.
    */
    property StatusAssetSettings asset: StatusAssetSettings {
        width: 36
        height: 36
        color: Utils.colorForPubkey(root.contactPubKey)
        name: isImage ? d.contactData.displayIcon : nameText.text
        isImage: d.isContact && d.contactData.displayIcon.includes("data")
        isLetterIdenticon: d.isContact && !isImage
        charactersLen: 2
    }

    implicitHeight: Math.max(identicon.height, contentColumn.height) + 12

    QtObject {
        id: d
        readonly property var prefixAndAddress: Utils.splitToChainPrefixAndAddress(root.address)
        readonly property bool isContactPubKeyValid: !!root.contactPubKey
        readonly property bool isContact: isContactPubKeyValid && contactData.isContact
        property var contactData: Utils.getContactDetailsAsJson(root.contactPubKey)

        function refreshContactData() {
            d.contactData = Utils.getContactDetailsAsJson(root.contactPubKey)
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
            visible: d.isContact
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
                text: {
                    let name = ""
                    if (d.isContact) {
                        name = ProfileUtils.displayName(d.contactData.localNickname, d.contactData.name, d.contactData.displayName, d.contactData.alias)
                    }
                    return name || root.addressName
                }
                visible: !!text
                elide: Text.ElideRight
            }
            StatusBaseText {
                Layout.fillWidth: true
                font.pixelSize: 15
                color: Theme.palette.directColor1
                wrapMode: Text.WrapAnywhere
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
