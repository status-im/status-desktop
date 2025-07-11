import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt.labs.settings

import Storybook
import Models

import AppLayouts.Communities.panels
import utils


SplitView {
    FeesModel {
        id: feesModel
    }

    WalletAccountsModel {
        id: accountsModel
    }

    LimitProxyModel {
        id: filteredModel

        sourceModel: feesModel
        limit: countSlider.value
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        FeesBox {
            id: feesPanel

            anchors.centerIn: parent

            width: 600

            model: filteredModel

            accountsSelector.model: accountsModel
            showAccountsSelector: accountsSwitch.checked

            placeholderText: placeholderTextField.text

            totalFeeText: totalCheckBox.checked ?
                              totalFeeTextField.text : ""
            generalErrorText: generalErrorCheckBox.checked ?
                                  generalErrorTextField.text : ""
            accountErrorText: accountErrorCheckBox.checked ?
                                  accountErrorTextField.text : ""
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        Settings {
            property alias countSliderValue: countSlider.value
            property alias generalErrorCheckBoxChecked: generalErrorCheckBox.checked
            property alias accountErrorCheckBoxChecked: accountErrorCheckBox.checked
            property alias totalCheckBoxChecked: totalCheckBox.checked
        }

        ColumnLayout {
            anchors.fill: parent

            Label {
                Layout.fillWidth: true

                wrapMode: Text.Wrap
                text: "Placeholder text (visible when model count is 0)"
            }

            TextField {
                id: placeholderTextField

                Layout.fillWidth: true

                text: "Add valid “What” and “To” values to see fees"
            }

            MenuSeparator {
                Layout.fillWidth: true
            }

            GroupBox {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent

                    Label {
                        Layout.fillWidth: true

                        text: "Number of items in the model"
                    }

                    RowLayout {
                        Slider {
                            id: countSlider

                            from: 0
                            to: feesModel.count
                            value: to
                            stepSize: 1
                            snapMode: Slider.SnapAlways
                        }

                        Label {
                            text: countSlider.value
                        }
                    }
                }
            }


            GroupBox {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent

                    CheckBox {
                        id: generalErrorCheckBox

                        text: "General error"
                    }

                    Label {
                        Layout.fillWidth: true

                        text: "Error text"
                    }
                    TextField {
                        id: generalErrorTextField

                        Layout.fillWidth: true

                        text: "Transaction fees exceed block gas limit.\n" +
                              "Try splitting the recipients into two separate airdrops instead."
                    }
                }
            }

            Switch {
                id: accountsSwitch

                text: "Accounts selector"
                checked: true
            }

            GroupBox {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent

                    CheckBox {
                        id: accountErrorCheckBox

                        text: "Account error"
                    }

                    Label {
                        Layout.fillWidth: true

                        text: "Error text"
                    }

                    TextField {
                        id: accountErrorTextField

                        Layout.fillWidth: true

                        text: "Insufficient funds on Optimism or Status to pay gas fees."
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent

                    CheckBox {
                        id: totalCheckBox

                        checked: true
                        text: "Total fee"
                    }


                    TextField {
                        id: totalFeeTextField

                        Layout.fillWidth: true

                        text: "0.01 ETH ($265.43)"
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}

// category: Panels
