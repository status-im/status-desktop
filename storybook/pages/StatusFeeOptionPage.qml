import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Controls
import StatusQ.Core.Theme

import Storybook

import AppLayouts.Wallet
import utils

SplitView {
    orientation: Qt.Horizontal

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        background: Rectangle {
            color: Theme.palette.baseColor4
        }

        StatusFeeOption {
            id: feeOption
            anchors.centerIn: parent
            type: feeModeCombobox.currentValue
            mainText: WalletUtils.getFeeTextForFeeMode(type)
            icon: WalletUtils.getIconForFeeMode(type)

            onClicked: {
                console.warn("control clicked...")
                selected = !selected
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.fillHeight: true
        SplitView.preferredWidth: 300

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            ComboBox {
                id: feeModeCombobox
                model: [
                    {testCase: Constants.FeePriorityModeType.Normal, name: "Normal"},
                    {testCase: Constants.FeePriorityModeType.Fast, name: "Fast"},
                    {testCase: Constants.FeePriorityModeType.Urgent, name: "Urgent"},
                    {testCase: Constants.FeePriorityModeType.Custom, name: "Custom"}
                ]

                textRole: "name"
                valueRole: "testCase"
            }

            RowLayout {
                TextField {
                    id: price
                    Layout.preferredWidth: 130
                    text: "1.45 EUR"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                    Component.onCompleted: feeOption.subText = price.text
                }

                StatusButton {
                    text: "Set price"
                    onClicked: {
                        feeOption.subText = price.text
                    }
                }
            }

            RowLayout {
                TextField {
                    id: time
                    Layout.preferredWidth: 130
                    text: "~60s"

                    Component.onCompleted: feeOption.additionalText = time.text
                }

                StatusButton {
                    text: "Set time"
                    onClicked: {
                        feeOption.additionalText = time.text
                    }
                }
            }

            RowLayout {
                TextField {
                    id: unselectedText
                    Layout.preferredWidth: 130
                    text: "Set your own fees & nonce"

                }

                StatusButton {
                    text: "Set unselected text"
                    onClicked: {
                        feeOption.unselectedText = unselectedText.text
                    }
                }
            }

            CheckBox {
                text: "Show subtext"
                checked: true

                onCheckStateChanged: {
                    feeOption.showSubText = checked
                }

                Component.onCompleted: feeOption.showSubText = checked
            }

            CheckBox {
                text: "Show additional text"
                checked: true

                onCheckStateChanged: {
                    feeOption.showAdditionalText = checked
                }

                Component.onCompleted: feeOption.showAdditionalText = checked
            }

            CheckBox {
                text: "Show unselected text"
                checked: false

                onCheckStateChanged: {
                    if (checked) {
                        feeOption.unselectedText = unselectedText.text
                        return
                    }
                    feeOption.unselectedText = ""
                }

                Component.onCompleted: feeOption.unselectedText = ""
            }

            CheckBox {
                id: loading
                text: "Set loading state"
                checked: false

                onCheckStateChanged: {
                    if (checked) {
                        feeOption.subText = ""
                        feeOption.additionalText = ""
                        return
                    }

                    feeOption.subText = price.text
                    feeOption.additionalText = time.text
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}

// category: Controls
