import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.controls 1.0

import utils 1.0

ColumnLayout {
    id: root

    property string caption

    property alias components: delegate.components
    property alias highlighted: delegate.highlighted
    property int listItemHeight: 76

    required property string address
    property string name
    property string ens
    property string emoji
    property string walletColor

    StatusBaseText {
        text: root.caption
        font.pixelSize: Theme.additionalTextSize
    }
    RecipientViewDelegate {
        id: delegate
        objectName: "recipientDelegate"

        Layout.fillWidth: true
        Layout.preferredHeight: root.listItemHeight

        address: root.address
        name: root.name
        ens: root.ens
        emoji: root.emoji
        walletColor: root.walletColor

        elideAddressInTitle: true
        useAddressAsLetterIdenticon: !root.name && !root.ens

        sensor.enabled: false

        statusListItemSubTitle.font.pixelSize: Theme.additionalTextSize
        statusListItemTitle.customColor: Theme.palette.directColor1
        statusListItemTitle.font.pixelSize: Theme.additionalTextSize
        statusListItemTitle.elide: Text.ElideMiddle
        border.width: 1
        border.color: Theme.palette.baseColor2

        asset.bgWidth: 40
        asset.bgHeight: 40
        rightPadding: Theme.padding
    }
}
