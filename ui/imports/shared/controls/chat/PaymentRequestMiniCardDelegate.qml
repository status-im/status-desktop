import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1

import utils 1.0

CalloutCard {
    id: root

    required property string amount
    required property string symbol

    readonly property bool containsMouse: mouseArea.hovered || closeButton.hovered

    signal close()

    implicitWidth:260
    implicitHeight: 64
    verticalPadding: 15
    horizontalPadding: 12
    borderColor: Theme.palette.directColor7
    backgroundColor: root.containsMouse ? Theme.palette.directColor7 : Theme.palette.background

    contentItem: GridLayout {
        rowSpacing: 0
        columnSpacing: Theme.halfPadding
        columns: 4
        rows: 3

        StatusRoundIcon {
            id: favIcon
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.rowSpan: 3
            asset.width: 24
            asset.height: 24
            asset.bgColor: Theme.palette.directColor7
            asset.bgHeight: 36
            asset.bgWidth: 36
            asset.color: Theme.palette.primaryColor1
            asset.name: Theme.svg("send")

            StatusSmartIdenticon {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.right
                asset.width: 16
                asset.height: 16
                asset.bgColor: root.containsMouse ? Theme.palette.transparent : Theme.palette.background
                asset.bgHeight: 20
                asset.bgWidth: 20
                asset.isImage: true
                asset.name: Constants.tokenIcon(root.symbol)
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: Theme.halfPadding / 2
            Layout.rowSpan: 3
        }

        Item {
            // NOTE this item is added because for some reason the "Payment request" text is not rendered until hover
            Layout.preferredHeight: 1
            Layout.fillWidth: true
        }

        StatusFlatButton {
            id: closeButton
            Layout.rowSpan: 3
            icon.name: "close"
            size: StatusBaseButton.Size.Small
            hoverColor: Theme.palette.directColor8
            textColor: Theme.palette.directColor1
            onClicked: root.close()
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Payment request")
            font.pixelSize: Theme.additionalTextSize
            font.weight: Font.Medium
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Theme.halfPadding / 2
            StatusBaseText {
                id: amountText
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: symbolText.paintedWidth
                font.pixelSize: Theme.tertiaryTextFontSize
                color: Theme.palette.baseColor1
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: root.amount
            }
            StatusBaseText {
                id: symbolText
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: amountText.paintedWidth + Theme.halfPadding
                font.pixelSize: Theme.tertiaryTextFontSize
                color: Theme.palette.baseColor1
                verticalAlignment: Text.AlignVCenter
                text: root.symbol
            }
        }
    }

    HoverHandler {
        id: mouseArea
        target: background
        cursorShape: Qt.PointingHandCursor
    }
}
