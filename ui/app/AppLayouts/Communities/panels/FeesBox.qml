import QtQuick 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.controls 1.0
import utils 1.0

StatusGroupBox {
    id: root

    title: qsTr("Fees")
    icon: Style.svg("gas")

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
        padding: Style.current.padding

        verticalPadding: 20

        background: Rectangle {
            radius: Style.current.radius
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
