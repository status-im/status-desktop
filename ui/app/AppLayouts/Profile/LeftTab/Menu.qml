import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1

import "../../../../imports"
import "./constants.js" as ProfileConstants

ScrollView {
    property var changeProfileSection: function (sectionId) {
        Config.currentMenuTab = sectionId
    }
    ScrollBar.horizontal.policy: Qt.ScrollBarAlwaysOff
    contentHeight: menuItems.height + 24

    id: profileMenu
    clip: true

    Column {
        id: menuItems
        spacing: 4

        Repeater {
            model: ProfileConstants.mainMenuButtons
            delegate: StatusNavigationListItem {
                itemId: modelData.id
                title: modelData.text
                icon.name: modelData.icon
                selected: Config.currentMenuTab === modelData.id
                onClicked: Config.currentMenuTab = modelData.id
            }
        }

        StatusListSectionHeadline { text: "Settings" }

        Repeater {
            model: ProfileConstants.settingsMenuButtons
            delegate: StatusNavigationListItem {
                itemId: modelData.id
                title: modelData.text
                icon.name: modelData.icon
                selected: Config.currentMenuTab === modelData.id
                onClicked: Config.currentMenuTab = modelData.id
                visible: modelData.ifEnabled !== "browser" || appSettings.isBrowserEnabled
            }
        }

        Item {
            id: invisibleSeparator
            height: 16
            width: parent.width
        }

        Repeater {
            model: ProfileConstants.extraMenuButtons
            delegate: StatusNavigationListItem {
                itemId: modelData.id
                title: modelData.text
                icon.name: modelData.icon
                selected: Config.currentMenuTab === modelData.id
                visible: modelData.ifEnabled !== "browser" || appSettings.isBrowserEnabled
                onClicked: function () {
                    if (modelData.function === "exit") {
                        return Qt.quit()
                    }
                    Config.currentMenuTab = modelData.id
                }
            }
        }
    }
}
