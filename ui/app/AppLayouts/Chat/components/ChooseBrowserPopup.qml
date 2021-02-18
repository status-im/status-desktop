import QtQuick 2.12
import QtQuick.Controls 2.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string link

    id: popup

    //% "Choose browser"
    title: qsTrId("choose-browser")
    width: 440
    height: 425

    Column {
        anchors.fill: parent
        spacing: 20

        Image {
            source: "../../../img/chooseBrowserImage.png"
            width: 240
            height: 148
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StatusButton {
            //% "Open in Status"
            text: qsTrId("browsing-open-in-status")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                appSettings.showBrowserSelector = !rememberChoiceCheckBox.checked
                changeAppSection(Constants.browser)
                browserLayoutContainer.item.openUrlInNewTab(popup.link)
                popup.close()
            }
        }

        StatusButton {
            //% "Open in my default browser"
            text: qsTrId("open-in-my-default-browser")
            type: "secondary"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                appSettings.showBrowserSelector = !rememberChoiceCheckBox.checked
                Qt.openUrlExternally(popup.link)
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

