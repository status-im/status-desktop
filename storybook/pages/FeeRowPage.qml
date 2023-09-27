import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.controls 1.0

SplitView {
    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: feesPanel
            anchors.margins: -15
            border.color: "lightgray"
            color: "transparent"
        }

        FeeRow {
            id: feesPanel

            anchors.centerIn: parent

            width: 500

            title: titleButtonsGroup.checkedButton.title
            feeText: feeButtonsGroup.checkedButton.fee

            highlightFee: highlightFeeSwitch.checked
            errorFee: errorFeeSwitch.checked
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent

            Label {
                Layout.fillWidth: true

                text: "Title"
            }

            ButtonGroup {
                id: titleButtonsGroup

                buttons: titleButtonsRow.children
            }

            RowLayout {
                id: titleButtonsRow

                RadioButton {
                    readonly property string title: "Airdrop MCT on Status"

                    text: "Short"
                    checked: true
                }

                RadioButton {
                    readonly property string title:
                        "Mint Doodles Owner and TokenMaster tokens on Optimism"

                    text: "Long"
                }

                RadioButton {
                    readonly property string title: ModelsData.descriptions.mediumLoremIpsum

                    text: "Very Long"
                }
            }

            Label {
                Layout.fillWidth: true

                text: "Fee"
            }

            ButtonGroup {
                id: feeButtonsGroup

                buttons: feeButtonsRow.children
            }

            RowLayout {
                id: feeButtonsRow

                RadioButton {
                    readonly property string fee: ""

                    text: "Empty"
                    checked: true
                }

                RadioButton {
                    readonly property string fee: "13.34 USD (0.0072 ETH)"

                    text: "Short"
                    checked: true
                }

                RadioButton {
                    readonly property string fee: "112 323.34 USD (2223.000272 ETH)"

                    text: "Long"
                }
            }

            MenuSeparator {
                Layout.fillWidth: true
            }

            Switch {
                id: highlightFeeSwitch

                text: "Highlight fee"
                enabled: true
            }

            Switch {
                id: errorFeeSwitch

                text: "Fee error"
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

// category: Panels
