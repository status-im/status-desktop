import QtQuick 2.13

Image {
    sourceSize.width: width || undefined
    sourceSize.height: height || undefined
    fillMode: Image.PreserveAspectFit
    mipmap: true
    antialiasing: true
}
