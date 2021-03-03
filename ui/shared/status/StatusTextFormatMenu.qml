import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../imports"
import "./"

Menu {
    id: root
    width: 132
    height: 36

    onClosed: {
        messageInputField.deselect()
    }

    background: Item {
        id: menuBackground
        Rectangle {
            id: menuBackgroundContent
            implicitWidth: menuBackground.width
            implicitHeight: menuBackground.height
            color: Style.current.modalBackground
            radius: Style.current.radius
            layer.enabled: true
            layer.effect: DropShadow{
                width: menuBackgroundContent.width
                height: menuBackgroundContent.height
                x: menuBackgroundContent.x
                visible: menuBackgroundContent.visible
                source: menuBackgroundContent
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                spread: 0.2
                color: "#22000000"
            }
        }
    }

    contentItem: Item {
        width: root.width
        height: root.height
        Row {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          Repeater {
              model: root.contentModel
          }
        }
    }

    delegate: MenuItem {
        id: menuItem
        width: 32
        height: 32
        leftPadding: 0
        topPadding: 0
        action: Action {}
        contentItem: Item {
            StatusIconButton {
                icon.name: menuItem.action.icon.name
                icon.width: menuItem.action.icon.width
                icon.height: menuItem.action.icon.height
                onClicked: menuItem.action.trigger()
                highlighted: menuItem.action.checked
                StatusToolTip {
                    visible: parent.hovered
                    text: menuItem.action.text
                }
            }
        }
        background: Rectangle {
            color: "transparent"
        }
    }
}
