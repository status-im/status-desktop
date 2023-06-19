import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import mainui 1.0
import AppLayouts.Profile.panels 1.0

import utils 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Popups {
        popupParent: root
        rootStore: QtObject {}
    }

    ListModel {
        id: communitiesModel
        Component.onCompleted:
            append([{
                        id: "0x0001",
                        name: "Test community",
                        joined: true,
                        memberRole: Constants.memberRole.owner,
                        image: ModelsData.icons.dribble,
                        color: "yellow"
                    },
                    {
                        id: "0x0002",
                        name: "Test community 2",
                        joined: true,
                        memberRole: Constants.memberRole.none,
                        image: ModelsData.collectibles.custom,
                        color: "peach"
                    },
                    {
                        id: "0x0003",
                        name: "Test community invisible",
                        joined: false,
                        memberRole: Constants.memberRole.none,
                        image: "",
                        color: "red"
                    },
                    {
                        id: "0x0004",
                        name: "Test community 3",
                        joined: true,
                        memberRole: Constants.memberRole.none,
                        image: "",
                        color: "whitesmoke"
                    },
                    {
                        id: "0x0005",
                        name: "Test community 4",
                        joined: true,
                        memberRole: Constants.memberRole.admin,
                        image: ModelsData.icons.spotify,
                        color: "green"
                    },
                   ])
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500
        ProfileShowcaseCommunitiesPanel {
            id: showcasePanel
            width: 500
            baseModel: communitiesModel
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        Button {
            text: "Reset (clear settings)"
            onClicked: showcasePanel.settings.reset()
        }
    }
}
