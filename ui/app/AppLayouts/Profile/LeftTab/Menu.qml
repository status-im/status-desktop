import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1

import "../../../../shared"
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
                id: settingsMenuDelegate
                itemId: modelData.id
                title: modelData.text
                icon.name: modelData.icon
                selected: Config.currentMenuTab === modelData.id
                onClicked: Config.currentMenuTab = modelData.id
                visible: modelData.ifEnabled !== "browser" || appSettings.isBrowserEnabled
                badge.value: (!profileModel.mnemonic.isBackedUp && (settingsMenuDelegate.title ===
                             ProfileConstants.settingsMenuButtons[0].text)) ? 1 : 0
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
                        return confirmDialog.open()
                    }
                    Config.currentMenuTab = modelData.id
                }
            }
        }
    }

    ConfirmationDialog {
        id: confirmDialog
        header.title: qsTr("Sign out")
        confirmationText: qsTr("Make sure you have your account password and seed phrase stored. Without them you can lock yourself out of your account and lose funds.")
        confirmButtonLabel: qsTr("Sign out & Quit")
        onConfirmButtonClicked: {
            Qt.quit()
        }
    }
}
