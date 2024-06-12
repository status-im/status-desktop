import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

ItemDelegate {
    id: root
    objectName: "tokenSelectorAssetDelegate_" + tokensKey

    required property string tokensKey
    required property string name
    required property string symbol
    required property string currencyBalanceAsString
    // expected structure: balancesModel -> model.balances submodel [chainId: int, balance: BigIntString] + flatNetworks [account:string, iconUrl: string]
    required property var balancesModel

    property bool interactive: true

    signal assetSelected(string tokensKey)

    spacing: Style.current.halfPadding
    horizontalPadding: Style.current.padding
    verticalPadding: 4

    opacity: interactive ? 1 : 0.3

    implicitWidth: ListView.view.width
    implicitHeight: 60

    icon.width: 32
    icon.height: 32
    icon.source: Constants.tokenIcon(symbol)

    enabled: interactive

    background: Rectangle {
        radius: Style.current.radius
        color: (root.interactive && root.hovered) || root.highlighted ? Theme.palette.statusListItem.highlightColor
                                                                      : "transparent"
        HoverHandler {
            cursorShape: root.interactive ? Qt.PointingHandCursor : undefined
        }
    }

    contentItem: RowLayout {
        spacing: root.spacing

        // asset icon
        StatusRoundedImage {
            Layout.preferredWidth: root.icon.width
            Layout.preferredHeight: root.icon.height
            image.source: root.icon.source
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            // name, symbol, total balance
            RowLayout {
                Layout.fillWidth: true
                spacing: root.spacing
                Item {
                    id: nameRow
                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height
                    StatusBaseText {
                        id: nameText
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(implicitWidth, nameRow.width - symbolText.width - symbolText.anchors.leftMargin)
                        text: root.name
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    StatusBaseText {
                        id: symbolText
                        anchors.left: nameText.right
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.symbol
                        color: Theme.palette.baseColor1
                    }
                }
                StatusBaseText {
                    font.weight: Font.Medium
                    text: root.currencyBalanceAsString
                }
            }

            // balances per network chain
            StatusListView {
                Layout.maximumWidth: parent.width
                Layout.preferredWidth: contentWidth
                Layout.preferredHeight: 22
                orientation: ListView.Horizontal
                spacing: root.spacing
                visible: count
                interactive: !root.ListView.view.moving
                ScrollBar.horizontal: null

                model: root.balancesModel
                delegate: RowLayout {
                    height: ListView.view.height
                    spacing: 4
                    StatusRoundedImage {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        image.source: Style.svg("tiny/%1".arg(model.iconUrl))
                    }
                    StatusBaseText {
                        font.pixelSize: Theme.tertiaryTextFontSize
                        text: model.balanceAsString
                    }
                }
                // let the root handle the click
                TapHandler {
                    onTapped: root.clicked()
                }
            }
        }
    }

    onClicked: root.assetSelected(root.tokensKey)
}
