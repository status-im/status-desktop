import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1

import AppLayouts.Profile.views 1.0
import mainui 1.0
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
        id: emptyModel
    }

    ListModel {
        id: communitiesModel
        Component.onCompleted:
            append([{
                        id: "0x0001",
                        name: "Test community",
                        description: "Lorem ipsum dolor sit amet",
                        introMessage: "Welcome to ze club",
                        outroMessage: "Sad to see you go",
                        joined: true,
                        spectated: false,
                        memberRole: Constants.memberRole.owner,
                        image: ModelsData.icons.dribble,
                        color: "yellow",
                        muted: false,
                        members: [ { pubKey: "0xdeadbeef" } ]
                    },
                    {
                        id: "0x0002",
                        name: "Test community 2",
                        description: "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat.",
                        introMessage: "Welcome to ze club",
                        outroMessage: "Sad to see you go",
                        joined: true,
                        spectated: false,
                        memberRole: Constants.memberRole.none,
                        image: ModelsData.icons.status,
                        color: "peach",
                        muted: false,
                        members: [ { pubKey: "0xdeadbeef" }, { pubKey: "0xdeadbeef" }, { pubKey: "0xdeadbeef" } ]
                    },
                    {
                        id: "0x0003",
                        name: "Free to join",
                        introMessage: "Welcome to ze club",
                        description: "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat.",
                        outroMessage: "Sad to see you go",
                        joined: false,
                        spectated: true,
                        memberRole: Constants.memberRole.none,
                        image: "",
                        color: "red",
                        muted: false,
                        members: [ { pubKey: "0xdeadbeef" } ]
                    },
                    {
                        id: "0x0004",
                        name: "Muted community",
                        introMessage: "Welcome to ze club",
                        description: "Lorem ipsum dolor sit amet",
                        outroMessage: "Sad to see you go",
                        joined: true,
                        spectated: false,
                        memberRole: Constants.memberRole.none,
                        image: "",
                        color: "whitesmoke",
                        muted: true,
                        members: []
                    },
                    {
                        id: "0x0005",
                        name: "Test community 4",
                        description: "Lorem ipsum dolor sit amet",
                        introMessage: "Welcome to ze club",
                        outroMessage: "Sad to see you go",
                        joined: true,
                        spectated: false,
                        memberRole: Constants.memberRole.admin,
                        image: ModelsData.icons.spotify,
                        color: "green",
                        muted: false,
                        members: [{ pubKey: "0xdeadbeef" }, { pubKey: "0xdeadbeef" }, { pubKey: "0xdeadbeef" }, { pubKey: "0xdeadbeef" }]
                    },
                    {
                        id: "0x0006",
                        name: "Pending request here",
                        description: "Lorem ipsum dolor sit amet",
                        introMessage: "Welcome to ze club",
                        outroMessage: "Sad to see you go",
                        joined: false,
                        spectated: true,
                        memberRole: Constants.memberRole.none,
                        image: ModelsData.icons.spotify,
                        color: "pink",
                        muted: false,
                        members: [{ pubKey: "0xdeadbeef" }]
                    }
                   ])
    }

    CommunitiesView {
        SplitView.fillWidth: true
        SplitView.preferredHeight: 400

        contentWidth: 664
        profileSectionStore: QtObject {
            property var communitiesProfileModule: QtObject {
                function setCommunityMuted(communityId, mutedType) {
                    logs.logEvent("profileSectionStore::communitiesProfileModule::setCommunityMuted", ["communityId", "mutedType"], arguments)
                }
                function leaveCommunity(communityId) {
                    logs.logEvent("profileSectionStore::communitiesProfileModule::leaveCommunity", ["communityId"], arguments)
                }
            }
            property var communitiesList: ctrlEmptyView.checked ? emptyModel : communitiesModel
        }
        rootStore: QtObject {
            function isCommunityRequestPending(communityId) {
                return communityId === "0x0006"
            }
            function cancelPendingRequest(communityId) {
                logs.logEvent("rootStore::cancelPendingRequest", ["communityId"], arguments)
            }
            function setActiveCommunity(communityId) {
                logs.logEvent("rootStore::setActiveCommunity", ["communityId"], arguments)
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        Switch {
            id: ctrlEmptyView
            text: "No communities"
        }
    }
}
