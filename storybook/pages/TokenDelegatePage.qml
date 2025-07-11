import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook

import shared.controls
import utils

SplitView {
    id: root

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        TokenDelegate {
            anchors.centerIn: parent

            name: nameTextFiled.text
            balance: balanceTextFiled.text
            icon: Constants.tokenIcon(iconTextFiled.text, false)

            marketDetailsAvailable: marketDataAvailableCheckBox.checked
            marketDetailsLoading: marketDataLoadingCheckBox.checked
            marketCurrencyPrice: marketCurrencyPriceTextFiled.text
            marketBalance: marketBalanceTextFiled.text
            marketChangePct24hour: market24ChangeSpinBox.value

            communityId: communityCheckBox.checked ? "42" : ""
            communityName: communityNameTextField.text
            communityIcon: Constants.tokenIcon("DAI", false)

            errorTooltipText_1: errorTooltipTextField.text
            errorTooltipText_2: marketDataErrorTooltipTextField.text

            onCommunityClicked: {
                console.log("community clicked:", communityId)
            }
        }
    }

    Pane {
        ColumnLayout {
            RowLayout {
                Label {
                    text: "name:"
                }
                TextField {
                    id: nameTextFiled
                    text: "Ether"
                }
            }
            RowLayout {
                Label {
                    text: "icon:"
                }
                TextField {
                    id: iconTextFiled
                    text: "ETH"
                }
            }
            RowLayout {
                Label {
                    text: "balance:"
                }
                TextField {
                    id: balanceTextFiled
                    text: "0,1232 ETH"
                }
            }
            RowLayout {
                CheckBox {
                    id: marketDataAvailableCheckBox
                    text: "market data available"
                    checked: true
                }
                CheckBox {
                    id: marketDataLoadingCheckBox
                    text: "market data loading"
                    checked: false
                }
            }
            RowLayout {
                Label {
                    text: "market balance:"
                }
                TextField {
                    id: marketBalanceTextFiled
                    text: "711,23 USD"
                }
            }
            RowLayout {
                Label {
                    text: "market currency price:"
                }
                TextField {
                    id: marketCurrencyPriceTextFiled
                    text: "3 823,23 USD"
                }
            }
            RowLayout {
                Label {
                    text: "Market data error tooltip:"
                }
                TextField {
                    id: marketDataErrorTooltipTextField
                    text: ""
                }
            }
            RowLayout {
                Label {
                    text: "market 24 change:"
                }
                Slider {
                    id: market24ChangeSpinBox

                    value: 0.1

                    from: -100
                    to: 200
                }

                RoundButton {
                    text: "0"

                    onClicked: market24ChangeSpinBox.value = 0
                }
            }
            CheckBox {
                id: communityCheckBox
                text: "community minted"
                checked: false
            }
            RowLayout {
                Label {
                    text: "community id:"
                }
                TextField {
                    id: communityNameTextField
                    text: "Crypto Kitties"
                }
            }
            RowLayout {
                Label {
                    text: "Error tooltip:"
                }
                TextField {
                    id: errorTooltipTextField
                    text: ""
                }
            }
            Label {
                visible: communityCheckBox.checked
                         && marketDataAvailableCheckBox.checked
                text: "Community pill and market details are not expected \n"
                        + "to occur both for a single token."
                color: "red"
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}

// category: Controls
