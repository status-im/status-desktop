import QtQuick 2.13

Image {
  sourceSize.width: width
  sourceSize.height: height

  fillMode: Image.PreserveAspectFit

  mipmap: true
  antialiasing: true
}
