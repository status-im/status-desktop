import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    height: 237
    width: 400

    property Popup parentPopup
    
    title: qsTr("Application Restart")

    StyledText {
        text: qsTr("Status app will be closed. Please restart it for the changes to take into effect.")
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
            text: qsTr("Proceed")
            anchors.bottom: parent.bottom
            onClicked: Qt.quit()
        }
    }
}
