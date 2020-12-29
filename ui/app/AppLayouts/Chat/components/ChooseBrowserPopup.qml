import QtQuick 2.12
import QtQuick.Controls 2.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string link

    id: popup

    title: qsTr("Choose browser")
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
            text: qsTr("Open in Status")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                appSettings.showBrowserSelector = !rememberChoiceCheckBox.checked
                changeAppSection(Constants.browser)
                browserLayoutContainer.item.openUrlInNewTab(popup.link)
                popup.close()
            }
        }

        StatusButton {
            text: qsTr("Open in my default browser")
            type: "secondary"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                appSettings.showBrowserSelector = !rememberChoiceCheckBox.checked
                Qt.openUrlExternally(popup.link)
            }
        }


        StatusCheckBox {
            id: rememberChoiceCheckBox
            text: qsTr("Remember my choice. To override it, go to settings.")
            width: parent.width
        }
    }
}

