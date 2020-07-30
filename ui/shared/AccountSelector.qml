import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    id: root
    property string label: qsTr("Choose account")
    property var accounts
    property var selectedAccount: {
        "address": "", "name": "", "iconColor": "", "fiatBalance": ""
    }
    height: select.height + selectedAccountDetails.height
    // set to asset symbol to display asset's balance top right
    // NOTE: if this asset is not selected as a wallet token in the UI, then
    // nothing will be displayed
    property string showAssetBalance: ""

    Repeater {
        visible: showAssetBalance !== ""
        model: selectedAccount.assets
        delegate: StyledText {
            visible: symbol === root.showAssetBalance.toUpperCase()
            anchors.bottom: select.top
            anchors.bottomMargin: -18 
            anchors.right: parent.right
            text: "Balance: " + (parseFloat(value) === 0.0 ? "0" : value) + " " + symbol
            color: parseFloat(value) === 0.0 ? Style.current.red : Style.current.darkGrey
            font.pixelSize: 13
            height: 18
        }
    }
    Select {
        id: select
        icon: "../app/img/walletIcon.svg"
        iconColor: selectedAccount.iconColor || Style.current.blue
        label: root.label
        selectedText: selectedAccount.name
        model: root.accounts

        menu.delegate: menuItem
        menu.onOpened: {
            selectedAccountDetails.visible = false
        }
        menu.onClosed: {
            selectedAccountDetails.visible = true
        }
    }

    Row {
        id: selectedAccountDetails
        anchors.top: select.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 2

        StyledText {
            id: textSelectedAddress
            text: selectedAccount.address
            font.pixelSize: 12
            elide: Text.ElideMiddle
            height: 16
            width: 80
            color: Style.current.darkGrey
        }
        StyledText {
            text: " • "
            font.pixelSize: 12
            height: 16
            color: Style.current.darkGrey
        }
        StyledText {
            text: selectedAccount.fiatBalance + " " + walletModel.defaultCurrency.toUpperCase()
            font.pixelSize: 12
            height: 16
            color: Style.current.darkGrey
        }
    }

    Component {
        id: menuItem
        MenuItem {
            id: itemContainer
            property color bgColor: Style.current.white
            property bool isFirstItem: index === 0
            property bool isLastItem: index === accounts.rowCount() - 1

            Component.onCompleted: {
                if (root.selectedAccount.address === "") {
                    root.selectedAccount = { address, name, iconColor, assets, fiatBalance }
                }
            }

            height: accountName.height + 14 + accountAddress.height + 14
            SVGImage {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                width: select.iconWidth
                height: select.iconHeight
                sourceSize.height: select.iconHeight
                sourceSize.width: select.iconWidth
                fillMode: Image.PreserveAspectFit
                source: select.icon
            }
            ColorOverlay {
                anchors.fill: iconImg
                source: iconImg
                color: iconColor
            }
            Column {
                anchors.left: iconImg.right
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    id: accountName
                    text: name
                    font.pixelSize: 15
                    height: 22
                }

                StyledText {
                    id: accountAddress
                    text: address
                    elide: Text.ElideMiddle
                    width: 80
                    color: Style.current.darkGrey
                    font.pixelSize: 12
                    height: 16
                }
            }
            StyledText {
                anchors.right: fiatCurrencySymbol.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                height: 22
                text: fiatBalance
            }
            StyledText {
                id: fiatCurrencySymbol
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                height: 22
                color: Style.current.darkGrey
                text: walletModel.defaultCurrency.toUpperCase()
            }
            background: Rectangle {
                color: itemContainer.bgColor
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
                hoverEnabled: true
                onEntered: {
                    itemContainer.bgColor = Style.current.lightGrey
                }
                onExited: {
                    itemContainer.bgColor = Style.current.white
                }
                onClicked: {
                    root.selectedAccount = { address, name, iconColor, assets, fiatBalance }
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
