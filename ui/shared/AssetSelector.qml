import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

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
            iconImg.source = "../app/img/tokens/" + selectedAsset.symbol.toUpperCase() + ".png"
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
            value: assets.rowData(0, "value"),
            fiatBalanceDisplay: assets.rowData(0, "fiatBalanceDisplay"),
            address: assets.rowData(0, "address"),
            fiatBalance: assets.rowData(0, "fiatBalance")
        }
    }

    Select {
        id: select
        width: parent.width
        bgColor: Style.current.transparent
        bgColorHover: Style.current.secondaryHover
        model: root.assets
        caretRightMargin: 7
        select.radius: 6
        select.height: root.height
        menu.width: 343
        selectedItemView: Item {
            anchors.fill: parent
            SVGImage {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: 4
                sourceSize.height: 24
                sourceSize.width: 24
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
            }

            StyledText {
                id: selectedTextField
                anchors.left: iconImg.right
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                height: 22
                verticalAlignment: Text.AlignVCenter
            }
        }

        menu.delegate: menuItem
    }

    Component {
        id: menuItem
        MenuItem {
            id: itemContainer
            property bool isFirstItem: index === 0
            property bool isLastItem: index === assets.rowCount() - 1

            width: parent.width
            height: 72
            SVGImage {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
                sourceSize.height: height
                sourceSize.width: width
                fillMode: Image.PreserveAspectFit
                source: "../app/img/tokens/" + symbol.toUpperCase() + ".png"
            }
            Column {
                anchors.left: iconImg.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    text: symbol.toUpperCase()
                    font.pixelSize: 15
                    height: 22
                }

                StyledText {
                    text: name
                    color: Style.current.secondaryText
                    font.pixelSize: 15
                    height: 22
                }
            }
            Column {
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                StyledText {
                    font.pixelSize: 15
                    height: 22
                    text: parseFloat(value).toFixed(4) + " " + symbol
                }
                StyledText {
                    font.pixelSize: 15
                    anchors.right: parent.right
                    height: 22
                    text: fiatBalanceDisplay.toUpperCase()
                    color: Style.current.secondaryText
                }
            }
            background: Rectangle {
                color: itemContainer.highlighted ? Style.current.backgroundHover : Style.current.background
                radius: Style.current.radius

                // cover bottom left/right corners with square corners
                Rectangle {
                    visible: !isLastItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.radius
                    color: parent.color
                }

                // cover top left/right corners with square corners
                Rectangle {
                    visible: !isFirstItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: parent.radius
                    color: parent.color
                }
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: itemContainer
                onClicked: {
                    root.selectedAsset = { address, name, value, symbol, fiatBalance, fiatBalanceDisplay }
                    select.menu.close()
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
