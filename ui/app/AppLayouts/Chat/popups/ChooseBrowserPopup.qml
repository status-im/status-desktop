import QtQuick 2.12
import QtQuick.Controls 2.3

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    property string link

    id: popup
    anchors.centerIn: parent

    header.title: qsTr("Choose browser")
    width: 440

    contentItem: Column {
        width: popup.width - 32
        spacing: 20
        anchors.horizontalCenter: popup.horizontalCenter

        Image {
            source: Style.png("browser/chooseBrowserImage")
            width: 240
            height: 148
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StatusButton {
            text: qsTr("Open in Status")
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
            text: qsTr("Open in my default browser")
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
            text: qsTr("Remember my choice. To override it, go to settings.")
            width: parent.width
        }
    }
}

