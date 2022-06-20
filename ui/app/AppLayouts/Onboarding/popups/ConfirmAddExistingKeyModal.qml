import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1

import shared.panels 1.0
import shared.popups 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    //% "Enter seed phrase"
    title: qsTrId("enter-seed-phrase")
    height: Style.dp(200)
    signal openModalClicked()

    StyledText {
        text: "Do you want to add another existing key?"
        anchors.left: parent.left
        anchors.top: parent.top
    }

    footer: StatusButton {
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        text: "Add another existing key"

        onClicked : {
            openModalClicked()
            popup.close()
        }
    }
}
