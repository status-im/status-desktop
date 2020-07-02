import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import "../components"
import "../../../../shared"
import "../../../../imports"

Rectangle {
    border.width: 0

    visible: chatsModel.activeChannel.chatType != Constants.chatTypePrivateGroupChat || chatsModel.activeChannel.isMember(profileModel.profile.pubKey)

    Audio {
        id: sendMessageSound
        source: "../../../../sounds/send_message.wav"
    }

    function onEnter(event){
        if (event.modifiers == Qt.NoModifier && (event.key == Qt.Key_Enter || event.key == Qt.Key_Return)) {
            if(txtData.text.trim().length > 0){
                chatsModel.sendMessage(txtData.text.trim());
                txtData.text = "";
                event.accepted = true;
                sendMessageSound.stop()
                Qt.callLater(sendMessageSound.play);
            }
        }
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
                topPadding: Style.current.padding
                leftPadding: 12
                rightPadding: Style.current.padding
                font.pixelSize: 14
                placeholderText: qsTr("Type a message...")
                Keys.onPressed: onEnter(event)
                background: Rectangle {
                    color: "#00000000"
                }
            }
        }

        ChatButtons {
            id: sendBtns
            Layout.topMargin: 1
            Layout.fillHeight: true
            Layout.preferredWidth: 30 + Style.current.padding
            Layout.minimumWidth: 30 + Style.current.padding
            Layout.maximumWidth: 200
        }
    }

}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:100;width:600}
}
##^##*/
