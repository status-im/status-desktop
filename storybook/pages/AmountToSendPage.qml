import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.1

import shared.popups.send.views 1.0

SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        AmountToSend {
            id: amountToSend

            anchors.centerIn: parent

            width: 400

            interactive: interactiveCheckBox.checked
            fiatInputInteractive: fiatInteractiveCheckBox.checked
            markAsInvalid: markAsInvalidCheckBox.checked

            mainInputLoading: ctrlMainInputLoading.checked
            bottomTextLoading: ctrlBottomTextLoading.checked

            caption: captionField.text

            decimalPoint: decimalPointRadioButton.checked ? "." : ","
            price: parseFloat(priceTextField.text)

            multiplierIndex: multiplierIndexSpinBox.value

            formatFiat: balance => `${balance.toLocaleString(Qt.locale())} USD`
            formatBalance: balance => `${balance.toLocaleString(Qt.locale())} ETH`

            dividerVisible: ctrlDividerVisible.checked
            selectedSymbol: ctrlShowMainInputSymbol.checked ? amountToSend.fiatMode ? "USD": "ETH": ""
        }
    }

    Pane {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 350

        ColumnLayout {
            spacing: 15


            RowLayout {
                Label {
                    text: "Caption"
                }

                TextField {
                    id: captionField

                    text: "Amount to send"
                }
            }

            RowLayout {
                Label {
                    text: "Price"
                }

                TextField {
                    id: priceTextField

                    text: "812.323"
                }
            }

            RowLayout {
                Label {
                    text: "Decimal point"
                }

                RadioButton {
                    id: decimalPointRadioButton

                    text: "."
                }

                RadioButton {
                    text: ","
                    checked: true
                }
            }

            RowLayout {
                Label {
                    text: "Multiplier index"
                }

                SpinBox {
                    id: multiplierIndexSpinBox

                    editable: true
                    value: 18
                    to: 30
                }
            }

            RowLayout {
                CheckBox {
                    id: interactiveCheckBox

                    text: "Interactive"
                    checked: true
                }

                CheckBox {
                    id: fiatInteractiveCheckBox

                    text: "Fiat mode interactive"
                    checked: true
                }

                CheckBox {
                    id: markAsInvalidCheckBox

                    text: "Mark as invalid"
                }

                CheckBox {
                    id: ctrlMainInputLoading
                    text: "Input loading"
                }

                CheckBox {
                    id: ctrlBottomTextLoading
                    text: "Bottom text loading"
                }

                CheckBox {
                    id: ctrlDividerVisible
                    text: "Divider"
                }

                CheckBox {
                    id: ctrlShowMainInputSymbol
                    text: "Show Main Input Symbol"
                }
            }

            Label {
                font.bold: true
                text: `fiat mode: ${amountToSend.fiatMode}, ` +
                      `valid: ${amountToSend.valid}, ` +
                      `empty: ${amountToSend.empty}, ` +
                      `amount: ${amountToSend.amount}`
            }

            RowLayout {
                Label {
                    text: `Set value`
                }

                TextField {
                    id: amountTextField

                    text: "0.0012"
                }

                Button {
                    text: "SET"

                    onClicked: {
                        amountToSend.setValue(amountTextField.text)
                    }
                }
            }
        }
    }

    Settings {
        property alias multiplier: multiplierIndexSpinBox.value
    }
}

// category: Components
