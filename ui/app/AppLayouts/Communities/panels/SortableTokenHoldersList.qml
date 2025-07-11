import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Core.Utils as StatusQUtils

import utils

import "../controls"

/*!
   \qmltype SortableTokenHoldersList
   \inherits StatusListView
   \brief Shows list of users or addresses with corrensponding numbers of
   messages and holding amounts.

   Expected roles: contactId, name, walletAddress, imageSource, numberOfMessages, amount
  */
StatusListView {
    id: root

    property int multiplierIndex: 0

    readonly property alias sortBy: d.sortBy
    readonly property alias sortOrder: d.sorting

    signal clicked(int index, var parent, var mouse)

    currentIndex: -1
    spacing: Theme.halfPadding

    component ColumnHeader: StatusSortableColumnHeader {
        id: columnHeader

        leftPadding: 0
        rightPadding: 4

        Connections {
            target: d

            function onResetOtherHeaders(header) {
                if (header !== columnHeader)
                    columnHeader.reset()
            }
        }

        onClicked: {
            d.resetOtherHeaders(this)

            if (sorting === StatusSortableColumnHeader.Sorting.Ascending)
                d.sorting = Qt.AscendingOrder
            else if (sorting === StatusSortableColumnHeader.Sorting.Descending)
                d.sorting = Qt.DescendingOrder
        }
    }

    QtObject {
        id: d

        property int sortBy: TokenHoldersProxyModel.SortBy.None
        property int sorting: Qt.DescendingOrder

        readonly property int red2Color: 4

        signal resetOtherHeaders(var header)
    }

    header: ItemDelegate {
        width: ListView.view.width

        padding: 0
        horizontalPadding: Theme.padding


        readonly property alias usernameHeaderWidth: usernameHeader.width
        readonly property alias noOfMessagesHeaderWidth: noOfMessagesHeader.width
        readonly property alias holdingHeaderWidth: holdingHeader.width

        contentItem: RowLayout {
            id: row

            spacing: Theme.padding

            RowLayout {
                id: usernameHeader

                ColumnHeader {
                    text: qsTr("Username")

                    traversalOrder: [
                        StatusSortableColumnHeader.Sorting.NoSorting,
                        StatusSortableColumnHeader.Sorting.Ascending,
                        StatusSortableColumnHeader.Sorting.Descending
                    ]

                    onClicked: {
                        if (sorting !== StatusSortableColumnHeader.Sorting.NoSorting)
                            d.sortBy = TokenHoldersProxyModel.SortBy.Username
                        else
                            d.sortBy = TokenHoldersProxyModel.SortBy.None
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            ColumnHeader {
                id: noOfMessagesHeader

                text: qsTr("No. of messages")

                onClicked: {
                    if (sorting !== StatusSortableColumnHeader.Sorting.NoSorting)
                        d.sortBy = TokenHoldersProxyModel.SortBy.NumberOfMessages
                    else
                        d.sortBy = TokenHoldersProxyModel.SortBy.None
                }
            }

            RowLayout {
                id: holdingHeader

                Item {
                    Layout.preferredWidth: 25
                }

                ColumnHeader {
                    text: qsTr("Hodling")

                    onClicked: {
                        if (sorting !== StatusSortableColumnHeader.Sorting.NoSorting)
                            d.sortBy = TokenHoldersProxyModel.SortBy.Holding
                        else
                            d.sortBy = TokenHoldersProxyModel.SortBy.None
                    }
                }
            }
        }
    }

    delegate: TokenHolderListItem {
        id: delegate

        width: ListView.view.width
        usernameHeaderWidth: root.headerItem.usernameHeaderWidth
        noOfMessagesHeaderWidth: root.headerItem.noOfMessagesHeaderWidth
        holdingHeaderWidth: root.headerItem.holdingHeaderWidth
        isCurrentItem: delegate.ListView.isCurrentItem

        remotelyDestructInProgress: model.remotelyDestructState === Constants.ContractTransactionStatus.InProgress

        pubKey: model.pubKey
        walletAddress: model.walletAddress
        numberOfMessages: model.numberOfMessages
        amount: LocaleUtils.numberToLocaleString(StatusQUtils.AmountsArithmetic.toNumber(model.amount, root.multiplierIndex))
        nickName: model.localNickname
        userName: ProfileUtils.displayName("", model.ensName, model.displayName, model.alias)
        compressedPubKey: model.compressedPubKey
        isContact: model.isContact
        trustStatus: model.trustStatus
        memberRole: model.memberRole
        onlineStatus: model.onlineStatus
        iconName: model.icon

        showSeparator: isFirstRowAddress && root.sortBy === TokenHoldersProxyModel.SortBy.Username
        isFirstRowAddress: {
            if (name !== "")
                return false

            const item = root.itemAtIndex(index - 1)
            return item && item.name
        }

        onClicked: root.clicked(model.index, delegate, mouse)
    }
}
