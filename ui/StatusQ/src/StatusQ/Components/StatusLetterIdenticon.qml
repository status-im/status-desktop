import QtQuick 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

Rectangle {
    id: root

    property alias identiconText: identiconText
    property string name
    property string emoji
    property string emojiSize: Emoji.size.small
    property int letterSize: 21
    property int charactersLen: 1
    property color letterIdenticonColor: Theme.palette.miscColor5
    property bool useAcronymForLetterIdenticon: false

    color: {
        if (root.useAcronymForLetterIdenticon) {
            return Qt.rgba(root.letterIdenticonColor.r, root.letterIdenticonColor.g, root.letterIdenticonColor.b, 0.2)
        }
        return root.letterIdenticonColor
    }

    width: 40
    height: 40
    radius: width / 2

    StatusEmoji {
        visible: root.emoji
        anchors.centerIn: parent
        width: Math.round(parent.width / 2)
        height: Math.round(parent.height / 2)
        emojiId: Emoji.iconId(root.emoji, root.emojiSize) || ""
    }
    
    StatusBaseText {
        id: identiconText

        visible: !root.emoji
        anchors.alignWhenCentered: false
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        width: parent.width
        height: parent.height

        font.weight: Font.Bold
        font.pixelSize: root.letterSize
        color: {
            if (root.useAcronymForLetterIdenticon) {
                return root.letterIdenticonColor
            }
            return d.luminance(root.letterIdenticonColor) > 0.5 ? Qt.rgba(0, 0, 0, 0.5) : Qt.rgba(1, 1, 1, 0.7)
        }

        text: {
            let parts = root.name.split(" ")
            if (root.useAcronymForLetterIdenticon && parts.length > 1) {
                let word = ""
                for (let i=0; i<root.charactersLen; i++) {
                    if (i >= parts.length) {
                        return word
                    }

                    let shift = (parts[i].charAt(0) === "#") ||
                                (parts[i].charAt(0) === "@")

                    word += parts[i].substring(shift, shift + 1).toUpperCase()
                }
                return word
            }

            const shift = (root.name.charAt(0) === "#") ||
                          (root.name.charAt(0) === "@")
            return root.name.substring(shift, shift + charactersLen).toUpperCase()
        }
    }

    QtObject {
        id: d
        function luminance(color) {
            let r = Math.pow(color.r, 2.2) * 0.2126
            let g = Math.pow(color.g, 2.2) * 0.7151
            let b = Math.pow(color.b, 2.2) * 0.0721
            return r + g + b
        }
    }
}

