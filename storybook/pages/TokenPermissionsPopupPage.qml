import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook
import Models

import AppLayouts.Communities.popups

SplitView {
    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

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

            TokenPermissionsPopup {
                id: dialog

                anchors.centerIn: parent
                channelName: editor.channelName
                viewOnlyHoldingsModel: editor.viewOnlyHoldingsModel
                viewAndPostHoldingsModel: editor.viewAndPostHoldingsModel
                moderateHoldingsModel: editor.moderateHoldingsModel

                assetsModel: AssetsModel {}
                collectiblesModel: CollectiblesModel {}
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        JoinCommunityPermissionsEditor {
            id: editor

            isOnlyChannelPanelEditor: true
            channelName: "vip"
            joinCommunity: false
        }
    }
}

// category: Popups
