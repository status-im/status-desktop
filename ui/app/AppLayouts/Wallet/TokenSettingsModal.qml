import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../imports"
import "../../../shared"
import "./components"

ModalPopup {
    id: popup
    title: qsTr("Add/Remove Tokens")
    
    
    TokenSettingsModalContent {
        id: settingsModalContent
    }

    footer: StyledButton {
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        label: qsTr("Add custom token")
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        onClicked: {
            popup.close()
            addCustomTokenModal.open()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
