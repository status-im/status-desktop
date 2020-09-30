import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"

Rectangle {
    property string userName: "Joseph Joestar"
    property string message: "Your next line is: this is a Jojo reference"
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="

    id: replyArea
    height: 70
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    color: "#00000000"

    function setup(){
        let replyMessageIndex = chatsModel.messageList.getMessageIndex(SelectedMessage.messageId);
        if (replyMessageIndex == -1) return;
        
        userName = chatsModel.messageList.getMessageData(replyMessageIndex, "userName")
        message = chatsModel.messageList.getMessageData(replyMessageIndex, "message")
        identicon = chatsModel.messageList.getMessageData(replyMessageIndex, "identicon")
    }

    function reset(){
        userName = "";
        message= "";
        identicon = "";
    }

    StatusIconButton {
        id: closeButton
        type: "secondary"
        icon.name: "close"
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        anchors.right: parent.right
        onClicked: {
            chatColumn.hideExtendedArea()
        }
    }

    Image {
        id: chatImage
        width: 36
        height: 36
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top: parent.top
        fillMode: Image.PreserveAspectFit
        source: identicon
        mipmap: true
        smooth: false
        antialiasing: true
    }

    StyledTextEdit {
        id: replyToUsername
        text: userName
        font.bold: true
        font.pixelSize: 14
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: chatImage.right
        readOnly: true
        wrapMode: Text.WordWrap
        selectByMouse: true
    }

    StyledText {
        id: replyText
        text: Emoji.parse(message, "26x26")
        anchors.left: replyToUsername.left
        anchors.top: replyToUsername.bottom
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding * 2 + closeButton.width
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        font.pixelSize: 15
        textFormat: Text.RichText
    }
    
}
