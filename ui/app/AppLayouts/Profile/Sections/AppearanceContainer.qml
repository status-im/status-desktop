import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls.Universal 2.12
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ScrollView {
    height: parent.height
    width: parent.width
    id: root
    contentHeight: appearanceContainer.height
    clip: true

    enum Theme {
        Light,
        Dark,
        System
    }

    function updateTheme(theme) {
        let themeStr = Universal.theme === Universal.Dark ? "dark" : "light"
        if (theme === AppearanceContainer.Theme.Light) {
            themeStr = "light"
        } else if (theme === AppearanceContainer.Theme.Dark) {
            themeStr = "dark"
        }
        profileModel.changeTheme(theme)
        Style.changeTheme(themeStr)
    }

    Item {
        id: appearanceContainer
        anchors.right: parent.right
        anchors.rightMargin: contentMargin
        anchors.left: parent.left
        anchors.leftMargin: contentMargin
        height: this.childrenRect.height + 100

        ButtonGroup {
            id: chatModeSetting
        }

        ButtonGroup {
            id: appearanceSetting
        }

        StatusSectionHeadline {
            id: sectionHeadlineChatMode
            text: qsTr("Chat mode")
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }

        RowLayout {
            id: chatModeSection
            anchors.top: sectionHeadlineChatMode.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding

            StatusImageRadioButton {
                padding: Style.current.padding
                image.source: "../../../img/appearance-normal-light.svg"
                image.height: 186
                control.text: qsTr("Normal")
                control.checked: !appSettings.compactMode
                control.onCheckedChanged: {
                    if (control.checked) {
                        appSettings.compactMode = false
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.padding
                image.source: "../../../img/appearance-compact-light.svg"
                image.height: 186
                control.text: qsTr("Compact")
                control.checked: appSettings.compactMode
                control.onCheckedChanged: {
                    if (control.checked) {
                        appSettings.compactMode = true
                    }
                }
            }
        }

        StatusSectionHeadline {
            id: sectionHeadlineAppearance
            text: qsTr("Appearance")
            anchors.top: chatModeSection.bottom
            anchors.topMargin: Style.current.padding*3
            anchors.left: parent.left
            anchors.right: parent.right
        }

        RowLayout {
            id: appearanceSection
            anchors.top: sectionHeadlineAppearance.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: "../../../img/appearance-normal-light.svg"
                image.height: 128
                control.text: qsTr("Light")
                control.checked: profileModel.profile.appearance === AppearanceContainer.Theme.Light
                control.onClicked: {
                    if (control.checked) {
                        root.updateTheme(AppearanceContainer.Theme.Light)
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: "../../../img/appearance-normal-dark.svg"
                image.height: 128
                control.text: qsTr("Dark")
                control.checked: profileModel.profile.appearance === AppearanceContainer.Theme.Dark
                control.onClicked: {
                    if (control.checked) {
                        root.updateTheme(AppearanceContainer.Theme.Dark)
                    }
                }
            }

            StatusImageRadioButton {
                padding: Style.current.smallPadding
                width: 208
                height: 184
                image.source: "../../../img/appearance-normal-system.png"
                image.height: 128
                control.text: qsTr("System")
                control.checked: profileModel.profile.appearance === AppearanceContainer.Theme.System
                control.onClicked: {
                    if (control.checked) {
                        root.updateTheme(AppearanceContainer.Theme.System)
                    }
                }
            }

            // For the case where the theme was finally loaded by status-go in init(),
            // update the theme in qml
            Connections {
                target: profileModel
                onProfileChanged: {
                    root.updateTheme(profileModel.profile.appearance)
                }
            }
        }
    }
}
