import QtQuick 2.13
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

/*!
   \qmltype TransactionAddressTile
   \inherits StatusListItem
   \inqmlmodule shared.controls
   \since shared.controls 1.0
   \brief It displays list of addresses for wallet activity.

   The \c TransactionAddressTile can display list of addresses formatted in specific way.

   \qml
        TransactionAddressTile {
            title: qsTr("From")
            width: parent.width
            rootStore: WalletStores.RootStore
            roundedCornersBottom: false
            addresses: [
                "eth:arb:opt:0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35",
                "0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35",
            ]
        }
   \endqml
*/

StatusListItem {
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

    /*!
       \qmlproperty int TransactionAddressTile::topPadding
       This property holds spacing between top and content item in tile.
    */
    property int topPadding: 12
    /*!
       \qmlproperty int TransactionAddressTile::bottomPadding
       This property holds spacing between bottom and content item in tile.
    */
    property int bottomPadding: 12

    /* /internal Property hold reference to contacts store to refresh contact data on any change. */
    property var contactsStore

    signal showContextMenu()

    leftPadding: 12
    rightPadding: 12
    radius: 0

    implicitHeight: transactionColumn.height + statusListItemTitleArea.height + root.topPadding + root.bottomPadding
    statusListItemTitle.customColor: Theme.palette.directColor5
    statusListItemTitleArea.anchors {
        top: statusListItemTitleArea.parent.top
        topMargin: root.topPadding
        right: statusListItemTitleArea.parent.right
        verticalCenter: undefined
    }

    components: [
        StatusRoundButton {
            id: button
            width: 32
            height: 32
            icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
            icon.name: "more"
            type: StatusRoundButton.Type.Quinary
            radius: 8
            visible: root.sensor.containsMouse
            onClicked: root.showContextMenu()
        }
    ]

    Column {
        id: transactionColumn
        anchors {
            left: parent.left
            leftMargin: root.leftPadding
            right: parent.right
            rightMargin: button.width + root.rightPadding * 2
            bottom: parent.bottom
            bottomMargin: root.bottomPadding
        }
        height: childrenRect.height
        spacing: 4
        // Moving it under sensor, because Rich Text steals hovering
        z: root.sensor.z - 1

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
