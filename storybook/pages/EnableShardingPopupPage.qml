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

        EnableShardingPopup {
            id: dialog

            anchors.centerIn: parent
            visible: true
            modal: false
            closePolicy: Popup.NoAutoClose

            communityName: "Foobar"
            shardIndex: -1
            pubsubTopic: '{"pubsubTopic":"/waku/2/rs/16/%1", "publicKey":"0xdeadbeef"}'.arg(dialog.shardIndex)

            onShardIndexChanged: {
                shardingInProgress = true
                logs.logEvent("enableSharding", ["shardIndex"], arguments)
                shardSetterDelayer.start()
            }
        }

        Timer {
            id: shardSetterDelayer
            interval: 1000
            onTriggered: {
                dialog.shardingInProgress = false
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

// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?node-id=37239%3A184324&mode=dev
