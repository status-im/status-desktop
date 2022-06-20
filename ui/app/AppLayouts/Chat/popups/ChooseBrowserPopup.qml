import QtQuick 2.12
import QtQuick.Controls 2.3

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    property string link

    id: popup
    anchors.centerIn: parent

    //% "Choose browser"
    header.title: qsTrId("choose-browser")
    width: Style.dp(440)

    contentItem: Column {
        width: popup.width - Style.dp(32)
        spacing: Style.dp(20)
        anchors.horizontalCenter: popup.horizontalCenter

        Image {
            source: Style.png("browser/chooseBrowserImage")
            width: Style.dp(240)
            height: Style.dp(148)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StatusButton {
            //% "Open in Status"
            text: qsTrId("browsing-open-in-status")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                localAccountSensitiveSettings.showBrowserSelector = !rememberChoiceCheckBox.checked
                if (rememberChoiceCheckBox.checked) {
                    localAccountSensitiveSettings.openLinksInStatus = true
                }
                Global.changeAppSectionBySectionType(Constants.appSection.browser)
                browserLayoutContainer.item.openUrlInNewTab(popup.link)
                popup.close()
            }
        }

        StatusFlatButton {
            //% "Open in my default browser"
            text: qsTrId("open-in-my-default-browser")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                localAccountSensitiveSettings.showBrowserSelector = !rememberChoiceCheckBox.checked
                if (rememberChoiceCheckBox.checked) {
                    localAccountSensitiveSettings.openLinksInStatus = false
                }
                Qt.openUrlExternally(popup.link)
                popup.close()
            }
        }


        StatusCheckBox {
            id: rememberChoiceCheckBox
            //% "Remember my choice. To override it, go to settings."
            text: qsTrId("remember-my-choice--to-override-it--go-to-settings-")
            width: parent.width
        }
    }
}

