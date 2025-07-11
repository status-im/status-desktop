import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Utils as CoreUtils

import AppLayouts.Profile.panels
import AppLayouts.Profile.controls
import shared.stores

import utils

import Storybook
import Models

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    ListModel {
        id: hiddenModelItem
        Component.onCompleted:
            append([{
                        showcaseKey: "0x0006",
                        name: "Test community 6",
                        joined: true,
                        memberRole: Constants.memberRole.owner,
                        isControlNode: true,
                        image: ModelsData.icons.dribble,
                        color: "yellow",
                        showcaseVisibility: Constants.ShowcaseVisibility.NoOne
                    },
                    {
                        showcaseKey: "0x0007",
                        name: "Test community 7",
                        joined: true,
                        memberRole: Constants.memberRole.none,
                        isControlNode: false,
                        image: ModelsData.collectibles.custom,
                        color: "peach",
                        showcaseVisibility: Constants.ShowcaseVisibility.NoOne
                    },
                    {
                        showcaseKey: "0x0008",
                        name: "Test community 8",
                        joined: true,
                        memberRole: Constants.memberRole.none,
                        isControlNode: false,
                        image: "",
                        color: "whitesmoke",
                        showcaseVisibility: Constants.ShowcaseVisibility.NoOne
                    },
                    {
                        showcaseKey: "0x0009",
                        name: "Test community 9",
                        joined: true,
                        memberRole: Constants.memberRole.admin,
                        isControlNode: false,
                        image: ModelsData.icons.spotify,
                        color: "green",
                        showcaseVisibility: Constants.ShowcaseVisibility.NoOne
                    },
                   ])
    }

    ListModel {
        id: inShowcaseModelItem

        Component.onCompleted:
            append([{
                        id: "0x0001",
                        showcaseKey: "0x0001",
                        name: "Test community",
                        joined: true,
                        memberRole: Constants.memberRole.owner,
                        isControlNode: true,
                        image: ModelsData.icons.dribble,
                        color: "yellow",
                        showcaseVisibility: Constants.ShowcaseVisibility.Everyone
                    },
                    {
                        id: "0x0002",
                        showcaseKey: "0x0002",
                        name: "Test community 2",
                        joined: true,
                        memberRole: Constants.memberRole.none,
                        isControlNode: false,
                        image: ModelsData.collectibles.custom,
                        color: "peach",
                        showcaseVisibility: Constants.ShowcaseVisibility.Everyone
                    },
                    {
                        id: "0x0004",
                        showcaseKey: "0x0004",
                        name: "Test community 3",
                        joined: true,
                        memberRole: Constants.memberRole.none,
                        isControlNode: false,
                        image: "",
                        color: "whitesmoke",
                        showcaseVisibility: Constants.ShowcaseVisibility.Everyone
                    },
                    {
                        id: "0x0005",
                        showcaseKey: "0x0005",
                        name: "Test community 4",
                        joined: true,
                        memberRole: Constants.memberRole.admin,
                        isControlNode: false,
                        image: ModelsData.icons.spotify,
                        color: "green",
                        showcaseVisibility: Constants.ShowcaseVisibility.Everyone
                    },
                   ])
    }

    ListModel {
        id: emptyModel
    }

    ProfileShowcaseCommunitiesPanel {
        id: showcasePanel
        SplitView.fillWidth: true
        SplitView.preferredHeight: 500

        inShowcaseModel: emptyModelChecker.checked ? emptyModel : inShowcaseModelItem
        hiddenModel: emptyModelChecker.checked ? emptyModel : hiddenModelItem
        showcaseLimit: 5
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {
            Label {
                text: "ⓘ Showcase interaction implemented in ProfileShowcasePanelPage"
            }

            CheckBox {
                id: emptyModelChecker

                text: "Empty model"
                checked: false
            }
        }
    }

}

// category: Panels

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14580-339532&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14729-231402&t=RkXAEv3G6mp3EUvl-0
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=14609-236656&t=RkXAEv3G6mp3EUvl-0
