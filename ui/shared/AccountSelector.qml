import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared"
import "../shared/status"

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
            selectedIconImgOverlay.color = Utils.getCurrentThemeAccountColor(selectedAccount.iconColor) || Style.current.accountColors[0]
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
        txtAssetBalance.text = qsTr("Balance: ") + (parseFloat(assetFound.value) === 0.0 ? "0" : Utils.stripTrailingZeros(assetFound.value))
        txtAssetSymbol.text = " " + assetFound.symbol
    }

    StyledText {
        id: txtAssetBalance
        visible: root.assetFound !== undefined
        anchors.bottom: select.top
        anchors.bottomMargin: -18 
        anchors.right: txtAssetSymbol.left
        anchors.left: select.left
        anchors.leftMargin: select.width / 2.5
        
        color: !root.isValid ? Style.current.danger : Style.current.secondaryText
        elide: Text.ElideRight
        font.pixelSize: 13 * scaleAction.factor
        horizontalAlignment: Text.AlignRight
        height: 18 * scaleAction.factor

        StatusToolTip {
            enabled: txtAssetBalance.truncated
            id: assetTooltip
            text: txtAssetBalance.text
        }

        MouseArea {
            enabled: txtAssetBalance.truncated
            anchors.fill: parent
            hoverEnabled: enabled
            onEntered: assetTooltip.visible = true
            onExited: assetTooltip.visible = false
        }
    }
    StyledText {
        id: txtAssetSymbol
        visible: txtAssetBalance.visible
        anchors.top: txtAssetBalance.top
        anchors.right: parent.right

        color: txtAssetBalance.color
        font.pixelSize: 13 * scaleAction.factor
        height: txtAssetBalance.height
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
                sourceSize.height: 12 * scaleAction.factor
                sourceSize.width: 12 * scaleAction.factor
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
                font.pixelSize: 15 * scaleAction.factor
                verticalAlignment: Text.AlignVCenter
                height: 22 * scaleAction.factor
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
            font.pixelSize: 12 * scaleAction.factor
            elide: Text.ElideMiddle
            height: 16 * scaleAction.factor
            width: 90 * scaleAction.factor
            color: Style.current.secondaryText
        }
        StyledText {
            id: textSelectedAddressFiatBalance
            font.pixelSize: 12 * scaleAction.factor
            height: 16 * scaleAction.factor
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
                width: 12 * scaleAction.factor
                height: 12 * scaleAction.factor
                sourceSize.height: height
                sourceSize.width: width
                fillMode: Image.PreserveAspectFit
                source: "../app/img/walletIcon.svg"
            }
            ColorOverlay {
                anchors.fill: iconImg
                source: iconImg
                color: Utils.getCurrentThemeAccountColor(iconColor) || Style.current.accountColors[0]
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
                    font.pixelSize: 15 * scaleAction.factor
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 22 * scaleAction.factor
                }

                StyledText {
                    id: accountAddress
                    text: address
                    elide: Text.ElideMiddle
                    width: 80 * scaleAction.factor
                    color: Style.current.secondaryText
                    font.pixelSize: 12 * scaleAction.factor
                    height: 16 * scaleAction.factor
                }
            }
            StyledText {
                id: txtFiatBalance
                anchors.right: fiatCurrencySymbol.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15 * scaleAction.factor
                height: 22 * scaleAction.factor
                text: fiatBalance
            }
            StyledText {
                id: fiatCurrencySymbol
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15 * scaleAction.factor
                height: 22 * scaleAction.factor
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



