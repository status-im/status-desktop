import QtQuick 2.15
import QtQuick.Controls 2.15

import shared.popups 1.0

import Storybook 1.0

SplitView {
    orientation: Qt.Vertical

    Item {

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: popup.open()
        }
    }

    UserAgreementPopup {
        id: popup
        anchors.centerIn: parent
        modal: false
        visible: true
    }
}
