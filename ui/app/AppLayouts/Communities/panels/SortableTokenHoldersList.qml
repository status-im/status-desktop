import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

/*!
   \qmltype SortableTokenHoldersList
   \inherits StatusListView
   \brief Shows list of users or addresses with corrensponding numbers of
   messages and holding amounts.

   Expected roles: name, walletAddress, imageSource, noOfMessages, amount
  */
StatusListView {
    id: root

    readonly property alias sortBy: d.sortBy
    readonly property alias sortOrder: d.sorting

    signal clicked(int index, var parent, var mouse)

    currentIndex: -1
    spacing: Style.current.halfPadding

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

    component NumberCell: StatusBaseText {
        horizontalAlignment: Qt.AlignRight
        verticalAlignment: Qt.AlignVCenter

        font.weight: Font.Medium
        font.pixelSize: 13

        color: Theme.palette.baseColor1
        elide: Qt.ElideRight
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
        horizontalPadding: Style.current.padding


        readonly property alias usernameHeaderWidth: usernameHeader.width
        readonly property alias noOfMessagesHeaderWidth: noOfMessagesHeader.width
        readonly property alias holdingHeaderWidth: holdingHeader.width

        contentItem: RowLayout {
            id: row

            spacing: Style.current.padding

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
                        d.sortBy = TokenHoldersProxyModel.SortBy.NoOfMessages
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

    delegate: ItemDelegate {
        id: delegate

        readonly property bool remotelyDestructInProgress:
            model.remotelyDestructState === Constants.ContractTransactionStatus.InProgress

        onRemotelyDestructInProgressChanged: {
            if(!remotelyDestructInProgress)
                colorAnimation.restart()
        }

        padding: 0
        horizontalPadding: Style.current.padding

        topPadding: showSeparator ? Style.current.halfPadding : 0

        readonly property string name: model.name

        readonly property bool isFirstRowAddress: {
            if (model.name !== "")
                return false

            const item = root.itemAtIndex(index - 1)
            return item && item.name
        }

        readonly property bool showSeparator: isFirstRowAddress
            && root.sortBy === TokenHoldersProxyModel.SortBy.Username

        width: ListView.view.width

        background: Item {
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: delegate.topPadding

                radius: Style.current.radius
                color: (delegate.hovered || delegate.ListView.isCurrentItem)
                       ? Theme.palette.baseColor2 : "transparent"
            }

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: delegate.topPadding

                radius: Style.current.radius
                color: "transparent"

                SequentialAnimation on color {
                    id: colorAnimation

                    running: false

                    PropertyAction { value: Theme.palette.primaryColor3 }
                    PauseAnimation { duration: 1000 }
                    ColorAnimation { to: "transparent"; duration: 500 }
                }
            }

            Rectangle {
                visible: delegate.showSeparator

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                height: 1
                color: Theme.palette.baseColor2
            }
        }

        contentItem: Item {
            implicitWidth: delegateRow.implicitWidth
            implicitHeight: delegateRow.implicitHeight

            RowLayout {
                id: delegateRow

                spacing: Style.current.padding

                StatusListItem {
                    id: listItem

                    readonly property bool unknownHolder: model.name === ""
                    readonly property string formattedTitle: unknownHolder
                                                             ? "?" : model.name

                    readonly property string addressElided:
                        StatusQUtils.Utils.elideText(
                            model.walletAddress, 6, 3).replace("0x", "0×")

                    Layout.preferredWidth: root.headerItem.usernameHeaderWidth

                    color: "transparent"

                    leftPadding: 0
                    rightPadding: 0
                    sensor.enabled: false
                    title: unknownHolder ? addressElided : model.name

                    statusListItemIcon.name: "?"

                    subTitle: unknownHolder ? "" : addressElided

                    statusListItemSubTitle.font.pixelSize: Theme.asideTextFontSize
                    statusListItemSubTitle.lineHeightMode: Text.FixedHeight
                    statusListItemSubTitle.lineHeight: 14

                    asset.name: model.imageSource
                    asset.isImage: true
                    asset.isLetterIdenticon: unknownHolder
                    asset.color: Theme.palette.userCustomizationColors[d.red2Color]
                }

                NumberCell {
                    Layout.preferredWidth: root.headerItem.noOfMessagesHeaderWidth

                    text: model.name
                          ? LocaleUtils.numberToLocaleString(model.noOfMessages)
                          : "-"
                }

                RowLayout {
                    Layout.preferredWidth: root.headerItem.holdingHeaderWidth
                    spacing: 4

                    StatusBaseText {
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignRight

                        text: StatusQUtils.Emoji.fromCodePoint("1f525") // :fire: emoji
                        font.pixelSize: Style.current.tertiaryTextFontSize
                        visible: delegate.remotelyDestructInProgress
                        color: Theme.palette.directColor1
                    }

                    NumberCell {
                        Layout.alignment: Qt.AlignRight
                        text: LocaleUtils.numberToLocaleString(model.amount)
                    }

                    StatusLoadingIndicator {
                        Layout.preferredHeight: Theme.primaryTextFontSize
                        Layout.preferredWidth: Layout.preferredHeight
                        Layout.leftMargin: 6
                        visible: delegate.remotelyDestructInProgress
                        color: Theme.palette.primaryColor1
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            acceptedButtons: Qt.AllButtons
            cursorShape: Qt.PointingHandCursor

            onClicked: root.clicked(model.index, delegate, mouse)
        }
    }
}
