import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledTextEdit {
    id: chatText
    visible: contentType == Constants.messageType || isEmoji
    textFormat: Text.RichText
    horizontalAlignment: Text.AlignLeft
    wrapMode: Text.Wrap
    font.pixelSize: 15
    readOnly: true
    selectByMouse: true
    color: Style.current.textColor
    z: 51
    onLinkActivated: function (link) {
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
    text: {
        if(contentType === Constants.stickerType) return "";
        let msg = Utils.linkifyAndXSS(message);
        if(isEmoji){
            return Emoji.parse(msg, "72x72");
        } else {
            return `<html>`+
                `<head>`+
                    `<style type="text/css">`+
                    `code {`+
                        `background-color: #1a356b;`+
                        `color: #FFFFFF;`+
                        `white-space: pre;`+
                    `}`+
                    `p {`+
                        `white-space: pre-wrap;`+
                    `}`+
                    `a.mention {`+
                        `color: ${isCurrentUser ? Style.current.black : Style.current.white};`+
                        `font-weight: bold;`+
                    `}`+
                    `blockquote {`+
                        `margin: 0;`+
                        `padding: 0;`+
                    `}`+
                    `</style>`+
                `</head>`+
                `<body>`+
                    `${Emoji.parse(msg, "26x26")}`+
                `</body>`+
            `</html>`;
        }
    }
}
