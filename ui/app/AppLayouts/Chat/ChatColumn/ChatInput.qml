import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../components"
import "../../../../shared"
import "../../../../imports"

Rectangle {
    border.width: 0

    visible: chatsModel.activeChannel.chatType != Constants.chatTypePrivateGroupChat || chatsModel.activeChannel.isMember(profileModel.profile.pubKey)

    function onEnter(event){
        if(!(event.modifiers & Qt.ControlModifier) && !(event.modifiers & Qt.ShiftModifier)){
            if(txtData.text.trim().length > 0){
                chatsModel.sendMessage(txtData.text.trim());
                txtData.text = "";
            }
        } else {
            txtData.text = txtData.text + "\n";
            txtData.cursorPosition = txtData.text.length
        }
        event.accepted = true;
    }

    RowLayout {
        spacing: 0
        anchors.fill: parent


        ScrollView {
            anchors.fill: parent
            Layout.fillWidth: true
            Layout.fillHeight: true

            StyledTArea {
                Layout.fillWidth: true
                Layout.fillHeight: true
                textFormat: TextArea.PlainText
                Layout.preferredWidth: parent.width - sendBtns.width

                id: txtData
                text: ""
                selectByMouse: true
                topPadding: Theme.padding
                leftPadding: 12
                rightPadding: Theme.padding
                font.pixelSize: 14
                placeholderText: qsTr("Type a message...")
                Keys.onEnterPressed: onEnter(event)
                Keys.onReturnPressed: onEnter(event)
                background: Rectangle {
                    color: "#00000000"
                }
            }
        }

        ChatButtons {
            id: sendBtns
            Layout.topMargin: 1
            Layout.fillHeight: true
            Layout.preferredWidth: 30 + Theme.padding
            Layout.minimumWidth: 30 + Theme.padding
            Layout.maximumWidth: 200
        }
    }

}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:100;width:600}
}
##^##*/
