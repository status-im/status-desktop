import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"
import "../shared"

ModalPopup {
    property var onConfirmSeedClick: function () {}
    id: popup
    title: qsTr("Add key")
    height: 400

    onOpened: {
        mnemonicTextField.text = "";
        mnemonicTextField.forceActiveFocus(Qt.MouseFocusReason)
    }

    TextArea {
        id: mnemonicTextField
        height: 44
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 15
        placeholderText: "Enter your seed phrase here..."
        anchors.left: parent.left
        anchors.leftMargin: 76
        anchors.right: parent.right
        anchors.rightMargin: 76
        anchors.verticalCenter: parent.verticalCenter

        Keys.onReturnPressed: {
            submitBtn.clicked()
        }
    }

    StyledText {
        text: qsTr("Enter 12, 15, 18, 21 or 24 words.\nSeperate words by a single space.")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        color: Theme.darkGrey
        font.pixelSize: 12
    }

    footer: Button {
        id: submitBtn
        anchors.bottom: parent.bottom
        anchors.topMargin: Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        width: 44
        height: 44
        background: Rectangle {
            radius: 50
            color: Theme.lightBlue
        }

        SVGImage {
            sourceSize.height: 15
            sourceSize.width: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "../app/img/leave_chat.svg"
            rotation: 180
            fillMode: Image.PreserveAspectFit
        }

        onClicked : {
            if (mnemonicTextField.text === "") {
                return
            }
            onConfirmSeedClick(mnemonicTextField.text)
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
