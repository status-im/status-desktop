import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Rectangle {
  property int topMargin: Style.current.smallPadding
  property int bottomMargin: Style.current.smallPadding
  property string channelName
  property int channelType
  property string channelIdenticon
  id: contactImage
  width: 36
  height: 36
  anchors.left: parent.left
  anchors.leftMargin: Style.current.padding
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
      radius: 120
      color: {
          const color = chatsModel.getChannelColor(channelName)
          if (!color) {
              return Style.current.transparent
          }
          return color
      }

      StyledText {
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
      color: Style.current.transparent
      SVGImage {
          width: contactImage.width ? contactImage.width : 40
          height: contactImage.height ? contactImage.height : 40
          fillMode: Image.PreserveAspectFit
          source: channelIdenticon
      }
    }
  }
}
