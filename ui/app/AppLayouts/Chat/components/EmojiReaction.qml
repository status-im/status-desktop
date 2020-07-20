import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"

SVGImage {
    property int emojiId
    width: 32
    fillMode: Image.PreserveAspectFit

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            console.log('Clicked on Emoji', emojiId)
            console.log('This feature will be implmented at a later date')

        }
    }
}
