import QtQuick 2.13

// Source: https://forum.qt.io/topic/52161/properly-scaling-svg-images/6

Image {
  sourceSize: Qt.size(Math.max(hiddenImg.sourceSize.width * 2, 250), Math.max(hiddenImg.sourceSize.height * 2, 250))
  Image {
    id: hiddenImg
    source: parent.source
    width: 0
    height: 0
  }
}
