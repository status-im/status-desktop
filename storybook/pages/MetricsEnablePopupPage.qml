import QtQuick 2.15
import QtQuick.Controls 2.15

import shared.popups 1.0
import utils 1.0

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

    MetricsEnablePopup {
        id: popup
        anchors.centerIn: parent
        modal: false
        visible: true
        placement: Constants.metricsEnablePlacement.unknown
    }
}

// category: Popups

// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=24721-503547&t=a7IsC44aG7YQuInQ-0
