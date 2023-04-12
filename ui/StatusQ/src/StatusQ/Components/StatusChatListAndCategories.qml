import QtQuick 2.14
import QtQml.Models 2.14
import QtQuick.Controls 2.14 as QC

import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1

Item {
    id: root

    implicitHeight: chatListsAndCategories.height
    implicitWidth: chatListsAndCategories.width

    property alias highlightItem: statusChatList.highlightItem

    property StatusTooltipSettings categoryAddButtonToolTip: StatusTooltipSettings {
        text: qsTr("Add channel inside category")
    }
    property StatusTooltipSettings categoryMenuButtonToolTip: StatusTooltipSettings {
        text: qsTr("More")
    }

    property var model: []
    property bool showCategoryActionButtons: false
    property bool showPopupMenu: true
    property alias sensor: sensor
    property bool draggableItems: false
    property bool draggableCategories: false

    property Component categoryPopupMenu
    property Component chatListPopupMenu
    property Component popupMenu

    signal chatItemSelected(string categoryId, string id)
    signal chatItemUnmuted(string id)
    signal chatItemReordered(string categoryId, string chatId, int to)
    signal chatListCategoryReordered(string categoryId, int to)
    signal categoryAddButtonClicked(string id)

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    MouseArea {
        id: sensor
        anchors.top: parent.top
        width: root.width
        height: root.height
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton && showPopupMenu && !!root.popupMenu) {
                popupMenuSlot.item.popup(mouse.x + 4, mouse.y + 6)
                return
            }
        }

        Column {
            id: chatListsAndCategories

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4

            StatusChatList {
                objectName: "statusChatListAndCategoriesChatList"
                id: statusChatList
                visible: statusChatList.model.count > 0
                onChatItemSelected: root.chatItemSelected(categoryId, id)
                onChatItemUnmuted: root.chatItemUnmuted(id)
                onChatItemReordered: {
                    root.chatItemReordered(categoryId, chatId, to)
                }
                onCategoryReordered: root.chatListCategoryReordered(categoryId, to)
                draggableItems: root.draggableItems
                showCategoryActionButtons: root.showCategoryActionButtons
                onCategoryAddButtonClicked: {
                    root.categoryAddButtonClicked(id)
                }

                model: root.model

                popupMenu: root.chatListPopupMenu
                categoryPopupMenu: root.categoryPopupMenu
            }
        }
    }

    Loader {
        id: popupMenuSlot
        active: !!root.popupMenu
    }
}
