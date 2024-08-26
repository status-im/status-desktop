import QtQuick 2.15

Image {
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
