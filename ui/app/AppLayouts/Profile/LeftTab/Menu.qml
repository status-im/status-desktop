import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./components"
import "./constants.js" as ProfileConstants

ScrollView {
    readonly property int btnheight: 42
    readonly property int w: 340
    property var changeProfileSection: function (sectionId) {
        Config.currentMenuTab = sectionId
    }
    contentHeight: menuItems.height + 24

    id: profileMenu
    clip: true

    Column {
        id: menuItems
        spacing: 8

        Repeater {
            model: ProfileConstants.mainMenuButtons
            delegate: MenuButton {
                menuItemId: modelData.id
                text: modelData .text
                source: "../../../img/profile/" + modelData.filename
                active: Config.currentMenuTab === modelData.id
                Layout.fillWidth: true
                width: profileMenu.width
                onClicked: {
                    Config.currentMenuTab = modelData.id
                }
            }
        }

        StyledText {
            topPadding: 10
            leftPadding: 20
            text: "Settings"
            color: Style.current.secondaryText
        }

        Repeater {
            model: ProfileConstants.settingsMenuButtons
            delegate: MenuButton {
                menuItemId: modelData.id
                text: modelData .text
                source: "../../../img/profile/" + modelData.filename
                active: Config.currentMenuTab === modelData.id
                visible: {
                    if((profileModel.fleets.fleet == Constants.waku_prod || profileModel.fleets.fleet === Constants.waku_test) && modelData.id === 8){
                        // Disable sync settings. - TODO: remove this once wakuV2 compatibility is added
                        return false;
                    } 
                    return modelData.ifEnabled !== "browser" || appSettings.isBrowserEnabled
                }
                Layout.fillWidth: true
                width: profileMenu.width
                onClicked: function () {
                    Config.currentMenuTab = modelData.id
                }
            }
        }

        StyledText {
            text: " "
        }

        Repeater {
            model: ProfileConstants.extraMenuButtons
            delegate: MenuButton {
                menuItemId: modelData.id
                text: modelData.text
                source: "../../../img/profile/" + modelData.filename
                active: Config.currentMenuTab === modelData.id
                Layout.fillWidth: true
                width: profileMenu.width
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
