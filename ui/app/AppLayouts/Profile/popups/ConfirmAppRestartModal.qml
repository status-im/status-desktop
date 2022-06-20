import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

// TODO: replace with StatusModal
ModalPopup {
    height: Style.dp(237)
    width: Style.dp(400)

    property Popup parentPopup

    title: qsTr("Application Restart")

    StyledText {
        text: qsTr("Please restart the application to apply the changes.")
        font.pixelSize: Style.current.primaryTextFontSize
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
            type: StatusBaseButton.Type.Danger
            text: qsTr("Restart")
            anchors.bottom: parent.bottom
            onClicked: Qt.quit()
        }
    }
}
