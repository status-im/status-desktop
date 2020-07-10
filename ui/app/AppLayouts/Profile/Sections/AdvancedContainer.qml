import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    property var appSettings
    id: advancedContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: title
        //% "Advanced settings"
        text: qsTrId("advanced-settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    RowLayout {
        // TODO move this to a new panel once we have the appearance panel
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
            onCheckedChanged: function(value) {
                profileModel.changeTheme(themeSetting.isDarkTheme ? 0 : 1)
            }
        }
    }

    RowLayout {
        id: walletTabSettings
        anchors.top: themeSetting.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Wallet Tab"
            text: qsTrId("wallet-tab")
        }
        Switch {
            checked: walletBtn.enabled
            onCheckedChanged: function(value) {
                walletBtn.enabled = this.checked
            }
        }
        StyledText {
            //% "NOT RECOMMENDED - Use at your own risk"
            text: qsTrId("not-recommended---use-at-your-own-risk")
        }
    }

    RowLayout {
        id: browserTabSettings
        anchors.top: walletTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Browser Tab"
            text: qsTrId("browser-tab")
        }
        Switch {
            checked: browserBtn.enabled
            onCheckedChanged: function(value) {
                browserBtn.enabled = this.checked
            }
        }
        StyledText {
            //% "experimental (web3 not supported yet)"
            text: qsTrId("experimental-(web3-not-supported-yet)")
        }
    }

    RowLayout {
        id: nodeTabSettings
        anchors.top: browserTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Node Management Tab"
            text: qsTrId("node-management-tab")
        }
        Switch {
            checked: nodeBtn.enabled
            onCheckedChanged: function(value) {
                nodeBtn.enabled = this.checked
            }
        }
        StyledText {
            //% "under development"
            text: qsTrId("under-development")
        }
    }

    RowLayout {
        anchors.top: nodeTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            text: qsTr("Display images in chat automatically")
        }
        Switch {
            checked: appSettings.displayChatImages
            onCheckedChanged: function(value) {
              advancedContainer.appSettings.displayChatImages = this.checked
            }
        }
        StyledText {
            text: qsTr("under development")
        }
    }
}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
