import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Control {
    id: root

    /** Input property holding if token should be min window size mode **/
    property bool isSmallWindow

    QtObject {
        id: d
        // Split into 4 different equal width columns
        readonly property int columnWidth:
            (root.width - indexText.width - tokenNameText.width - Theme.padding) / 4
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

                // width by design
                Layout.preferredWidth: 52

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

                Layout.preferredWidth: root.isSmallWindow ? 234: 384
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
