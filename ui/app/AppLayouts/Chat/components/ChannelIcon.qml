import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../imports"
import "../../../../shared"

Rectangle {
  property int topMargin: Theme.smallPadding
  property int bottomMargin: Theme.smallPadding
  property string channelName
  property int channelType
  property string channelIdenticon
  id: contactImage
  width: 36
  height: 36
  anchors.left: parent.left
  anchors.leftMargin: Theme.padding
  anchors.top: parent.top
  anchors.topMargin: topMargin
  anchors.bottom: parent.bottom
  anchors.bottomMargin: bottomMargin
  radius: 50

  Loader {
    sourceComponent: channelType == Constants.chatTypeOneToOne ? imageIdenticon : letterIdenticon
    anchors.fill: parent
  }

  Component {
    id: letterIdenticon
    Rectangle {
      width: contactImage.width ? contactImage.width : 36
      height: contactImage.height ? contactImage.height: 36
      radius: 50
      color: {
          const color = chatsModel.getChannelColor(channelName)
          if (!color) {
              return Theme.transparent
          }
          return color
      }

      Text {
        text: {
          if (channelType == Constants.chatTypeOneToOne) {
            return channelName;
          } else {
            return (channelName.charAt(0) == "#" ? channelName.charAt(1) : channelName.charAt(0)).toUpperCase();
          }
        }
        opacity: 0.7
        font.weight: Font.Bold
        font.pixelSize: 21
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
      }
    }
  }

  Component {
    id: imageIdenticon
    Rectangle {
      width: contactImage.width ? contactImage.width : 40
      height: contactImage.height ? contactImage.height : 40
      radius: 50
      border.color: "#10000000"
      border.width: 1
      color: Theme.transparent
      Image {
          width: contactImage.width ? contactImage.width : 40
          height: contactImage.height ? contactImage.height : 40
          fillMode: Image.PreserveAspectFit
          source: channelIdenticon
      }
    }
  }
}

