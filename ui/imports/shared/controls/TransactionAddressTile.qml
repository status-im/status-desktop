import QtQuick 2.13
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

/*!
   \qmltype TransactionAddressTile
   \inherits TransactionDataTile
   \inqmlmodule shared.controls
   \since shared.controls 1.0
   \brief It displays list of addresses for wallet activity.

   The \c TransactionAddressTile can display list of addresses formatted in specific way.

   \qml
        TransactionAddressTile {
            title: qsTr("From")
            width: parent.width
            rootStore: WalletStores.RootStore
            addresses: [
                "eth:arb:opt:0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35",
                "0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35",
            ]
        }
   \endqml
*/

TransactionDataTile {
    id: root

    /*!
       \qmlproperty var TransactionAddressTile::addresses
       This property holds list or model of addresses to display in the tile.
    */
    property var addresses: []
    /*!
       \qmlproperty var TransactionAddressTile::rootStore
       This property holds rootStore object used to retrive data for each address.
    */
    property var rootStore

    /* /internal Property hold reference to contacts store to refresh contact data on any change. */
    property var contactsStore

    implicitHeight: transactionColumn.height + transactionColumn.spacing + root.topPadding + root.bottomPadding
    buttonIconName: "more"

    Column {
        id: transactionColumn
        anchors {
            left: parent.left
            leftMargin: root.leftPadding
            right: parent.right
            rightMargin: root.statusListItemComponentsSlot.width + root.rightPadding * 2
            bottom: parent.bottom
            bottomMargin: root.bottomPadding
        }
        height: childrenRect.height
        spacing: 4

        Repeater {
            model: root.addresses
            delegate: TransactionAddress {
                width: parent.width
                address: modelData
                rootStore: root.rootStore
                contactsStore: root.contactsStore
            }
        }
    }
}
