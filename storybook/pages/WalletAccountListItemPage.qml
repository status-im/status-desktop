import QtQuick 2.15
import QtQuick.Controls 2.15

import shared.controls 1.0

import utils 1.0

SplitView {
    id: root

    Item {
        SplitView.preferredWidth: walletAccountListItem.implicitWidth
        SplitView.preferredHeight: walletAccountListItem.implicitHeight
        WalletAccountListItem {
            id: walletAccountListItem
            clearVisible: showClearButton.checked
            name: nameField.text
            address: addressField.text
            chainShortNames: chainShortNamesField.text
            emoji: emojiField.text
            walletColor: walletColorField.text
            currencyBalance: QtObject {
                readonly property double amount: parseInt(currencyBalanceField.text)
                readonly property string symbol: "USD"
                readonly property int displayDecimals: 4
                readonly property bool stripTrailingZeroes: false
            }
            walletType: walletTypeCombo.currentText
            migratedToKeycard: migratedToKeycardCheckBox.checked
            accountBalance: hasAccountBalanceCheckBox.checked ? ({
                formattedBalance: formattedAccountBalance.text,
                balance: formattedAccountBalance.text,
                iconUrl: "network/Network=Hermez",
                chainColor: "#FF0000"
            }) : null

            onCleared: {
                console.log("Cleared clicked")
            }

            onClicked: (itemId, mouse) => {
                console.log("Clicked: ", itemId, mouse)
            }
            onTitleClicked: (titleId) => {
                console.log("Title clicked: ", titleId)
            }
            onIconClicked: (mouse) => {
                console.log("Icon clicked: ", mouse)
            }
        }
    }
    

    Pane {
        id: pane
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Column {

            TextField {
                id: nameField
                text: "Piggy Bank"
                placeholderText: "Name"
            }

            TextField {
                id: addressField
                text: "0x1234567890abcdef"
                placeholderText: "Address"
            }

            TextField {
                id: chainShortNamesField
                text: "<font color=\"red\">eth:</font><font color=\"blue\">oeth:</font><font color=\"green\">arb:</font>"
                placeholderText: "Chain Short Names"
            }

            TextField {
                id: emojiField
                text: "🐷"
                placeholderText: "Emoji"
            }

            TextField {
                id: walletColorField
                text: "#FF0000"
                placeholderText: "Wallet Color"
            }
            Label {
                text: "Currency balance amount"
            }
            TextField {
                id: currencyBalanceField
                text: "1232343234234"
                placeholderText: "Currency Balance"
            }

            Label {
                text: "Wallet Type: " + Constants.watchWalletType
            }

            ComboBox {
                id: walletTypeCombo
                model: [Constants.watchWalletType, Constants.keyWalletType, Constants.seedWalletType, Constants.generatedWalletType]
                currentIndex: 0
            }

            CheckBox {
                id: migratedToKeycardCheckBox
                text: "Migrated to Keycard"
            }

            CheckBox {
                id: showClearButton
                text: "Show Clear Button"
            }

            CheckBox {
                id: hasAccountBalanceCheckBox
                text: "Has Account Balance"
                checked: true
            }

            TextField {
                id: formattedAccountBalance
                text: "123.45"
                visible: hasAccountBalanceCheckBox.checked
            }
        }
    }
}