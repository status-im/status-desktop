import QtQuick 2.15
import QtQuick.Controls 2.15

import utils 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0
import shared.popups 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    title: qsTr("Enter recovery phrase")
    height: 200
    signal openModalClicked()

    StyledText {
        text: qsTr("Do you want to add another existing key?")
        anchors.left: parent.left
        anchors.top: parent.top
    }

    footer: StatusButton {
        anchors.bottom: parent.bottom
        anchors.topMargin: Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        text: qsTr("Add another existing key")

        onClicked : {
            openModalClicked()
            popup.close()
        }
    }
}
