import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Item {
    id: root
    property var assets
    property var selectedAsset
    property string defaultToken: ""
    property var tokenAssetSourceFn: function (symbol) {
        return ""
    }
    // Define this in the usage to get balance in currency selected by user
    property var getCurrencyBalanceString: function (currencyBalance) { return "" }
    implicitWidth: 86
    implicitHeight: 32

    function resetInternal() {
        assets = null
        selectedAsset = null
    }

    onSelectedAssetChanged: {
        if (selectedAsset && selectedAsset.symbol) {
            iconImg.image.source = tokenAssetSourceFn(selectedAsset.symbol.toUpperCase())
            selectedTextField.text = selectedAsset.symbol.toUpperCase()
        }
    }

    StatusSelect {
        id: select
        width: parent.width
        bgColor: "transparent"
        bgColorHover: Theme.palette.directColor8
        model: root.assets
        caretRightMargin: 0
        select.radius: 6
        select.height: root.height
        selectMenu.width: 342
        selectedItemComponent: Item {
            anchors.fill: parent
            StatusRoundedImage {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: 4
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                image.onStatusChanged: {
                    if (iconImg.image.status === Image.Error) {
                        iconImg.image.source = defaultToken
                    }
                }
            }
            StatusBaseText {
                id: selectedTextField
                anchors.left: iconImg.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                height: 22
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
            }
        }
        selectMenu.delegate: menuItem
    }

    Component {
        id: menuItem
        MenuItem {
            id: itemContainer
            property bool isFirstItem: index === 0
            property bool isLastItem: index === assets.rowCount() - 1

            width: parent.width
            height: 72
            StatusRoundedImage {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                image.source: root.tokenAssetSourceFn(symbol.toUpperCase())
                image.onStatusChanged: {
                    if (iconImg.image.status === Image.Error) {
                        iconImg.image.source = defaultToken
                    }
                }
            }
            Column {
                anchors.left: iconImg.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                StatusBaseText {
                    text: symbol.toUpperCase()
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    text: name
                    color: Theme.palette.baseColor1
                    font.pixelSize: 15
                }
            }
            Column {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                StatusBaseText {
                    font.pixelSize: 15
                    text: parseFloat(balance).toFixed(4) + " " + symbol
                }
                StatusBaseText {
                    font.pixelSize: 15
                    anchors.right: parent.right
                    text: getCurrencyBalanceString(currencyBalance)
                    color: Theme.palette.baseColor1
                }
            }
            background: Rectangle {
                color: itemContainer.highlighted ? Theme.palette.statusSelect.menuItemHoverBackgroundColor : Theme.palette.statusSelect.menuItemBackgroundColor
            }
            Component.onCompleted: {
                if(index === 0 ) {
                    selectedAsset = { name: name, symbol: symbol, address: address, balance: balance, currencyBalance: currencyBalance}
                }
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: itemContainer
                onClicked: {
                    selectedAsset = {name: name, symbol: symbol, address: address, balance: balance, currencyBalance: currencyBalance}
                    select.selectMenu.close()
                }
            }
        }
    }
}
