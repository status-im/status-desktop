import QtQuick 2.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0

import AppLayouts.Chat.panels.communities 1.0

StatusDialog {
    id: root

    // account, amount, symbol, network, feeText
    property alias model: feesPanel.model
    property alias showSummary: feesPanel.showSummary
    property alias errorText: feesPanel.errorText
    property alias totalFeeText: feesPanel.totalFeeText

    property alias isFeeLoading: feesPanel.isFeeLoading

    signal signTransactionClicked()
    signal cancelClicked()

    QtObject {
        id: d

        property int minTextWidth: 50
    }

    implicitWidth: 600 // by design
    topPadding: 2 * Style.current.padding // by design
    bottomPadding: Style.current.bigPadding

    contentItem: FeesPanel {
        id: feesPanel
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Cancel")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.cancelClicked()
                    root.close()
                }
            }
            StatusButton {
                enabled: root.errorText === "" && !root.isFeeLoading
                icon.name: "password"
                text: qsTr("Sign transaction")
                onClicked: {
                    root.signTransactionClicked()
                    root.close()
                }
            }
        }
    }
}
