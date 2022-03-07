import QtQuick 2.13
import StatusQ.Core.Utils 0.1 as StatusQUtils
import utils 1.0

Text {
    id: root
    property string publicKey
    property string size: "14x14"
    renderType: Text.NativeRendering
    font.pointSize: 1 // make sure there is no padding for emojis due to 'style: "vertical-align: top"'
    text: {
        const emojiHash = Utils.getEmojiHashAsJson(root.publicKey);
        var emojiHashFirstLine = "";
        var emojiHashSecondLine = "";
        for (var i = 0; i < 7; i++) {
            emojiHashFirstLine += emojiHash[i];
        }
        for (var j = 7; j < emojiHash.length; j++) {
            emojiHashSecondLine += emojiHash[j];
        }
        return StatusQUtils.Emoji.parse(emojiHashFirstLine, size) + "<br>" +
               StatusQUtils.Emoji.parse(emojiHashSecondLine, size)
    }
}
