import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3
import "../../../imports"
import "../../../shared"

ModalPopup {
    id: popup
    title: qsTr("add custom token")
    height: 630

    property int marginBetweenInputs: 35

    onOpened: {
        accountNameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: addressInput
        placeholderText: qsTr("Enter contract address...")
        label: qsTr("Contract address")
    }

    Input {
        id: nameInput
        anchors.top: addressInput.bottom
        anchors.topMargin: marginBetweenInputs
        placeholderText: qsTr("The name of your token...")
        label: qsTr("Name")
    }

    Input {
        id: symbolInput
        anchors.top: nameInput.bottom
        anchors.topMargin: marginBetweenInputs
        placeholderText: qsTr("ABC")
        label: qsTr("Symbol")
    }

    Input {
        id: decimalsInput
        anchors.top: symbolInput.bottom
        anchors.topMargin: marginBetweenInputs
        label: qsTr("Decimals")
        text: "18"
    }

    footer: Item {
        anchors.fill: parent
        StyledButton {
            id: addBtn
            anchors.top: parent.top
            anchors.topMargin: Theme.padding
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            label: qsTr("Add")

            disabled: addressInput.text === "" || nameInput.text === "" || symbolInput.text === "" || decimalsInput.text === ""

            onClicked : {
                const error = walletModel.addCustomToken(addressInput.text, nameInput.text, symbolInput.text, decimalsInput.text);

                if (error) {
                    changeError.text = error
                    changeError.open()
                    return
                }
                popup.close();
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
