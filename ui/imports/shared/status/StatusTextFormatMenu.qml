import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import StatusQ.Controls 0.1
import utils 1.0

Menu {
    id: root
    width: Style.dp(132)
    height: Style.dp(36)

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
                verticalOffset: Style.dp(4)
                radius: Style.dp(12)
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
        width: Style.dp(32)
        height: Style.dp(32)
        leftPadding: 0
        topPadding: 0
        action: Action {}
        contentItem: Item {
            StatusFlatRoundButton {
                width: Style.dp(32)
                height: Style.dp(32)
                icon.width: Style.dp(24)
                icon.height: Style.dp(24)
                icon.name: menuItem.action.icon.name
                highlighted: menuItem.action.checked
                tooltip.text: menuItem.action.text
                type: StatusFlatRoundButton.Type.Tertiary
                onClicked: menuItem.action.actionTriggered()
            }
        }
        background: Rectangle {
            color: "transparent"
        }
    }
}
