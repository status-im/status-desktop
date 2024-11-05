import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import AppLayouts.Wallet.popups.simpleSend 1.0

SplitView {
    id: root

    orientation: Qt.Horizontal

    function launchPopup() {
        simpleSend.createObject(root)
    }

    PopupBackground {
        id: popupBg

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !simpleSend.visible

            onClicked: launchPopup()
        }

        Component.onCompleted: launchPopup()
    }

    Component {
        id: simpleSend
        SimpleSendModal {
            visible: true
            modal: false
            closePolicy: Popup.NoAutoClose
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 100

    }
}

// category: Popups
