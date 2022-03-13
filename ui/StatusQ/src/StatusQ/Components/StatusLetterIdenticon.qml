import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

Rectangle {
    id: root

    property alias identiconText: identiconText
    property string name
    property string emoji
    property int letterSize: 21
    property int charactersLen: 1

    color: Theme.palette.miscColor5
    width: 40
    height: 40
    radius: width / 2

    StatusBaseText {
        id: identiconText

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.alignWhenCentered: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font.weight: Font.Bold
        font.pixelSize: root.letterSize
        color: Qt.rgba(255, 255, 255, 0.7)

        text: {
            if (emoji) {
                if(Utils.isHtml(emoji))
                    return emoji
                else
                    return Emoji.parse(emoji)
            }

            const shift = (root.name.charAt(0) === "#") ||
                          (root.name.charAt(0) === "@")

            return root.name.substring(shift, shift + charactersLen).toUpperCase()
        }
    }
}

