import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2

Item {
    id: root

    property string label: "Choose account"
    property bool showAccountDetails: !!selectedAccount
    property var accounts
    property var selectedAccount
    property string currency: "USD"

    // set to asset symbol to display asset's balance top right
    // NOTE: if this asset is not selected as a wallet token in the UI, then
    // nothing will be displayed
    property string showBalanceForAssetSymbol: ""
    property var assetFound
    property double minRequiredAssetBalance: 0
    property int dropdownWidth: width
    property int chainId: 0
    property bool isValid: true
    property bool readOnly: false


    property var assetBalanceTextFn: function (foundValue) {
        return "Balance: " + (parseFloat(foundValue) === 0.0 ? "0" : Utils.stripTrailingZeros(foundValue))
    }

    readonly property string watchWalletType: "watch"

    enum Type {
        Address,
        Contact,
        Account
    }

    function validate() {
        if (showBalanceForAssetSymbol == "" || minRequiredAssetBalance == 0 || !assetFound) {
            return root.isValid
        }
        root.isValid = assetFound.totalBalance.amount >= minRequiredAssetBalance
        return root.isValid
    }

    implicitWidth: 448
    implicitHeight: comboBox.height +
                    (selectedAccountDetails.visible ? selectedAccountDetails.height + selectedAccountDetails.anchors.topMargin
                                                    : 0)

    onSelectedAccountChanged: {
        if (!selectedAccount) {
            return
        }
        if (selectedAccount.color) {
            d.selectedIconColor = Utils.getThemeAccountColor(selectedAccount.color, Theme.palette.userCustomizationColors) || Theme.palette.userCustomizationColors[0]
        }
        if (selectedAccount.name) {
            d.selectedText = selectedAccount.name
        }
        if (selectedAccount.address) {
            textSelectedAddress.text = selectedAccount.address
        }
        if (selectedAccount.currencyBalance) {
            textSelectedAddressFiatBalance.text = LocaleUtils.currencyAmountToLocaleString(selectedAccount.currencyBalance)
        }
        if (selectedAccount.assets && showBalanceForAssetSymbol) {
            assetFound = Utils.findAssetByChainAndSymbol(root.chainId, selectedAccount.assets, showBalanceForAssetSymbol)
            if (!assetFound) {
                console.warn("Cannot find asset '", showBalanceForAssetSymbol, "'. Ensure this asset has been added to the token list.")
            }
        }
        if (!selectedAccount.type) {
            selectedAccount.type = StatusAccountSelector.Type.Account
        }
        validate()
    }

    onAssetFoundChanged: {
        if (!assetFound) {
            return
        }
        txtAssetBalance.text = root.assetBalanceTextFn(assetFound.totalBalance.amount)
        txtAssetSymbol.text = " " + assetFound.symbol
    }

    QtObject {
        id: d
        property color selectedIconColor: "transparent"
        property string selectedText: ""
    }

    StatusBaseText {
        id: txtAssetBalance
        visible: root.assetFound !== undefined
        anchors.bottom: comboBox.top
        anchors.bottomMargin: -18
        anchors.right: txtAssetSymbol.left
        anchors.left: comboBox.left
        anchors.leftMargin: comboBox.width / 2.5

        color: !root.isValid ? Theme.palette.dangerColor1 : Theme.palette.baseColor1
        elide: Text.ElideRight
        font.pixelSize: 13
        horizontalAlignment: Text.AlignRight
        height: 18

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

    StatusBaseText {
        id: txtAssetSymbol
        visible: txtAssetBalance.visible
        anchors.top: txtAssetBalance.top
        anchors.right: parent.right

        color: txtAssetBalance.color
        font.pixelSize: 13
        height: txtAssetBalance.height
    }

    StatusComboBox {
        id: comboBox

        label: root.label
        width: parent.width

        model: SortFilterProxyModel {
            sourceModel: !!root.accounts ? root.accounts : null
            filters: [
                ValueFilter {
                    roleName: "walletType"
                    value: root.watchWalletType
                    inverted: true
                }
            ]
        }
        contentItem: RowLayout {
            spacing: 8

            StatusIcon {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                icon: "filled-account"
                color: d.selectedIconColor
            }

            StatusBaseText {
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.fillHeight: true
                font.pixelSize: 15
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: d.selectedText
            }
        }

        delegate: StatusItemDelegate {
            highlighted: index === comboBox.control.highlightedIndex
            width: comboBox.width
            padding: 16

            onClicked: {
                // WARNING: Settings comboBox value from delegate is wrong.
                //          ComboBox must have a single role as "value"
                //          This should be refactored later. Probably roleValue should be 'address'.
                //          All other needed values should be retrived from model by the user of component.
                root.selectedAccount = { address, name, color: model.color, assets, currencyBalance };
            }

            Component.onCompleted: {
                // WARNING: Same here, this is wrong, check comment above.
                if (!root.selectedAccount && index === 0) {
                    root.selectedAccount = { address, name, color: model.color, assets, currencyBalance }
                }
            }

            contentItem: RowLayout {
                spacing: 0

                StatusIcon {
                    id: iconImg
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    icon: "filled-account"
                    color: Utils.getThemeAccountColor(model.color, Theme.palette.userCustomizationColors) ||
                           Theme.palette.userCustomizationColors[0]
                }

                ColumnLayout {
                    id: column
                    Layout.fillWidth: true
                    Layout.leftMargin: 14
                    Layout.rightMargin: 8
                    spacing: 0

                    StatusBaseText {
                        id: accountName
                        Layout.fillWidth: true
                        text: model.name
                        elide: Text.ElideRight
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }

                    StatusBaseText {
                        id: accountAddress
                        Layout.fillWidth: true
                        Layout.maximumWidth: 80
                        text: address
                        elide: Text.ElideMiddle
                        color: Theme.palette.baseColor1
                        font.pixelSize: 12
                    }
                }
                StatusBaseText {
                    id: txtFiatBalance
                    Layout.rightMargin: 4
                    font.pixelSize: 15
                    text: LocaleUtils.currencyAmountToLocaleString(currencyBalance, {noSymbol: true})
                    color: Theme.palette.directColor1
                }
                StatusBaseText {
                    id: fiatCurrencySymbol
                    font.pixelSize: 15
                    color: Theme.palette.baseColor1
                    text: root.currency.toUpperCase()
                }
            }
        }
    }

    RowLayout {
        id: selectedAccountDetails
        visible: root.showAccountDetails
        anchors.top: comboBox.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: 4

        spacing: 2

        StatusBaseText {
            id: textSelectedAddress
            Layout.maximumWidth: 80
            font.pixelSize: 12
            elide: Text.ElideMiddle
            color: Theme.palette.baseColor1
        }
        StatusBaseText {
            font.pixelSize: 12
            color: Theme.palette.baseColor1
            text: "•"
        }
        StatusBaseText {
            id: textSelectedAddressFiatBalance
            Layout.fillWidth: true
            font.pixelSize: 12
            color: Theme.palette.baseColor1
        }
    }
}

