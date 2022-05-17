import QtQuick 2.13
import StatusQ.Core 0.1


Image {
    id: root

    property string emojiId: ""
    
    width: 14
    height: 14
    sourceSize.width: width
    sourceSize.height: height

    fillMode: Image.PreserveAspectFit
    mipmap: true
    antialiasing: true
    source: emojiId ? `../../assets/twemoji/svg/${emojiId}.svg` : ""
}