import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.popups 1.0

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

// category: Popups

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A482182
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A482231
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A482280
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A481935
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A482006
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=2934%3A482016
