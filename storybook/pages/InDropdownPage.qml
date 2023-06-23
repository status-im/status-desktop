import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.controls 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    Pane {
        id: pane

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        InDropdown {
            parent: pane
            anchors.centerIn: parent

            closePolicy: Popup.NoAutoClose

            allowChoosingEntireCommunity: allowChoosingEntireCommunityCheckBox.checked
            showAddChannelButton: showAddChannelButtonCheckBox.checked

            communityName: "Socks"
            communityImage: ModelsData.icons.socks
            communityColor: "red"

            model: ChannelsModel {}

            onAddChannelClicked: {
                logs.logEvent("InDropdown::addChannelClicked")
            }

            onCommunitySelected: {
                logs.logEvent("InDropdown::communitySelected")
            }

            onChannelsSelected: {
                logs.logEvent("InDropdown::channelSelected", ["channels"], arguments)
            }

            Component.onCompleted: open()
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            CheckBox {
                id: allowChoosingEntireCommunityCheckBox

                text: "Allow choosing entire community"
            }
            CheckBox {
                id: showAddChannelButtonCheckBox

                text: "Show \"Add channel\" button"
            }
        }
    }
}
