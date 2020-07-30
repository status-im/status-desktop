import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Item {
  id: root
  property string selectedColor
  //% "Account color"
  property string label: qsTrId("account-color")
  property var model
  height: accountColorInput.height

  Select {
      id: accountColorInput
      bgColor: selectedColor
      label: root.label
      model: root.model

      menu.delegate: Component {
          MenuItem {
              property bool isFirstItem: index === 0
              property bool isLastItem: index === root.model.length - 1
              height: 52
              width: parent.width
              padding: 10
              onTriggered: function () {
                  const selectedColor = root.model[index]
                  root.selectedColor = selectedColor
              }
              background: Rectangle {
                  color: root.model[index] || Style.current.transparent
                  radius: Style.current.radius

                  // cover bottom left/right corners with square corners
                  Rectangle {
                      visible: !isLastItem
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.bottom: parent.bottom
                      height: parent.radius
                      color: parent.color
                  }

                  // cover top left/right corners with square corners
                  Rectangle {
                      visible: !isFirstItem
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.top: parent.top
                      height: parent.radius
                      color: parent.color
                  }
              }
          }
      }
  }
}