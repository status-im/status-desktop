import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtMultimedia 5.13
import QtQuick.Dialogs 1.0
import "../components"
import "../../../../shared"
import "../../../../imports"

Rectangle {
    id: rectangle
    property alias textInput: txtData
    border.width: 0
    height: 52
    color: Style.current.transparent

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
            if(chatColumn.isImage){
                chatsModel.sendImage(sendImageArea.image);
            }

            if(txtData.text.trim().length > 0){
                let msg = interpretMessage(txtData.text.trim()).trim()
                chatsModel.sendMessage(msg, chatColumn.isReply ? SelectedMessage.messageId : "", Utils.isOnlyEmoji(txtData.text) ? Constants.emojiType : Constants.messageType);
                txtData.text = "";
                event.accepted = true
                sendMessageSound.stop()
                Qt.callLater(sendMessageSound.play);
            }
            chatColumn.hideExtendedArea();
        }
    }

    FileDialog {
        id: imageDialog
        title: qsTr("Please choose an image")
        folder: shortcuts.pictures
        nameFilters: [
            qsTr("Image files (*.jpg *.jpeg *.png)")
        ]
        onAccepted: {
            chatColumn.showImageArea(imageDialog.fileUrls);
            txtData.forceActiveFocus();
        }
        onRejected: {
            chatColumn.hideExtendedArea();
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
                color: Style.current.transparent
            }
        }
    }

    ChatButtons {
        id: sendBtns
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        addToChat: function (text) {
            txtData.insert(txtData.length, text)
        }
    }
}
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
