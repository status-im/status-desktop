import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup

    title: qsTr("Open links with...")

    onClosed: {
        destroy()
    }

    Column {
        anchors.fill: parent
        spacing: Style.current.bigPadding

        ButtonGroup {
            id: openLinksWithGroup
        }

        StatusRadioButton {
            text: "Status"
            ButtonGroup.group: openLinksWithGroup
            checked: appSettings.openLinksInStatus
            onCheckedChanged: {
                if (checked) {
                    appSettings.openLinksInStatus = true
                }
            }
        }
        StatusRadioButton {
            text: qsTr("My default browser")
            ButtonGroup.group: openLinksWithGroup
            checked: !appSettings.openLinksInStatus
            onCheckedChanged: {
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
