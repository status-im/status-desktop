import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"

ModalPopup {
    id: popup

    property bool editable: true
    property int marginBetweenInputs: 35

    title: editable ? 
        //% "Add custom token"
        qsTrId("add-custom-token")
        : nameInput.text

    height: editable ? 450 : 380

    onOpened: {
        addressInput.text = "";
        nameInput.text = "";
        symbolInput.text = "";
        decimalsInput.text = "";
        addressInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    function setData(address, name, symbol, decimals){
        addressInput.text = address;
        nameInput.text = name;
        symbolInput.text = symbol;
        decimalsInput.text = decimals;
        editable = false;
    }

    Input {
        id: addressInput
        readOnly: !editable
        //% "Enter contract address..."
        placeholderText: qsTrId("enter-contract-address...")
        //% "Contract address"
        label: qsTrId("contract-address")
    }

    Input {
        id: nameInput
        readOnly: !editable
        anchors.top: addressInput.bottom
        anchors.topMargin: marginBetweenInputs
        //% "The name of your token..."
        placeholderText: qsTrId("the-name-of-your-token...")
        //% "Name"
        label: qsTrId("name")
    }


    Item {
        width: 200
        anchors.top: nameInput.bottom
        anchors.topMargin: marginBetweenInputs
        anchors.left: parent.left
        Input {
            id: symbolInput
            readOnly: !editable
            //% "ABC"
            placeholderText: qsTrId("abc")
            //% "Symbol"
            label: qsTrId("symbol")
            
        }
    }

    Item {
        width: 200
        anchors.top: nameInput.bottom
        anchors.topMargin: marginBetweenInputs
        anchors.right: parent.right
        Input {
            id: decimalsInput
            readOnly: !editable
            //% "Decimals"
            label: qsTrId("decimals")
            text: "18"
        }
    }

    footer: Item {
        visible: editable
        anchors.fill: parent
        StyledButton {
            id: addBtn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            //% "Add"
            label: qsTrId("add")

            disabled: addressInput.text === "" || nameInput.text === "" || symbolInput.text === "" || decimalsInput.text === ""

            onClicked : {
                const error = walletModel.addCustomToken(addressInput.text, nameInput.text, symbolInput.text, decimalsInput.text);

                if (error) {
                    errorSound.play()
                    changeError.text = error
                    changeError.open()
                    return
                }

                walletModel.loadCustomTokens()                
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
