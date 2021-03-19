import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup

    //% "Open links with..."
    title: qsTrId("open-links-with---")

    onClosed: {
        destroy()
    }

    Column {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding

        spacing: 0

        ButtonGroup {
            id: openLinksWithGroup
        }

        StatusRadioButtonRow {
            text: "Status"
            buttonGroup: openLinksWithGroup
            checked: appSettings.openLinksInStatus
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.openLinksInStatus = true
                }
            }
        }
        StatusRadioButtonRow {
            //% "My default browser"
            text: qsTrId("my-default-browser")
            buttonGroup: openLinksWithGroup
            checked: !appSettings.openLinksInStatus
            onRadioCheckedChanged: {
                if (checked) {
                    appSettings.openLinksInStatus = false
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
