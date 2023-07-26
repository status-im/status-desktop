import QtQuick 2.15
import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.panels 1.0

StatusDialog {
    id: root

    // expected roles:
    //
    // title (string)
    // feeText (string)
    // error (bool), optional
    property alias model: feesPanel.model

    property alias errorText: footer.errorText
    property alias totalFeeText: footer.totalFeeText
    property alias accountName: footer.accountName

    signal signTransactionClicked()
    signal cancelClicked()

    QtObject {
        id: d

        property int minTextWidth: 50
    }

    implicitWidth: 600 // by design

    contentItem: FeesPanel {
        id: feesPanel

        highlightFees: false

        footer: FeesSummaryFooter {
            id: footer
        }
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
