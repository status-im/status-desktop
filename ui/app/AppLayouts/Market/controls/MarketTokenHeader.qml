import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core.Theme
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Components

Control {
    id: root

    property bool compactMode: false

    QtObject {
        id: d

        property int columnNum: root.compactMode ? 2 : 5

        // Split into 2 or 5 different columns of equal width
        readonly property int columnWidth:
            (root.width - indexText.width - iconWidth - Theme.xlPadding) / d.columnNum
        // Minimum width of a column
        readonly property int minColumnWidth: root.compactMode ? 80 : 130
        // Derived from MarketTokenDelegate
        readonly property int iconWidth: 32
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

                Layout.preferredWidth: idxMetrics.advanceWidth

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
                // set to allign correctly with list
                Layout.preferredWidth: d.columnWidth + d.iconWidth + Theme.padding
                Layout.minimumWidth: d.minColumnWidth + d.iconWidth + Theme.padding
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
                Layout.preferredWidth: d.columnWidth
                Layout.minimumWidth: d.minColumnWidth

                text: qsTr("Price")
                color: Theme.palette.baseColor1
                font.weight: Font.Medium
                font.pixelSize: Theme.additionalTextSize
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight
            }

            // Change 24 Hour
            StatusBaseText {
                Layout.preferredWidth: d.columnWidth
                Layout.minimumWidth: d.minColumnWidth

                visible: !root.compactMode
                text: qsTr("24hr")
                color: Theme.palette.baseColor1
                font.weight: Font.Medium
                font.pixelSize: Theme.additionalTextSize
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight
            }

            // 24 hour Volume
            StatusBaseText {
                Layout.preferredWidth: d.columnWidth
                Layout.minimumWidth: d.minColumnWidth

                visible: !root.compactMode
                text: qsTr("24hr Volume")
                color: Theme.palette.baseColor1
                font.weight: Font.Medium
                font.pixelSize: Theme.additionalTextSize
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight
            }

            // Market Cap
            Item {
                Layout.preferredWidth: d.columnWidth
                Layout.minimumWidth: d.minColumnWidth
                Layout.preferredHeight: childrenRect.height
                visible: !root.compactMode

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

    TextMetrics {
        id: idxMetrics
        font: indexText.font
        text: "999" // Dummy text to calculate width
    }
}
