import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0

Item {
    id: root
    property var assets
    property var selectedAsset
    width: 86
    height: 24

    function resetInternal() {
        assets = undefined
        selectedAsset = undefined
    }

    onSelectedAssetChanged: {
        if (selectedAsset && selectedAsset.symbol) {
            iconImg.image.source = Style.png("tokens/" + selectedAsset.symbol.toUpperCase())
            selectedTextField.text = selectedAsset.symbol.toUpperCase()
        }
    }

    onAssetsChanged: {
        if (!assets) {
            return
        }

        selectedAsset = {
            name: assets.rowData(0, "name"),
            symbol: assets.rowData(0, "symbol"),
            value: assets.rowData(0, "balance"),
            fiatBalanceDisplay: assets.rowData(0, "currencyBalance"),
            address: assets.rowData(0, "address"),
            fiatBalance: assets.rowData(0, "currencyBalance")
        }
    }

    StatusSelect {
        id: select
        width: parent.width
        bgColor: Style.current.transparent
        bgColorHover: Style.current.secondaryHover
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
            property bool isLastItem: index === assets.count - 1

            width: parent.width
            height: 72
            StatusRoundedImage {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                image.source: Style.png("tokens/" + symbol.toUpperCase())
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
                    color: Theme.palette.directColor1
                }
                StatusBaseText {
                    font.pixelSize: 15
                    anchors.right: parent.right
                    height: 22
                    text: currencyBalance.toString().toUpperCase()
                    color: Theme.palette.baseColor1
                }
            }
            background: Rectangle {
                color: itemContainer.highlighted ? Theme.palette.statusSelect.menuItemHoverBackgroundColor : Theme.palette.statusSelect.menuItemBackgroundColor
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: itemContainer
                onClicked: {
                    root.selectedAsset = { address, name, balance, symbol, currencyBalance, fiatBalanceDisplay: "" }
                    select.selectMenu.close()
                }
            }
        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
