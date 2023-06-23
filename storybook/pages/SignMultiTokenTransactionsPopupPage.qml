import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import AppLayouts.Communities.popups 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Pane {
            id: pane

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            SignMultiTokenTransactionsPopup {
                id: dialog

                model: ListModel {
                    id: feesModel

                    ListElement {
                        account: "My Account 1"
                        network: "Optimism"
                        symbol: "TAT"
                        amount: 2
                        feeText: "0.0015 ($75.43)"
                    }
                    ListElement {
                        account: "My Account 2"
                        network: "Arbitrum"
                        symbol: "SNT"
                        amount: 34
                        feeText: "0.0085 ETH ($175.43)"
                    }
                }

                closePolicy: Popup.NoAutoClose
                visible: true
                modal: false
                destroyOnClose: false

                title: `Sign transaction - Airdrop ${model.count} token(s) to 32 recipients`

                isFeeLoading: loadingSwitch.checked
                showSummary: showSummarySwitch.checked

                errorText: errorTextField.text
                totalFeeText: "0.01 ETH ($265.43)"

                onSignTransactionClicked: logs.logEvent("SignTokenTransactionsPopup::onSignTransactionClicked")
                onCancelClicked: logs.logEvent("SignTokenTransactionsPopup::onCancelClicked")
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent

            Label {
                Layout.fillWidth: true

                text: "Error text"
            }

            TextField {
                id: errorTextField

                Layout.fillWidth: true

                text: ""
            }

            SpinBox {
                id: recipientsCountSpinBox

                from: 1
                to: 1000
            }

            Switch {
                id: loadingSwitch

                text: "Is fee loading"
                checked: false
            }

            Switch {
                id: showSummarySwitch

                text: "Is summary visible"
                checked: true
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}


