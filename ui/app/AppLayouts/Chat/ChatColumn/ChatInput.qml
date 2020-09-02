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

    property bool emojiEvent: false;

    Audio {
        id: sendMessageSound
        source: "../../../../sounds/send_message.wav"
        volume: 0.2
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

    function sendMsg(event){
        if(chatColumn.isImage){
            chatsModel.sendImage(sendImageArea.image);
        }
        var msg = chatsModel.plainText(Emoji.deparse(txtData.text).trim()).trim()
        if(msg.length > 0){
            msg = interpretMessage(msg)
            chatsModel.sendMessage(msg, chatColumn.isReply ? SelectedMessage.messageId : "", Utils.isOnlyEmoji(msg) ? Constants.emojiType : Constants.messageType);
            txtData.text = "";
            if(event) event.accepted = true
            sendMessageSound.stop()
            Qt.callLater(sendMessageSound.play);
        }
        chatColumn.hideExtendedArea();
    }

    function onEnter(event){
        if (event.modifiers === Qt.NoModifier && (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
            sendMsg(event);
        }

        emojiEvent = emojiHandler(emojiEvent, event);
    }


    function emojiHandler(emojiEvent, event) {

        var msg = chatsModel.plainText(Emoji.deparse(txtData.text).trim());

        if (emojiEvent == false && event.key == Qt.Key_Colon) {
            if (isSpace(msg.charAt(msg.length - 1)) == true) {
                console.log('emoji event');
                return true;
            }
            return false;
        } else if (emojiEvent == true && isKeyValid(event.key) == true) {
            console.log('popup');
            return true;
        } else if (emojiEvent == true && event.key == Qt.Key_Colon) {
            var index = msg.indexOf(':', 0);
            txtData.remove(index - 1, txtData.length);
            txtData.insert(txtData.length, " EMOJI");

            if (event) event.accepted = true;

            return false;
        } else if (emojiEvent == true && isKeyValid(event.key) == false) {
            console.log('emoji event stopped');
            return false;
        }

        return false;
    }

    function isKeyValid(key) {
        if (isKeyAlpha(key) == true || isKeyDigit(key) == true || key == Qt.Key_Underscore || key == Qt.Key_Shift)
            return true;
        return false;
    }

    function isSpace(c) {
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r')
            return true
        return false
    }

    function isKeyAlpha(key) {
        if (key >= Qt.Key_A && key <= Qt.Key_Z)
            return true;
        return false;
    }

    function isKeyDigit(key) {
        if (key >= Qt.Key_0 && key <= Qt.Key_9)
            return true;
        return false;
    }

    FileDialog {
        id: imageDialog
        //% "Please choose an image"
        title: qsTrId("please-choose-an-image")
        folder: shortcuts.pictures
        nameFilters: [
            //% "Image files (*.jpg *.jpeg *.png)"
            qsTrId("image-files----jpg---jpeg---png-")
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
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        topPadding: Style.current.padding
        
        StyledTArea {
            textFormat: Text.RichText
            id: txtData
            text: ""
            selectByMouse: true
            wrapMode: TextArea.Wrap
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
        onSend: function(){
            sendMsg(false)
        }
    }
}
/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
