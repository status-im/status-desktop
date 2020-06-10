import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../imports"
import "../../../shared"

ModalPopup {
    property var currentAccount: walletModel.currentAccount
    id: popup
    // TODO add icon when we have that feature
    title: qsTr("Status account settings")
    height: 630

    property int marginBetweenInputs: 35
    property string selectedColor: currentAccount.iconColor

    onOpened: {
        accountNameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: accountNameInput
        placeholderText: qsTr("Enter an account name...")
        label: qsTr("Account name")
        text: currentAccount.name
    }

    Select {
        id: accountColorInput
        anchors.top: accountNameInput.bottom
        anchors.topMargin: marginBetweenInputs
        bgColor: selectedColor
        label: qsTr("Account color")
        selectOptions: Constants.accountColors.map(color => {
            return {
                text: "",
                bgColor: color,
                height: 52,
                onClicked: function () {
                    selectedColor = color
                }
           }
        })
    }

    TextWithLabel {
        id: typeText
        label: qsTr("Type")
        text: {
            var result = ""
            switch (currentAccount.walletType) {
                case Constants.watchWalletType: result = qsTr("Watch-only"); break;
                case Constants.keyWalletType:
                case Constants.seedWalletType: result = qsTr("Off Status tree"); break;
                default: result = qsTr("On Status tree")
            }
            return result
        }
        anchors.top: accountColorInput.bottom
        anchors.topMargin: marginBetweenInputs
    }

    TextWithLabel {
        id: addressText
        label: qsTr("Wallet address")
        text: currentAccount.address
        anchors.top: typeText.bottom
        anchors.topMargin: marginBetweenInputs
    }

    TextWithLabel {
        id: pathText
        label: qsTr("Derivation path")
        text: currentAccount.path
        anchors.top: addressText.bottom
        anchors.topMargin: marginBetweenInputs
    }

    TextWithLabel {
        id: storageText
        visible: currentAccount.walletType !== Constants.watchWalletType
        label: qsTr("Storage")
        text: qsTr("This device")
        anchors.top: pathText.bottom
        anchors.topMargin: marginBetweenInputs
    }

    footer: Item {
        anchors.fill: parent
        StyledButton {
            anchors.top: parent.top
            anchors.topMargin: Theme.padding
            anchors.right: saveBtn.left
            anchors.rightMargin: Theme.padding
            label: qsTr("Delete account")
            btnColor: Theme.white
            textColor: Theme.red

            onClicked : {
                // TODO add a confirmation message
                console.log('DELETE')
                popup.close();
            }
        }
        StyledButton {
            id: saveBtn
            anchors.top: parent.top
            anchors.topMargin: Theme.padding
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            label: qsTr("Save changes")

            disabled: accountNameInput.text === ""

            onClicked : {
                // TODO add message to show validation errors
                if (accountNameInput.text === "") return;
                console.log('SAVE')
    //            walletModel.generateNewAccount(passwordInput.text, accountNameInput.text, selectedColor);
                // TODO manage errors adding account
                popup.close();
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
