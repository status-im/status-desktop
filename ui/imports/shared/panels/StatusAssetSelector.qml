import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Item {
    id: root
    property var assets
    property var selectedAsset
    property string defaultToken
    property string userSelectedToken
    property var tokenAssetSourceFn: function (symbol) {
        return ""
    }
    // Define this in the usage to get balance in currency selected by user
    property var getCurrencyBalanceString: function (currencyBalance) { return "" }
    implicitWidth: select.width
    implicitHeight: 48

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
        width: visualRect.width
        model: root.assets
        caretVisible: false
        caretRightMargin: 0
        bgColor: Style.current.transparent
        bgColorHover: Theme.palette.directColor8
        select.radius: 16
        select.height: root.height
        selectMenu.width: 342
        selectMenu.height: 416
        selectedItemComponent: Rectangle {
            id: visualRect
            width: row.width + Style.current.padding
            height: parent.height
            color: Style.current.transparent
            border.width: 1
            border.color: Theme.palette.directColor8
            radius: 16
            Row {
                id: row
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Style.current.halfPadding
                spacing: Style.current.halfPadding
                StatusBaseText {
                    id: selectedTextField
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 15
                    width: Math.min(50, implicitWidth)
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.palette.directColor1
                    font.weight: Font.Medium
                }
                StatusRoundedImage {
                    id: iconImg
                    width: 40
                    height: 40
                    image.onStatusChanged: {
                        if (iconImg.image.status === Image.Error) {
                            iconImg.image.source = defaultToken
                        }
                    }
                }
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
            contentItem: Item {
                anchors.fill: parent
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
                        text: parseFloat(totalBalance).toFixed(4) + " " + symbol
                    }
                    StatusBaseText {
                        font.pixelSize: 15
                        anchors.right: parent.right
                        text: getCurrencyBalanceString(totalCurrencyBalance)
                        color: Theme.palette.baseColor1
                    }
                }
            }
            background: Rectangle {
                color: itemContainer.highlighted ? Theme.palette.statusSelect.menuItemHoverBackgroundColor : Theme.palette.statusSelect.menuItemBackgroundColor
            }
            Component.onCompleted: {
                if(userSelectedToken === "") {
                    if(index === 0) {
                        selectedAsset = model
                    }
                } else {
                    if(symbol === userSelectedToken) {
                        selectedAsset = model
                    }
                }
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: itemContainer
                onClicked: {
                    userSelectedToken = symbol
                    selectedAsset = model
                    select.selectMenu.close()
                }
            }
        }
    }
}
