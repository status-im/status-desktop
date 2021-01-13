import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtWebEngine 1.10
import "../../../shared"
import "../../../imports"

ModalPopup {
    id: root
    property QtObject request
    height: 286

    closePolicy: Popup.NoAutoClose

    onClosed: {
        request.dialogReject();
        root.destroy();
    }

    Component.onCompleted: {
        root.title = request.securityOrigin;
        message.text = request.message;
        if(request.type === JavaScriptDialogRequest.DialogTypeAlert){
            cancelButton.visible = false;
        }
        if(request.type === JavaScriptDialogRequest.DialogTypePrompt){
            prompt.text = request.defaultText;
            prompt.visible = true;
            svMessage.height = 75;
        }
    }

    ScrollView {
        id: svMessage
        width: parent.width
        height: 100
        TextArea {
            id: message
            wrapMode: TextEdit.Wrap
            readOnly: true
            text: ""
        }
    }

    Input {
        id: prompt
        text: ""
        visible: false
        Layout.fillWidth: true
        anchors.top: svMessage.bottom
    }

    footer: Item {
        width: parent.width
        height: okButton.height

        StyledButton {
            id: okButton
            anchors.right: parent.right
            label: qsTr("Ok")
            anchors.bottom: parent.bottom
            onClicked: {
                request.dialogAccept(prompt.text);
                close();
            }
        }

        StyledButton {
            id: cancelButton
            anchors.right: okButton.left
            anchors.rightMargin: Style.current.smallPadding
            label: qsTr("Cancel")
            btnColor: Style.current.transparent
            anchors.bottom: parent.bottom
            onClicked: {
                request.dialogReject();
                close();
            }
        }
    }
}