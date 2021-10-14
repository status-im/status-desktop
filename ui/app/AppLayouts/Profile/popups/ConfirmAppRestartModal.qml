import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"

// TODO: replace with StatusModal
ModalPopup {
    height: 237
    width: 400

    property Popup parentPopup
    
    title: qsTr("Application Restart")

    StyledText {
        text: qsTr("Please restart the application to apply the changes.")
        font.pixelSize: 15
        anchors.left: parent.left
        anchors.right: parent.right
        wrapMode: Text.WordWrap
    }

    footer: Item {
        id: footerContainer
        width: parent.width
        height: children[0].height

        StatusButton {
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            type: "warn"
            text: qsTr("Restart")
            anchors.bottom: parent.bottom
            onClicked: Qt.quit()
        }
    }
}
