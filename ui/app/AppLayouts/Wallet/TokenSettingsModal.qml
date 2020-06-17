import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../imports"
import "../../../shared"
import "./Components"

Item {
    function open() {
        popup.open()
    }

    function close() {
        popup.close()
    }

    Popup {
        id: popup
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        Overlay.modal: Rectangle {
            color: "#60000000"
        }
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: 480
        height: 510
        background: Rectangle {
            color: Theme.white
            radius: Theme.radius
        }
        padding: 0
        contentItem: TokenSettingsModalContent {
            id: settingsModalContent
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
