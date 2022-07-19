import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import "../controls"
import "../stores"

Item {
    id: root

    property string locale: ""
    property string currency: ""
    property var currentAccount
    property var store
    property var walletStore

    implicitHeight: childrenRect.height

    GridLayout {
        width: parent.width
        rowSpacing: Style.current.halfPadding
        columns: 2

        // account + balance
        Row {
            spacing: Style.current.halfPadding
            StatusBaseText {
                font.pixelSize: 28
                font.bold: true
                text: currentAccount.name
            }
            StatusBaseText {
                font.pixelSize: 28
                font.bold: true
                color: Theme.palette.baseColor1
                text: "%1 %2".arg(Utils.toLocaleString(root.currentAccount.currencyBalance.toFixed(2), root.locale, {"currency": true})).arg(root.currency.toUpperCase())
            }
        }

        // network filter
        NetworkFilter {
            id: networkFilter
            Layout.alignment: Qt.AlignTrailing
            Layout.fillHeight: true
            Layout.rowSpan: 2
            store: root.walletStore
        }

        // account address button
        Button {
            horizontalPadding: Style.current.halfPadding
            verticalPadding: 5
            Layout.preferredWidth: 150
            background: Rectangle {
                implicitWidth: 150
                implicitHeight: 32
                color: "transparent"
                border.width: 1
                border.color: Theme.palette.baseColor2
                radius: 36
            }

            contentItem: RowLayout {
                spacing: 4
                StatusIcon {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    icon: "address"
                    color: Theme.palette.baseColor2
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    text: currentAccount.mixedcaseAddress
                    color: Theme.palette.directColor5
                    elide: Text.ElideMiddle
                    font.pixelSize: Style.current.primaryTextFontSize
                    font.weight: Font.Medium
                }
            }
            onClicked: store.copyToClipboard(currentAccount.mixedcaseAddress)
        }
    }
}
