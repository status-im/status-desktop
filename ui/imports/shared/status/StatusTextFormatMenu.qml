import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Menu {
    id: root
    width: 165
    height: 36

    background: Item {
        id: menuBackground
        Rectangle {
            id: menuBackgroundContent
            implicitWidth: menuBackground.width
            implicitHeight: menuBackground.height
            color: Theme.palette.indirectColor2
            radius: Theme.radius
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
            anchors.centerIn: parent
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
            StatusFlatRoundButton {
                width: 32
                height: 32
                icon.width: 24
                icon.height: 24
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
