import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup
    title: qsTr("Generate an account")

    property int marginBetweenInputs: 38
    property string selectedColor: Constants.accountColors[0]

    onOpened: {
        passwordInput.text = "";
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: passwordInput
        placeholderText: qsTr("Enter your password…")
        label: qsTr("Password")
        textField.echoMode: TextInput.Password
    }

    Input {
        id: accountNameInput
        anchors.top: passwordInput.bottom
        anchors.topMargin: marginBetweenInputs
        placeholderText: qsTr("Enter an account name...")
        label: qsTr("Account name")
    }

    Input {
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

    footer: StyledButton {
        label: "Add account >"

        disabled: passwordInput.text === "" && accountNameInput === ""

        onClicked : {
            if(chatKey.text === "") return;
            chatsModel.joinChat(chatKey.text, Constants.chatTypeOneToOne);
            popup.close();
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
