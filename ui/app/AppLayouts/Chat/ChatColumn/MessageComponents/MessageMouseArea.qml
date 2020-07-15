import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

MouseArea {
    cursorShape: chatText.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: {
        if(mouse.button & Qt.RightButton) {
            clickMessage()
            return;
        }

        let link = chatText.hoveredLink;
        if(link.startsWith("#")){
            chatsModel.joinChat(link.substring(1), Constants.chatTypePublic);
            return;
        }

        if (link.startsWith('//')) {
          let pk = link.replace("//", "");
          profileClick(chatsModel.userNameOrAlias(pk), pk, chatsModel.generateIdenticon(pk))
          return;
        }

        Qt.openUrlExternally(link)
    }
}

