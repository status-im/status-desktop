import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: appearanceContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: title
        text: qsTr("Appearance setting")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    RowLayout {
        property bool isDarkTheme: {
            const isDarkTheme = profileModel.profile.appearance === 1
            if (isDarkTheme) {
                Style.changeTheme('dark')
            } else {
                Style.changeTheme('light')
            }
            return isDarkTheme
        }
        id: themeSetting
        anchors.top: title.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Theme (Light - Dark)"
            text: qsTrId("theme-(light---dark)")
        }
        Switch {
            checked: themeSetting.isDarkTheme
            onToggled: function() {
                profileModel.changeTheme(themeSetting.isDarkTheme ? 0 : 1)
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
