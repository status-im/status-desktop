import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import AppLayouts.Wallet 1.0

import utils 1.0

StatusButton {
    id: root

    required property double value
    required property string symbol
    required property bool valid
    property var formatCurrencyAmount: (amount, symbol) => { return "FIXME" }

    readonly property double maxSafeValue: WalletUtils.calculateMaxSafeSendAmount(value, symbol)
    readonly property string maxSafeValueAsString: maxSafeValue.toLocaleString(locale, 'f', -128)

    locale: LocaleUtils.userInputLocale

    implicitHeight: 22

    type: valid ? StatusBaseButton.Type.Normal : StatusBaseButton.Type.Danger
    text: qsTr("Max. %1").arg(value === 0 ? locale.zeroDigit : root.formatCurrencyAmount(maxSafeValue, root.symbol))

    horizontalPadding: 8
    verticalPadding: 3
    radius: 20
    font.pixelSize: 12
    font.weight: Font.Normal
}
