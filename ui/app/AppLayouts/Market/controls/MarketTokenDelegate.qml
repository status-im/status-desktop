import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

StatusItemDelegate {
    id: root

    /** Input property representing token name **/
    property string tokenName
    /** Input property representing token symbol **/
    property string tokenSymbol
    /** Input property representing icon source for token **/
    property string iconSource
    /** Input property representing token market price **/
    property string price
    /* Input property representing color of text -
    - green: if change is positive
    - red: if change is negative */
    property string changePct24HourColor
    /* Input property representing percentage change in
    market price in the last 24 hours */
    property string changePct24Hour
    /* Input property representing volume
    in last 24 hours */
    property string volume24Hour
    /* Input property representing token market cap */
    property string marketCap
    /* Input property if token is loading */
    property bool loading
    /** Input property representing index of token list **/
    property string indexString
    /** Input property holding if token should be min window size mode **/
    property bool isSmallWindow
    /** Input property holding if token is last item in the list **/
    property bool isLastItem

    QtObject {
        id: d
        // Split into 4 different columns of equal width
        readonly property int columnWidth:
            (root.width - indexText.width - icon.width - nameSymbolBox.width - 28) / 4
    }

    implicitHeight: 76
    padding: 0
    cursorShape: Qt.ArrowCursor

    background: Rectangle {
        color: root.hovered ? Theme.palette.baseColor4: Theme.palette.transparent
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Divider on top
        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.palette.baseColor2
            visible: index > 0
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            // Index
            StatusTextWithLoadingState {
                id: indexText

                objectName: "indexText"
                Layout.preferredWidth: 52

                text: root.indexString
                font.pixelSize: Theme.additionalTextSize
                lineHeight: 18
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Text.AlignHCenter
                leftPadding: 0
                loading: root.loading
            }

            // Token Icon
            StatusRoundedImage {
                id: icon

                objectName: "icon"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                Layout.leftMargin: Theme.padding

                image.source: root.iconSource
                LoadingComponent {
                    anchors.fill: parent
                    visible: root.loading
                }
            }

            // Name + Symbol
            ColumnLayout {
                id: nameSymbolBox

                Layout.leftMargin: 12
                spacing: 0

                StatusTextWithLoadingState {
                    id: tokenNameText

                    objectName: "tokenNameText"

                    // width by design
                    Layout.preferredWidth: root.isSmallWindow ? 150: 340

                    text: root.tokenName
                    font.weight: Font.Medium
                    lineHeight: 22
                    lineHeightMode: Text.FixedHeight
                    leftPadding: 0
                    loading: root.loading
                    elide: Text.ElideRight
                }
                StatusTextWithLoadingState {
                    objectName: "tokenSymbolText"

                    Layout.preferredWidth: tokenNameText.width

                    text: root.tokenSymbol
                    customColor: Theme.palette.baseColor1
                    lineHeight: 22
                    lineHeightMode: Text.FixedHeight
                    leftPadding: 0
                    loading: root.loading
                    visible: !!text
                }
            }

            // Price
            StatusTextWithLoadingState {
                objectName: "priceText"

                Layout.preferredWidth: d.columnWidth

                text: root.price
                font.weight: Font.Medium
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight
                leftPadding: d.columnWidth - maximumLoadingStateWidth
                loading: root.loading
            }

            // Change 24 Hour
            StatusTextWithLoadingState {
                objectName: "changePct24HrText"

                Layout.preferredWidth: d.columnWidth

                text: root.changePct24Hour
                customColor: root.changePct24HourColor
                font.weight: Font.Medium
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight
                leftPadding: d.columnWidth - maximumLoadingStateWidth
                loading: root.loading
            }

            // 24 hour Volume
            StatusTextWithLoadingState {
                objectName: "volume24HrText"

                Layout.preferredWidth: d.columnWidth

                text: root.volume24Hour
                font.weight: Font.Medium
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight
                leftPadding: d.columnWidth - maximumLoadingStateWidth
                loading: root.loading
            }

            // Market Cap
            StatusTextWithLoadingState {
                objectName: "marketCapText"

                Layout.preferredWidth: d.columnWidth

                text: root.marketCap
                font.weight: Font.Medium
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                horizontalAlignment: Qt.AlignRight
                leftPadding: d.columnWidth - maximumLoadingStateWidth
                rightPadding: Theme.padding
                loading: root.loading
            }
        }

        // Divider at the bottom
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.palette.baseColor2
            visible: root.isLastItem
        }
    }
}
