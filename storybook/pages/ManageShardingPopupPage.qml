import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import AppLayouts.Communities.popups 1.0

SplitView {
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

            onClicked: dialog.open()
        }

        ManageShardingPopup {
            id: dialog

            anchors.centerIn: parent
            visible: true
            modal: false
            closePolicy: Popup.NoAutoClose

            communityName: "Foobar"

            shardIndex: 33
            pubsubTopic: '{"pubsubTopic":"/waku/2/rs/16/%1", "publicKey":"%2"}'.arg(shardIndex).arg("0xdeadbeef")

            onDisableShardingRequested: logs.logEvent("ManageShardingPopup::disableShardingRequested")
            onEditShardIndexRequested: logs.logEvent("ManageShardingPopup::editShardIndexRequested")
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Popups

// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=37242-186255&mode=design&t=tn8u8VaIZDDrCXN4-0
