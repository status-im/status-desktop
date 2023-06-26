import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.popups 1.0

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
            channelName: "#vip"
            joinCommunity: false
        }
    }
}


