import QtQuick

import StatusQ.Components
import StatusQ.Core.Theme

import AppLayouts.Communities.controls
import utils

StatusGroupBox {
    id: root

    title: qsTr("Fees")
    icon: Theme.svg("gas")

    // expected roles:
    //
    // title (string)
    // feeText (string)
    // error (bool), optional
    property alias model: feesBox.model
    readonly property alias count: feesBox.count

    readonly property alias accountsSelector: footer.accountsSelector
    property alias showAccountsSelector: footer.showAccountsSelector

    property alias placeholderText: feesBox.placeholderText

    property alias totalFeeText: footer.totalFeeText

    property alias generalErrorText: footer.generalErrorText
    property alias accountErrorText: footer.accountErrorText

    property string accountSelectorText: qsTr("Select account to pay gas fees from")

    FeesPanel {
        id: feesBox

        width: root.availableWidth
        padding: Theme.padding

        verticalPadding: 20

        background: Rectangle {
            radius: Theme.radius
            color: Theme.palette.statusListItem.backgroundColor
        }

        footer: FeesBoxFooter {
            id: footer

            visible: feesBox.count && (root.showAccountsSelector || showTotal
                     || root.generalErrorText)

            showTotal: feesBox.count > 1
            accountSelectorText: root.accountSelectorText
        }
    }
}
