import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.controls 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    id: root

    SplitView {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        orientation: Qt.Vertical

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            RecipientViewDelegate {
                id: delegate

                anchors.centerIn: parent

                useAddressAsLetterIdenticon: addressAsLetterIndenticonCheckbox.checked
                name: nameField.text
                address: addressField.text
                emoji: emojiField.currentText
                ens: ensField.text
                walletColorId: colorIdField.currentText
                walletColor: colorField.currentText

                onClicked: logs.logEvent("delegate clicked")
            }
        }

        Logs {
            id: logs
        }

        LogsView {
            clip: true

            SplitView.preferredHeight: 150
            SplitView.fillWidth: true

            logText: logs.logText
        }
    }

    Pane {
        SplitView.preferredWidth: 300

        ColumnLayout {
            Label {
                text: "Name:"
            }
            TextField {
                id: nameField
                text: "Test account"
            }
            Label {
                text: "Address:"
            }
            TextField {
                id: addressField
                text: "0x929d0D5Cbc5228543Fa9b7df766CFf42C8c8975c"
            }
            Label {
                text: "Emoji:"
            }
            ComboBox {
                id: emojiField
                model: ["", "😋", "🚗"]
            }
            Label {
                text: "Ens:"
            }
            TextField {
                id: ensField
                text: ""
            }
            Label {
                text: "color"
            }
            ComboBox {
                id: colorField
                model: ["", "red", "blue", "lightgrey"]
            }
            Label {
                text: "colorId"
            }
            ComboBox {
                id: colorIdField
                model: ["", Constants.walletAccountColors.primary, Constants.walletAccountColors.army, Constants.walletAccountColors.camel,]
            }

            CheckBox {
                id: addressAsLetterIndenticonCheckbox
                text: "Use address as letter identicon"
                checked: false
            }
        }
    }
}
