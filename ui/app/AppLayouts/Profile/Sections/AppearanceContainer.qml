import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls.Universal 2.12
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    enum Theme {
        System, // 0
        Light,  // 1
        Dark    // 2
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

    StyledText {
        id: title
        //% "Appearance setting"
        text: qsTrId("appearance-setting")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    RowLayout {
        id: themeSetting
        anchors.top: title.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Theme (Light - Dark)"
            text: qsTrId("theme-(light---dark)")
        }
        ButtonGroup { id: appearance }

        StatusRadioButton {
            checked: profileModel.profile.appearance === AppearanceContainer.Theme.System
            Layout.alignment: Qt.AlignRight
            ButtonGroup.group: appearance
            rightPadding: 15
            text: qsTr("System")
            onClicked: {
                root.updateTheme(AppearanceContainer.Theme.System)
            }
        }
        StatusRadioButton {
            checked: profileModel.profile.appearance === AppearanceContainer.Theme.Light
            Layout.alignment: Qt.AlignRight
            ButtonGroup.group: appearance
            rightPadding: 15
            text: qsTr("Light")
            onClicked: {
                root.updateTheme(AppearanceContainer.Theme.Light)
            }
        }
        StatusRadioButton {
            checked: profileModel.profile.appearance === AppearanceContainer.Theme.Dark
            Layout.alignment: Qt.AlignRight
            ButtonGroup.group: appearance
            rightPadding: 0
            text: qsTr("Dark")
            onClicked: {
                root.updateTheme(AppearanceContainer.Theme.Dark)
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

    RowLayout {
        property bool isCompactMode: appSettings.compactMode
        id: compactModeSetting
        anchors.top: themeSetting.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Chat Compact Mode"
            text: qsTrId("chat-compact-mode")
        }
        Switch {
            checked: compactModeSetting.isCompactMode
            onToggled: function() {
                appSettings.compactMode = !compactModeSetting.isCompactMode
            }
        }
    }
}
