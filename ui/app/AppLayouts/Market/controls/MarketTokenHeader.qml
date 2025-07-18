import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core.Theme
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components

Control {
    id: root

    QtObject {
        id: d

        // Split into 4 different equal width columns
        readonly property int columnWidth:
            (root.width - indexText.width - tokenNameText.width - Theme.padding) / columnsShown

        // Minimum width of a column
        readonly property int minColumnWidth: 150

        // Maximum number of columns that can be shown in the list
        // Price, Change 24 Hour, Volume 24 Hour, Market Cap
        readonly property int maxColumns: 4

        // Maximum number of columns that can be shown based on available width
        readonly property int columnsShown:
            Math.min(maxColumns, Math.floor((root.width - indexText.width - tokenNameText.width - Theme.padding) / minColumnWidth))
    }

    padding: 0
    /* by default header has same z order as list (z:1).
       Making it 2 so that the list scrolls behind it */
    z: 2

    // Need a solid background so the list can scroll behind the sticky header
    background: Rectangle {
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
    }

    contentItem: ColumnLayout {
        spacing: 0
        // Divider on top
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.alignment: Qt.AlignTop

            color: Theme.palette.baseColor2
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            // "#"
            StatusBaseText {
                id: indexText

                leftPadding: Theme.padding
                rightPadding: Theme.padding

                text: qsTr("#")
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                lineHeight: 18
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Text.AlignHCenter
            }

            // Token
            StatusBaseText {
                id: tokenNameText

                // set to allign correctly with list
                Layout.preferredWidth: 195
                Layout.leftMargin: Theme.padding

                text: qsTr("Token")
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
            }

            // Price
            StatusBaseText {
                readonly property int priority: 2

                Layout.preferredWidth: d.columnWidth
                Layout.minimumWidth: d.minColumnWidth

                text: qsTr("Price")
                color: Theme.palette.baseColor1
                font.weight: Font.Medium
                font.pixelSize: Theme.additionalTextSize
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight

                visible: d.columnsShown >= priority
            }

            // Change 24 Hour
            StatusBaseText {
                readonly property int priority: 3

                Layout.preferredWidth: d.columnWidth
                Layout.minimumWidth: d.minColumnWidth

                text: qsTr("24hr")
                color: Theme.palette.baseColor1
                font.weight: Font.Medium
                font.pixelSize: Theme.additionalTextSize
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight

                visible: d.columnsShown >= priority
            }

            // 24 hour Volume
            StatusBaseText {
                readonly property int priority: 4

                Layout.preferredWidth: d.columnWidth
                Layout.minimumWidth: d.minColumnWidth

                text: qsTr("24hr Volume")
                color: Theme.palette.baseColor1
                font.weight: Font.Medium
                font.pixelSize: Theme.additionalTextSize
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight

                visible: d.columnsShown >= priority
            }

            // Market Cap
            Item {
                readonly property int priority: 1

                Layout.preferredWidth: d.columnWidth
                Layout.minimumWidth: d.minColumnWidth
                Layout.preferredHeight: childrenRect.height

                StatusSortableColumnHeader {
                    anchors.right: parent.right
                    anchors.top: parent.top

                    rightPadding: Theme.padding

                    sorting: StatusSortableColumnHeader.Sorting.Descending
                    traversalOrder: [
                        StatusSortableColumnHeader.Sorting.Descending
                    ]

                    text: qsTr("Market Cap")
                    enabled: false
                }

                visible: d.columnsShown >= priority
            }
        }
        // Bottom Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.alignment: Qt.AlignTop

            color: Theme.palette.baseColor2
        }
    }
}
