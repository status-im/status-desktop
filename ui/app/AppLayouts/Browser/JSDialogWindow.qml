import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtWebEngine 1.10
import "../../../shared"
import "../../../imports"

ModalPopup {
    id: root
    property QtObject request

    onClosed: {
        request.dialogReject();
        root.destroy();
    }

    Component.onCompleted: {
        switch (request.type) {
            case JavaScriptDialogRequest.DialogTypeAlert:
                cancelButton.visible = false;
                title.text = qsTr("Alert");
                message.text = request.message;
                prompt.text = "";
                prompt.visible = false;
                break;
            case JavaScriptDialogRequest.DialogTypeConfirm:
                title.text = qsTr("Confirm");
                message.text = request.message;
                prompt.text = "";
                prompt.visible = false;
                break;
            case JavaScriptDialogRequest.DialogTypePrompt:
                title.text = qsTr("Prompt");
                message.text = request.message;
                prompt.text = request.defaultText;
                prompt.visible = true;
                break;
        }
    }

    Rectangle {
        id: rectangle
        height: 30
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.left: parent.left

        Text {
            id: title
            x: 54
            y: 5
            color: "#ffffff"
            text: qsTr("Title")
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }


    ScrollView {
        width: parent.width
        height: 100
        TextArea {
            id: message
            wrapMode: TextEdit.Wrap
            readOnly: true
            text: ""
        }
    }

    TextField {
        id: prompt
        width: 300
        height: 22
        Layout.fillWidth: true
        font.pointSize: 12
    }

    Button {
        id: okButton
        width: 90
        height: 30
        text: qsTr("OK")
        onClicked: {
            request.dialogAccept(prompt.text);
            close();
        }
    }

    Button {
        id: cancelButton
        width: 90
        height: 30
        anchors.top: okButton.bottom
        text: qsTr("Cancel")
        onClicked: {
            request.dialogReject();
            close();
        }
    }
}