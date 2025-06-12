import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import QtGraphicalEffects 1.15

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

import shared.controls 1.0

import QtModelsToolkit 1.0

/**
    Expected model structure:
    name                    [string] - account name e.g. "Piggy Bank"
    address                 [string] - wallet account address e.g. "0x1234567890"
    emoji                   [string] - emoji for account e.g. "🐷"
    colorId                 [string] - color id for account e.g. "1"
    currencyBalance         [var]    - fiat currency balance
        amount              [number] - amount of currency e.g. 1234
        symbol              [string] - currency symbol e.g. "USD"
        displayDecimals     [number] - optional number of decimals to display
        stripTrailingZeroes [bool]   - strip trailing zeroes
    walletType              [string] - wallet type e.g. Constants.watchWalletType. See `Constants` for possible values
    migratedToKeycard       [bool]   - whether account is migrated to keycard
    accountBalance          [var]    - account balance for a specific network
        formattedBalance    [string] - formatted balance e.g. "1234.56B"
        balance             [string] - balance e.g. "123456000000"
        iconUrl             [string] - icon url e.g. "network/Network=Hermez"
        chainColor          [string] - chain color e.g. "#FF0000"
**/

StatusComboBox {
    id: root

    // input property for programatic selection
    property string selectedAddress: ""
    // output property for selected account
    readonly property alias currentAccount: selectedEntry.item
    readonly property string currentAccountAddress: d.currentAccountSelection

    // styling options
    type: StatusComboBox.Type.Secondary
    size: StatusComboBox.Size.Small

    currentIndex: 0

    objectName: "accountSelector"
    popupContentItemObjectName: "accountSelectorList"

    control.popup.width: 430
    control.popup.background: Rectangle {
        radius: Theme.radius
        color: Theme.palette.background
        border.color: Theme.palette.border
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    control.valueRole: "address"
    control.textRole: "name"
    implicitHeight: control.implicitHeight
    implicitWidth: control.implicitWidth

    contentItem: RowLayout {
        id: contentItemRow

        spacing: 4

        StatusSmartIdenticon {
            id: assetContent
            objectName: "assetContent"
            asset.emoji: currentAccount.emoji ?? ""
            asset.color: currentAccount.color ?? Theme.palette.baseColor1
            asset.width: 24
            asset.height: asset.width
            asset.isLetterIdenticon: !!currentAccount.emoji
            asset.bgColor: Theme.palette.primaryColor3
            visible: !!currentAccount.emoji
        }

        StatusBaseText {
            id: textContent
            objectName: "textContent"
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: currentAccount.name ?? ""
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: Theme.palette.directColor1
            font.pixelSize: Theme.additionalTextSize
        }
    }

    delegate: WalletAccountListItem {  
        id: delegateItem

        required property var model

        tagsScrollBarVisible: false

        width: ListView.view.width
        name: model.name
        address: model.address
        emoji: model.emoji
        walletColor: Utils.getColorForId(model.colorId)
        currencyBalance: model.currencyBalance
        walletType: model.walletType
        migratedToKeycard: model.migratedToKeycard ?? false
        accountBalance: model.accountBalance ?? null
        color: sensor.containsMouse || highlighted ?
                   Theme.palette.baseColor2 :
                   !!currentAccount && currentAccount.name === model.name ? Theme.palette.statusListItem.highlightColor : "transparent"
        onClicked: {
            d.currentAccountSelection = model.address
            control.popup.close()
        }
    }

    ModelEntry {
        id: selectedEntry
        sourceModel: root.model ?? null
        key: "address"
        value: d.currentAccountSelection
        onAvailableChanged: {
            if (!available) {
                d.resetSelection()
            }
        }
    }

    QtObject {
        id: d
        property string currentAccountSelection

        Binding on currentAccountSelection {
            value: root.selectedAddress || root.currentValue
        }

        function resetSelection() {
            currentAccountSelection = ""
        }
    }

    Component.onCompleted: {
        if (!selectedEntry.available)
            d.resetSelection()
    }
}

