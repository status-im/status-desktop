import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils

import mainui 1.0
import AppLayouts.Profile.panels 1.0
import shared.stores 1.0

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
        communityTokensStore: CommunityTokensStore {}
    }

    ListModel {
        id: communitiesModel

        Component.onCompleted:
            append([{
                        id: "0x0001",
                        name: "Test community",
                        joined: true,
                        memberRole: Constants.memberRole.owner,
                        isControlNode: true,
                        image: ModelsData.icons.dribble,
                        color: "yellow"
                    },
                    {
                        id: "0x0002",
                        name: "Test community 2",
                        joined: true,
                        memberRole: Constants.memberRole.none,
                        isControlNode: false,
                        image: ModelsData.collectibles.custom,
                        color: "peach"
                    },
                    {
                        id: "0x0003",
                        name: "Test community invisible",
                        joined: false,
                        memberRole: Constants.memberRole.none,
                        isControlNode: false,
                        image: "",
                        color: "red"
                    },
                    {
                        id: "0x0004",
                        name: "Test community 3",
                        joined: true,
                        memberRole: Constants.memberRole.none,
                        isControlNode: false,
                        image: "",
                        color: "whitesmoke"
                    },
                    {
                        id: "0x0005",
                        name: "Test community 4",
                        joined: true,
                        memberRole: Constants.memberRole.admin,
                        isControlNode: false,
                        image: ModelsData.icons.spotify,
                        color: "green"
                    },
                   ])
    }

    ListModel {
        id: inShowcaseCommunitiesModel

        signal baseModelFilterConditionsMayHaveChanged()

        function setVisibilityByIndex(index, visibility) {
            if (visibility === Constants.ShowcaseVisibility.NoOne) {
                remove(index)
            } else {
                 get(index).showcaseVisibility = visibility
            }
        }

        function setVisibility(id, visibility) {
            for (let i = 0; i < count; ++i) {
                if (get(i).id === id) {
                    setVisibilityByIndex(i, visibility)
                }
            }
        }

        function hasItemInShowcase(id) {
            for (let i = 0; i < count; ++i) {
                if (get(i).id === id) {
                    return true
                }
            }
            return false
        }

        function upsertItemJson(item) {
            append(JSON.parse(item))
        }
    }

    StatusScrollView { // wrapped in a ScrollView on purpose; to simulate SettingsContentBase.qml
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500
        ProfileShowcaseCommunitiesPanel {
            id: showcasePanel
            width: 500
            baseModel: communitiesModel
            showcaseModel: inShowcaseCommunitiesModel
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

// category: Panels

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14580-339532&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14729-231402&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14609-236656&t=RkXAEv3G6mp3EUvl-0
