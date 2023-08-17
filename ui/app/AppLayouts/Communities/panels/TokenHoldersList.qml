import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import SortFilterProxyModel 0.2

import utils 1.0
import shared.controls 1.0

import "../controls"

/*!
   \qmltype TokenHoldersList
   \inherits StatusListView
   \brief Shows list of users or addresses with corrensponding numbers of
   messages and holding amounts.

   Expected roles: name, walletAddress, imageSource, amount
  */


Item {
    id: root
    implicitHeight: (listView.contentHeight+header.height+12)//initial height plus top margin

    property alias model: listView.model
    property bool isSelectorMode: false
    readonly property alias sortBy: d.sortBy
    readonly property alias sortOrder: d.sorting
    readonly property bool bottomSeparatorVisible: ((listView.contentY > 0) &&
    (listView.contentY < (listView.contentHeight - listView.height)))

    signal selfDestructAmountChanged(string walletAddress, int amount)
    signal selfDestructRemoved(string walletAddress)

    QtObject {
        id: d
        property int sortBy: TokenHoldersProxyModel.SortBy.None
        property int sorting: Qt.DescendingOrder
        property var selectedTokenAmount: new Map();
        property var selectedTokenChecked: new Map();
        property int delegateHeight: 64

        signal resetOtherHeaders(var header)
    }

    clip: true

    Control {
        id: header
        width: parent.width
        height: 40
        readonly property alias usernameHeaderWidth: usernameHeader.width
        readonly property alias holdingHeaderWidth: holdingHeader.width
        background: Rectangle {
            id: scrollingSeparator
            width: parent.width
            height: 4
            anchors.bottom: parent.bottom
            color: Theme.palette.baseColor2
            visible: (listView.contentY > 0)
        }
        contentItem: Item {
            anchors.fill: parent
            anchors.leftMargin: Style.current.padding
            anchors.rightMargin: Style.current.padding
            clip: true
            RowLayout {
                id: row
                anchors.fill: parent
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
                    Item {  Layout.fillWidth: true }
                }

                ColumnHeader {
                    id: holdingHeader
                    text: qsTr("Hodling")
                    onClicked: {
                        if (sorting !== StatusSortableColumnHeader.Sorting.NoSorting)
                            d.sortBy = TokenHoldersProxyModel.SortBy.Holding
                        else
                            d.sortBy = TokenHoldersProxyModel.SortBy.None
                    }
                }
                Item {
                    Layout.preferredWidth: 233
                    Layout.rightMargin: Style.current.halfPadding
                }
            }
        }
    }

    StatusListView {
        id: listView
        anchors.fill: parent
        anchors.topMargin: header.height
        currentIndex: -1
        component ColumnHeader: StatusSortableColumnHeader {
            id: columnHeader

            leftPadding: 0
            rightPadding: 0
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

        delegate: ItemDelegate {
            id: delegate
            width: ListView.view.width
            height: d.delegateHeight
            padding: 0
            readonly property string name: model.name

            readonly property bool isFirstRowAddress: {
                if (model.name !== "")
                    return false

                const item = listView.itemAtIndex(index - 1)
                return item && item.name
            }

            readonly property bool showSeparator: isFirstRowAddress
                                                  && root.sortBy === TokenHoldersProxyModel.SortBy.Username


            background: Item {
                Rectangle {
                    anchors.fill: parent
                    radius: Style.current.radius
                    color: (delegate.hovered || delegate.ListView.isCurrentItem)
                           ? Theme.palette.baseColor2 : "transparent"
                }

                Rectangle {
                    visible: delegate.showSeparator
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: delegate.topPadding / 2

                    height: 1
                    color: Theme.palette.baseColor2
                }
            }

            contentItem: Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                RowLayout {
                    spacing: Style.current.halfPadding

                    StatusListItem {
                        readonly property bool unknownHolder: model.name === ""
                        readonly property string formattedTitle: unknownHolder ? "?" : model.name
                        Layout.preferredWidth: header.usernameHeaderWidth
                        color: "transparent"
                        leftPadding: 0
                        rightPadding: 0
                        sensor.enabled: false
                        title: formattedTitle
                        statusListItemTitle.visible: !unknownHolder
                        subTitle: Utils.getElidedPk(model.walletAddress)
                        asset.name: model.imageSource
                        asset.isImage: true
                        asset.isLetterIdenticon: !asset.name
                        asset.color: Theme.palette.getColor("red2")
                    }

                    TokenHolderNumberCell {
                        Layout.preferredWidth: header.holdingHeaderWidth
                        Layout.leftMargin: Style.current.halfPadding

                        text: LocaleUtils.numberToLocaleString(model.amount)
                    }

                    Item { Layout.preferredWidth: 100 }

                    StatusComboBox {
                        id: combo
                        Layout.preferredWidth: 68
                        Layout.preferredHeight: 44
                        control.spacing: Style.current.halfPadding / 2
                        model: amount
                        size: StatusComboBox.Size.Small
                        type: StatusComboBox.Type.Secondary
                        delegate: StatusItemDelegate {
                            width: combo.control.width
                            centerTextHorizontally: true
                            highlighted: combo.control.highlightedIndex === index
                            font: combo.control.font
                            text: Number(modelData) + 1
                        }
                        contentItem: StatusBaseText {
                            id: comboText
                            font: combo.control.font
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            color: Theme.palette.baseColor1
                            Component.onCompleted: {
                                if (d.selectedTokenAmount.get(walletAddress) === undefined) {
                                    d.selectedTokenAmount.set(walletAddress, amount);
                                }
                                text = d.selectedTokenAmount.get(walletAddress);
                            }
                        }

                        control.onActivated: {
                            d.selectedTokenAmount.set(walletAddress, (index+1));
                            comboText.text = d.selectedTokenAmount.get(walletAddress);
                            if (checkBox.checked) {
                                root.selfDestructAmountChanged(walletAddress, d.selectedTokenAmount.get(walletAddress))
                            }
                        }
                    }
                    Item { Layout.preferredWidth: 28 }
                    StatusCheckBox {
                        id: checkBox
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignRight
                        visible: root.isSelectorMode
                        padding: 0
                        onCheckStateChanged: {
                            if (checked)
                                root.selfDestructAmountChanged(model.walletAddress, d.selectedTokenAmount.get(walletAddress))
                            else
                                root.selfDestructRemoved(model.walletAddress)

                            d.selectedTokenChecked.set(walletAddress, checked);
                        }
                        Component.onCompleted: {
                            checked = !!d.selectedTokenChecked.get(walletAddress);
                        }
                    }
                }
            }
        }
    }
}
