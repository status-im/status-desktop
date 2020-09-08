import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../imports"
import "../../../shared"
import "./components"

ModalPopup {
    id: popup
    //% "Add/Remove Tokens"
    title: qsTrId("add/remove-tokens")
    
    
    TokenSettingsModalContent {
        id: settingsModalContent
    }

    footer: StyledButton {
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        //% "Add custom token"
        label: qsTrId("add-custom-token")
        anchors.top: parent.top
        onClicked: addCustomTokenModal.open()
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
