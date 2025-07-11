import QtQuick

Image {
    sourceSize.width: width || undefined
    sourceSize.height: height || undefined
    fillMode: Image.PreserveAspectFit
    mipmap: true
    antialiasing: true
}
