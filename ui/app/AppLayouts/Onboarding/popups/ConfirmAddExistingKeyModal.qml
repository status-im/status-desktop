import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/panels"
import "../../../../shared/status"

// TODO: replace with StatusModal
ModalPopup {
    property var onOpenModalClick: function () {}
    id: popup
    //% "Enter seed phrase"
    title: qsTrId("enter-seed-phrase")
    height: 200

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
            onOpenModalClick()
            popup.close()
        }
    }
}
