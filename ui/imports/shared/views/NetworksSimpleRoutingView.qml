import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"

RowLayout {
    id: networksSimpleRoutingView

    property var selectedNetwork
    property var suggestedRoutes
    property double amountToSend: 0

    signal networkChanged(var network)

    spacing: 10

    StatusRoundIcon {
        Layout.alignment: Qt.AlignTop
        radius: 8
        icon.name: "flash"
    }
    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        StatusBaseText {
            Layout.maximumWidth: 410
            font.pixelSize: 15
            font.weight: Font.Medium
            color: Theme.palette.directColor1
            text: qsTr("Networks")
            wrapMode: Text.WordWrap
        }
        StatusBaseText {
            Layout.maximumWidth: 410
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("Choose a network to use for the transaction")
            wrapMode: Text.WordWrap
        }
        BalanceExceeded {
            Layout.topMargin: Style.current.bigPadding
            Layout.alignment: Qt.AlignCenter
            visible: !transferPossible
            transferPossible: networksSimpleRoutingView.suggestedRoutes ? networksSimpleRoutingView.suggestedRoutes.length > 0 : false
            amountToSend: networksSimpleRoutingView.amountToSend
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: row.height + 10
            Layout.topMargin: Style.current.bigPadding
            contentWidth: row.width
            contentHeight: row.height + 10
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            clip: true
            visible: networksSimpleRoutingView.suggestedRoutes ? networksSimpleRoutingView.suggestedRoutes.length > 0 : false
            Row {
                id: row
                spacing: Style.current.padding
                Repeater {
                    id: repeater
                    model: networksSimpleRoutingView.suggestedRoutes
                    StatusListItem {
                        id: item
                        leftPadding: 5
                        rightPadding: 5
                        implicitWidth: 126
                        title: modelData.chainName
                        subTitle: ""
                        image.width: 32
                        image.height: 32
                        image.source: Style.png("networks/" + modelData.chainName.toLowerCase())
                        color: "transparent"
                        border.color: Style.current.primary
                        border.width: networksSimpleRoutingView.selectedNetwork !== undefined ? networksSimpleRoutingView.selectedNetwork.chainId === modelData.chainId ? 1 : 0 : 0
                        onClicked: networksSimpleRoutingView.networkChanged(modelData)
                    }
                }
            }
        }
    }
}
