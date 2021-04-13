import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./components"
import "./constants.js" as ProfileConstants

ScrollView {
    property int profileCurrentIndex: ProfileConstants.PROFILE
    readonly property int btnheight: 42
    readonly property int w: 340
    property var changeProfileSection: function (sectionId) {
        profileCurrentIndex = sectionId
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
                active: profileMenu.profileCurrentIndex === modelData.id
                Layout.fillWidth: true
                width: profileMenu.width
                onClicked: function () {
                    profileMenu.profileCurrentIndex = modelData.id
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
                active: profileMenu.profileCurrentIndex === modelData.id
                visible: modelData.ifEnabled !== "browser" || appSettings.browserEnabled
                Layout.fillWidth: true
                width: profileMenu.width
                onClicked: function () {
                    profileMenu.profileCurrentIndex = modelData.id
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
                active: profileMenu.profileCurrentIndex === modelData.id
                Layout.fillWidth: true
                width: profileMenu.width
                onClicked: function () {
                    if (modelData.function === "exit") {
                        return Qt.quit()
                    }
                    profileMenu.profileCurrentIndex = modelData.id
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:340}
}
##^##*/
