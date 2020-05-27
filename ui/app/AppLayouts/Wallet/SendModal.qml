import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"

Item {
    TextField {
        id: txtValue
        x: 19
        y: 41
        placeholderText: qsTr("Enter ETH")
        anchors.leftMargin: 24
        anchors.topMargin: 32
        width: 239
        height: 40
    }

    TextField {
        id: txtFrom
        x: 340
        y: 41
        width: 239
        height: 40
        text: assetsModel.getDefaultAccount()
        placeholderText: qsTr("Send from (account)")
        anchors.topMargin: 32
        anchors.leftMargin: 24
    }

    TextField {
        id: txtTo
        x: 340
        y: 99
        width: 239
        height: 40
        text: assetsModel.getDefaultAccount()
        placeholderText: qsTr("Send to")
        anchors.topMargin: 32
        anchors.leftMargin: 24
    }

    TextField {
        id: txtPassword
        x: 19
        y: 99
        width: 239
        height: 40
        text: "qwerty"
        placeholderText: "Enter Password"
        anchors.topMargin: 32
        anchors.leftMargin: 24
    }

    Button {
        x: 19
        y: 159
        text: "Send"
        onClicked: {
            let result = assetsModel.onSendTransaction(
                    txtFrom.text,
                    txtTo.text,
                    txtValue.text,
                    txtPassword.text
                    );
            console.log(result);
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
