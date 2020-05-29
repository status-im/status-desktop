import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../imports"
import "./"

Popup {
  property string title: "Default Title"
  default property alias content : popupContent.children

  id: popup
  modal: true
  property alias footer : footerContent.children

  Overlay.modal: Rectangle {
      color: "#60000000"
  }
  closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
  parent: Overlay.overlay
  x: Math.round((parent.width - width) / 2)
  y: Math.round((parent.height - height) / 2)
  width: 480
  height: 509
  background: Rectangle {
      color: Theme.white
      radius: 8
  }
  padding: 0
  contentItem: Item {
      Text {
          id: modalDialogTitle
          text: title
          anchors.top: parent.top
          anchors.left: parent.left
          font.bold: true
          font.pixelSize: 17
          anchors.leftMargin: 16
          anchors.topMargin: 16
      }

      Rectangle {
          id: closeButton
          height: 32
          width: 32
          anchors.top: parent.top
          anchors.topMargin: Theme.padding
          anchors.rightMargin: Theme.padding
          anchors.right: parent.right
          radius: 8

          Image {
              id: closeModalImg
              source: "../../../img/close.svg"
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.verticalCenter: parent.verticalCenter
          }

          MouseArea {
              id: closeModalMouseArea
              cursorShape: Qt.PointingHandCursor
              anchors.fill: parent
              hoverEnabled: true
              onExited: {
                  closeButton.color = Theme.white
              }
              onEntered:{
                  closeButton.color = Theme.grey
              }
              onClicked : {
                  popup.close()
              }
          }
      }
      
      Separator {
          id: separator
          anchors.top: modalDialogTitle.bottom
      }

      Item {
        id: popupContent
        anchors.top: separator.bottom
        anchors.bottom: separator2.top
        anchors.left: popup.left
        anchors.right: popup.right
        width: popup.width
      }

      Separator {
          id: separator2
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 75
      }

      Item {
        id: footerContent
        width: parent.width
        anchors.top: separator2.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.padding
        anchors.rightMargin: Theme.padding
        anchors.leftMargin: Theme.padding
      }
  }
}

