import QtQuick 2.13
import QtGraphicalEffects 1.13
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

Item {
    id: statusChatInfoToolBar

    implicitWidth: 288
    implicitHeight: 56

    property alias chatInfoButton: statusChatInfoButton
    property Component popupMenu

    signal chatInfoButtonClicked()
    signal addButtonClicked(var mouse)

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    StatusChatInfoButton {
        id: statusChatInfoButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        type: StatusChatInfoButton.Type.OneToOneChat
        onClicked: statusChatInfoToolBar.chatInfoButtonClicked()
    }

    StatusRoundButton {
        id: menuButton
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        visible: popupMenuSlot.active
        width: 32
        height: 32

        type: StatusRoundButton.Type.Secondary
        icon.name: "add"
        state: "default"

        states: [
            State {
                name: "default"
                PropertyChanges {
                    target: menuButton
                    icon.rotation: 0
                }
            },
            State {
                name: "pressed"
                PropertyChanges {
                    target: menuButton
                    icon.rotation: 45
                    highlighted: true
                }
            }
        ]

        transitions: [
            Transition {
                from: "default"
                to: "pressed"

                RotationAnimation {
                    duration: 150
                    direction: RotationAnimation.Clockwise
                    easing.type: Easing.InCubic
                }
            },
            Transition {
								from: "pressed"
								to: "default"
								RotationAnimation {
										duration: 150
										direction: RotationAnimation.Counterclockwise
										easing.type: Easing.OutCubic
								}
        		}
        ]

        onClicked: {
            statusChatInfoToolBar.addButtonClicked(mouse)
            menuButton.state = "pressed"
            popupMenuSlot.item.popup(menuButton.width-popupMenuSlot.item.width, menuButton.height + 4)
        }

        Loader {
            id: popupMenuSlot
            active: !!statusChatInfoToolBar.popupMenu
            onLoaded: {
                popupMenuSlot.item.closeHandler = function () {
                    menuButton.state = "default"
                }
            }
        }
    }

}
