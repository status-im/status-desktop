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
    id: root

    property var bestRoutes
    property double amountToSend: 0
    property bool isLoading: false
    property var weiToEth: function(wei) {}

    spacing: 10

    StatusRoundIcon {
        Layout.alignment: Qt.AlignTop
        radius: 8
        asset.name: "flash"
    }
    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.preferredWidth: root.width
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
            text: qsTr("The networks where the receipient will receive tokens. Amounts calculated automatically for the lowest cost.")
            wrapMode: Text.WordWrap
        }
        BalanceExceeded {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Style.current.bigPadding
            transferPossible: root.bestRoutes !== undefined ? root.bestRoutes.length > 0 : true
            amountToSend: root.amountToSend
            isLoading: root.isLoading
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
            visible: !root.isLoading ? root.bestRoutes !== undefined ? root.bestRoutes.length > 0 : true : false
            Row {
                id: row
                spacing: Style.current.padding
                Repeater {
                    id: repeater
                    objectName: "networksList"
                    model: root.bestRoutes
                    StatusListItem {
                        id: item
                        objectName: modelData.toNetwork.chainName
                        leftPadding: 5
                        rightPadding: 5
                        implicitWidth: 150
                        title: modelData.toNetwork.chainName
                        subTitle: root.weiToEth(modelData.amountIn)
                        statusListItemSubTitle.color: Theme.palette.primaryColor1
                        asset.width: 32
                        asset.height: 32
                        asset.name: Style.svg("tiny/" + modelData.toNetwork.iconUrl)
                        asset.isImage: true
                        color: "transparent"
                    }
                }
            }
        }
    }
}
