import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"

Rectangle {
    id: wrapper
    color: ListView.isCurrentItem ? Theme.lightBlue : Theme.transparent
    anchors.right: parent.right
    anchors.rightMargin: Theme.padding
    anchors.top: applicationWindow.top
    anchors.topMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: Theme.padding
    radius: 8
    // Hide the box if it is filtered out
    property bool isVisible: searchStr == "" || name.includes(searchStr)
    property int chatTypeOneToOne: 1
    visible: isVisible ? true : false
    height: isVisible ? 64 : 0

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            chatsModel.setActiveChannelByIndex(index)
            chatGroupsListView.currentIndex = index
        }
    }

    Rectangle {
      id: contactImage
      width: 40
      height: 40
      anchors.left: parent.left
      anchors.leftMargin: Theme.padding
      anchors.top: parent.top
      anchors.topMargin: 12
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 12
      radius: 50

      Loader {
        sourceComponent: chatType == chatTypeOneToOne ? imageIdenticon : letterIdenticon
        anchors.fill: parent
      }

      Component {
        id: letterIdenticon
        Rectangle {
          width: 40
          height: 40
          radius: 50
          color: {
              const color = chatsModel.getChannelColor(name)
              if (!color) {
                  return Theme.transparent
              }
              return color
          }

          Text {
            text: (name.charAt(0) == "#" ? name.charAt(1) : name.charAt(0)).toUpperCase()
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
          width: 40
          height: 40
          radius: 50
          border.color: "#10000000"
          border.width: 1
          color: Theme.transparent
          Image {
              width: 40
              height: 40
              fillMode: Image.PreserveAspectFit
              source: identicon
          }
        }
      }
    }

    Text {
        id: contactInfo
        text: chatType == chatTypeOneToOne ? name : "#" + name
        anchors.right: contactTime.left
        anchors.rightMargin: Theme.smallPadding
        elide: Text.ElideRight
        font.weight: Font.Medium
        font.pixelSize: 15
        anchors.left: contactImage.right
        anchors.leftMargin: Theme.padding
        anchors.top: parent.top
        anchors.topMargin: Theme.smallPadding
        color: "black"
    }
    Text {
        id: lastChatMessage
        text: lastMessage || qsTr("No messages")
        anchors.right: contactNumberChatsCircle.left
        anchors.rightMargin: Theme.smallPadding
        elide: Text.ElideRight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.smallPadding
        font.pixelSize: 15
        anchors.left: contactImage.right
        anchors.leftMargin: Theme.padding
        color: Theme.darkGrey
    }
    Text {
        id: contactTime
        text: timestamp
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.top: parent.top
        anchors.topMargin: Theme.smallPadding
        font.pixelSize: 11
        color: Theme.darkGrey
    }
    Rectangle {
        id: contactNumberChatsCircle
        width: 22
        height: 22
        radius: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        color: Theme.blue
        visible: unviewedMessagesCount > 0
        Text {
            id: contactNumberChats
            text: unviewedMessagesCount
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
        }
    }
}
