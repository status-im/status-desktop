import QtQuick
import QtQuick.Controls

import AppLayouts.Profile.popups.networkSettings

import Storybook

import StatusQ.Core

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

    ActiveNetworkLimitPopup {
        id: popup
        anchors.centerIn: parent
        width: 521
        modal: false
        visible: true
        destroyOnClose: false
    }
}

// category: Popups

// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=25465-98646&m=dev
