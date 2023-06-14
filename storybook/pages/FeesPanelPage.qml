import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import AppLayouts.Chat.panels.communities 1.0


SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Pane {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                anchors.fill: feesPanel
                anchors.margins: -15
                border.color: "lightgray"
            }

            FeesPanel {
                id: feesPanel

                anchors.centerIn: parent

                width: 500

                model: ListModel {
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

                errorText: errorTextField.text
                isFeeLoading: loadingSwitch.checked
                showSummary: showSummarySwitch.checked
                showAccounts: showAccountsSwitch.checked

                totalFeeText: "0.01 ETH ($265.43)"
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

            Switch {
                id: loadingSwitch

                text: "Is fee loading"
                checked: false
            }

            Switch {
                id: showSummarySwitch

                text: "Show summary"
                checked: true
            }

            Switch {
                id: showAccountsSwitch

                text: "Show account names"
                checked: true
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
