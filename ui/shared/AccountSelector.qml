import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    id: root
    //% "Choose account"
    property string label: qsTrId("choose-account")
    property bool showAccountDetails: true
    property var accounts
    property var selectedAccount
    property string currency: "usd"
    property alias selectField: select
    height: select.height +
            (selectedAccountDetails.visible ? selectedAccountDetails.height : 0)
    // set to asset symbol to display asset's balance top right
    // NOTE: if this asset is not selected as a wallet token in the UI, then
    // nothing will be displayed
    property string showBalanceForAssetSymbol: ""
    property var assetFound
    property double minRequiredAssetBalance: 0
    property int dropdownWidth: width
    property alias dropdownAlignment: select.menuAlignment
    property bool isValid: true
    property bool readOnly: false

    function validate() {
        if (showBalanceForAssetSymbol == "" || minRequiredAssetBalance == 0 || !assetFound) {
            return root.isValid
        }
        root.isValid = assetFound.value >= minRequiredAssetBalance
        return root.isValid
    }

    onSelectedAccountChanged: {
        if (!selectedAccount) {
            return
        }
        if (selectedAccount.iconColor) {
            selectedIconImgOverlay.color = selectedAccount.iconColor
        }
        if (selectedAccount.name) {
            selectedTextField.text = selectedAccount.name
        }
        if (selectedAccount.address) {
            textSelectedAddress.text = selectedAccount.address  + " • "
        }
        if (selectedAccount.fiatBalance) {
            textSelectedAddressFiatBalance.text = selectedAccount.fiatBalance + " " + currency.toUpperCase()
        }
        if (selectedAccount.assets && showBalanceForAssetSymbol) {
            assetFound = Utils.findAssetBySymbol(selectedAccount.assets, showBalanceForAssetSymbol)
            if (!assetFound) {
                //% "Cannot find asset '%1'. Ensure this asset has been added to the token list."
                console.warn(qsTrId("cannot-find-asset---1---ensure-this-asset-has-been-added-to-the-token-list-").arg(showBalanceForAssetSymbol))
            }
        }
        if (!selectedAccount.type) {
            selectedAccount.type = RecipientSelector.Type.Account
        }
        validate()
    }

    onAssetFoundChanged: {
        if (!assetFound) {
            return
        }
        txtAssetBalance.text = "Balance: " + (parseFloat(assetFound.value) === 0.0 ? "0" : Utils.stripTrailingZeros(assetFound.value)) + " " + assetFound.symbol
    }

    StyledText {
        id: txtAssetBalance
        visible: root.assetFound !== undefined
        anchors.bottom: select.top
        anchors.bottomMargin: -18 
        anchors.right: parent.right
        
        color: !root.isValid ? Style.current.danger : Style.current.secondaryText
        font.pixelSize: 13
        height: 18
    }
    Select {
        id: select
        label: root.label
        model: root.accounts
        menuAlignment: Select.MenuAlignment.Left
        menu.delegate: menuItem
        menu.onOpened: {
            selectedAccountDetails.visible = false
        }
        menu.onClosed: {
            selectedAccountDetails.visible = root.showAccountDetails
        }
        menu.width: dropdownWidth
        selectedItemView: Item {
            anchors.fill: parent

            SVGImage {
                id: selectedIconImg
                sourceSize.height: 12
                sourceSize.width: 12
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: "../app/img/walletIcon.svg"
            }
            ColorOverlay {
                id: selectedIconImgOverlay
                anchors.fill: selectedIconImg
                source: selectedIconImg
            }

            StyledText {
                id: selectedTextField
                elide: Text.ElideRight
                anchors.left: selectedIconImg.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: select.selectedItemRightMargin
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                verticalAlignment: Text.AlignVCenter
                height: 22
            }
        }
    }

    Row {
        id: selectedAccountDetails
        visible: root.showAccountDetails
        anchors.top: select.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 2

        StyledText {
            id: textSelectedAddress
            font.pixelSize: 12
            elide: Text.ElideMiddle
            height: 16
            width: 90
            color: Style.current.secondaryText
        }
        StyledText {
            id: textSelectedAddressFiatBalance
            font.pixelSize: 12
            height: 16
            color: Style.current.secondaryText
        }
    }

    Component {
        id: menuItem
        MenuItem {
            id: itemContainer
            visible: walletType !== 'watch'
            property bool isFirstItem: index === 0
            property bool isLastItem: index === accounts.rowCount() - 1

            Component.onCompleted: {
                if (!root.selectedAccount && isFirstItem) {
                    root.selectedAccount = { address, name, iconColor, assets, fiatBalance }
                }
            }

            height: walletType === 'watch' ? 0 : (accountName.height + 14 + accountAddress.height + 14)
            SVGImage {
                id: iconImg
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                height: 12
                sourceSize.height: height
                sourceSize.width: width
                fillMode: Image.PreserveAspectFit
                source: "../app/img/walletIcon.svg"
            }
            ColorOverlay {
                anchors.fill: iconImg
                source: iconImg
                color: iconColor
            }
            Column {
                id: column
                anchors.left: iconImg.right
                anchors.leftMargin: 14
                anchors.right: txtFiatBalance.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    id: accountName
                    text: name
                    elide: Text.ElideRight
                    font.pixelSize: 15
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 22
                }

                StyledText {
                    id: accountAddress
                    text: address
                    elide: Text.ElideMiddle
                    width: 80
                    color: Style.current.secondaryText
                    font.pixelSize: 12
                    height: 16
                }
            }
            StyledText {
                id: txtFiatBalance
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
                color: Style.current.secondaryText
                text: root.currency.toUpperCase()
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
                    root.selectedAccount = { address, name, iconColor, assets, fiatBalance }
                    select.menu.close()
                }
            }
        }
    }
}



