import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import "../components"
import "../../../../shared"
import "../../../../imports"

Rectangle {
    id: rectangle
    border.width: 0
    height: 52

    visible: chatsModel.activeChannel.chatType !== Constants.chatTypePrivateGroupChat || chatsModel.activeChannel.isMember(profileModel.profile.pubKey)

    Audio {
        id: sendMessageSound
        source: "../../../../sounds/send_message.wav"
    }

    function interpretMessage(msg) {
        if (msg === "/shrug") {
            return "¯\\\\\\_(ツ)\\_/¯"
        }
        if (msg === "/tableflip") {
            return "(╯°□°）╯︵ ┻━┻"
        }

        return msg
    }

    function onEnter(event){
        if (event.modifiers === Qt.NoModifier && (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
            if(txtData.text.trim().length > 0){
                let msg = interpretMessage(txtData.text.trim())
                chatsModel.sendMessage(msg, SelectedMessage.messageId);
                txtData.text = "";
                event.accepted = true;
                sendMessageSound.stop()
                Qt.callLater(sendMessageSound.play);
            }
        }
    }



    ScrollView {
        id: scrollView
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: sendBtns.left
        anchors.rightMargin: 0

        StyledTArea {
            textFormat: TextArea.PlainText

            id: txtData
            text: ""
            selectByMouse: true

            anchors.top: parent.top
            // The normal padding doesn't work for some reason
            topPadding: Style.current.padding + 9
            leftPadding: 12
            rightPadding: Style.current.padding

            font.pixelSize: 15
            //% "Type a message..."
            placeholderText: qsTrId("type-a-message")
            Keys.onPressed: onEnter(event)
            background: Rectangle {
                color: "#00000000"
            }
        }
    }

    ChatButtons {
        id: sendBtns
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        addToChat: function (text) {
            txtData.insert(txtData.length, text)
        }
    }
}
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/
