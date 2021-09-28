import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../../../shared"
import "../../../shared/status"
import "./components"

ModalPopup {
    id: popup
    //% "Manage Assets"
    title: qsTrId("manage-assets")
    
    
    TokenSettingsModalContent {
        id: settingsModalContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
    }

    footer: StatusButton {
        anchors.right: parent.right
        //% "Add custom token"
        text: qsTrId("add-custom-token")
        anchors.top: parent.top
        onClicked: addCustomTokenModal.openEditable()
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
