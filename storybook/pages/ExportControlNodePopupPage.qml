import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Communities.popups 1.0

import Storybook 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    Item {

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: popupComponent.createObject(parent)
        }
        Component.onCompleted: popupComponent.createObject(parent)
    }

    Component {
        id: popupComponent
        ExportControlNodePopup {
            id: popup
            anchors.centerIn: parent
            modal: false
            visible: true
            communityName: "Socks"
            privateKey: "0x0454f2231543ba02583e4c55e513a75092a4f2c86c04d0796b195e964656d6cd94b8237c64ef668eb0fe268387adc3fe699bce97190a631563c82b718c19cf1fb8"
            onDeletePrivateKey: logs.logEvent("ExportControlNodePopup::onDeletePrivateKey")
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText
    }
}
