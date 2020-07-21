import QtQuick 2.13

// Source: https://forum.qt.io/topic/52161/properly-scaling-svg-images/6

Image {
  sourceSize: Qt.size(hiddenImg.sourceSize.width * 2, hiddenImg.sourceSize.height * 2)
  Image {
    id: hiddenImg
    source: parent.source
    width: 0
    height: 0
  }
}
