import QtCore
import QtQuick
import QtQuick.Controls

import Models
import Storybook

import shared.popups

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    property var dialog

    function createAndOpenDialog() {
        dialog = dlgComponent.createObject(popupBg)
        dialog.open()
    }

    Component.onCompleted: createAndOpenDialog()

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            id: popupBg
            anchors.fill: parent

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: createAndOpenDialog()
            }
        }

        Component {
            id: dlgComponent
                EnableMessageBackupPopup {
                anchors.centerIn: parent
                visible: true
                onAccepted: logs.logEvent("EnableMessageBackupPopup::onAccepted")
                onClosed: logs.logEvent("EnableMessageBackupPopup::onClosed")

                destroyOnClose: false
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Popups
// status: good
