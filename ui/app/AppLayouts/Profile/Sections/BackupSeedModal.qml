import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup

    title: qsTr("Write down your seed phrase")

    Item {

      id: seed
      anchors.left: parent.left
      anchors.right: parent.right
      width: parent.width
      height: children[0].height

      Rectangle {
        id: wrapper
        property int len: profileModel.mnemonic.split(" ").length
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        height: 40*(len/2)
        width: 350
        border.width: 1
        border.color: Theme.grey
        radius: Theme.radius
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
          model: profileModel.mnemonic.split(" ")
          Rectangle {
            id: word
            height: 40
            width: 175
            color: "transparent"
            anchors.top: (index == 0 || index == (wrapper.len/2)) ? parent.top : parent.children[index-1].bottom
            anchors.left: (index < (wrapper.len/2)) ? parent.left : undefined
            anchors.right: (index >= wrapper.len/2) ? parent.right : undefined

            Rectangle {
              width: 1
              height: parent.height
              anchors.top: parent.top
              anchors.bottom: parent.bottom
              anchors.right: parent.right
              anchors.rightMargin: 175
              color: Theme.grey
              visible: index >= wrapper.len/2
            }

            Text {
              id: count
              text: index+1
              color: Theme.darkGrey
              anchors.bottom: parent.bottom
              anchors.bottomMargin: Theme.smallPadding
              anchors.left: parent.left
              anchors.leftMargin: Theme.bigPadding
              font.pixelSize: 15
            }

            TextEdit {
              text: modelData
              font.pixelSize: 15
              anchors.bottom: parent.bottom
              anchors.bottomMargin: Theme.smallPadding
              anchors.left: count.right
              anchors.leftMargin: Theme.padding
              selectByMouse: true
              readOnly: true
            }

          }
        }
      }
    }

    Text {
      id: confirmationsInfo
      text: qsTr("With this 12 words you can always get your key back. Write it down. Keep it safe, offline, and separate from this device.")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
      anchors.bottom: parent.bottom
      anchors.bottomMargin: Theme.padding
      anchors.left: parent.left
      anchors.leftMargin: Theme.smallPadding
      anchors.right: parent.right
      anchors.rightMargin: Theme.smallPadding
      wrapMode: Text.WordWrap
    }

    footer: StyledButton {
      label: qsTr("Done")
      anchors.right: parent.right
      anchors.rightMargin: Theme.smallPadding
      anchors.bottom: parent.bottom
      onClicked: {
        backupSeedModal.close()
      }
    }
}
