import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

import shared.controls 1.0

/**
    Expected model structure:
    name                    [string] - account name e.g. "Piggy Bank"
    address                 [string] - wallet account address e.g. "0x1234567890"
    colorizedChainPrefixes  [string] - chain prefixes with rich text colors e.g. "<font color=\"red\">eth:</font><font color=\"blue\">oeth:</font><font color=\"green\">arb:</font>"
    emoji                   [string] - emoji for account e.g. "🐷"
    colorId                 [string] - color id for account e.g. "1"
    currencyBalance         [var]    - fiat currency balance
        amount              [number] - amount of currency e.g. 1234
        symbol              [string] - currency symbol e.g. "USD"
        optDisplayDecimals  [number] - optional number of decimals to display
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
    readonly property string currentAccountAddress: root.control.currentValue ?? ""

    // styling options
    type: StatusComboBox.Type.Secondary
    size: StatusComboBox.Size.Small

    currentIndex: {
        if (count === 0) return
        return Math.max(control.indexOfValue(d.currentAccountSelection), 0)
    }

    objectName: "accountSelector"
    popupContentItemObjectName: "accountSelectorList"

    control.popup.width: 430

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
            font.pixelSize: 13
            color: Theme.palette.directColor1
        }
    }

    delegate: WalletAccountListItem {  
        id: delegateItem

        required property var model

        width: ListView.view.width
        name: model.name
        address: model.address
        chainShortNames: model.colorizedChainPrefixes ?? ""
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
        value: control.currentValue
    }

    QtObject {
        id: d
        property string currentAccountSelection: root.selectedAddress

        Binding on currentAccountSelection {
            value: root.selectedAddress
        }
    }
}

