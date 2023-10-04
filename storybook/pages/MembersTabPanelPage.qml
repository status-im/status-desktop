import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import AppLayouts.Communities.panels 1.0

import utils 1.0

import Models 1.0
import SortFilterProxyModel 0.2
import Storybook 1.0

import StatusQ.Core.Utils 0.1 as SQUtils

SplitView {
    id: root

    orientation: Qt.Vertical
    Logs { id: logs }

    // Utils.globalUtilsInst mock
    QtObject {
        function getEmojiHashAsJson(publicKey) {
            return JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
        }

        function getColorId(publicKey) {
            return SQUtils.ModelUtils.getByKey(usersModel, "pubKey", publicKey, "colorId")
        }

        function getCompressedPk(publicKey) { return "zx3sh" + publicKey }

        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }

        function isCompressedPubKey(publicKey) { return true }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
        }
        Component.onDestruction: {
            Utils.globalUtilsInst = {}
        }
    }

    // Global.userProfile mock
    QtObject {
        readonly property string pubKey: "0x043a7ed0e8d1012cf04" // Mike from UsersModel
        Component.onCompleted: {
            Global.userProfile = this
        }
        Component.onDestruction: {
            Utils.userProfile = {}
        }
    }

    MembersTabPanel {
        id: membersTabPanelPage
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        placeholderText: "Search users"
        model: usersModelWithMembershipState
        panelType: viewStateSelector.currentValue

        onKickUserClicked: {
            logs.logEvent("MembersTabPanel::onKickUserClicked", ["id", "name"], arguments)
        }

        onBanUserClicked: {
            logs.logEvent("MembersTabPanel::onBanUserClicked", ["id", "name"], arguments)
        }

        onUnbanUserClicked: {
            logs.logEvent("MembersTabPanel::onUnbanUserClicked", ["id"], arguments)
        }

        onAcceptRequestToJoin: {
            logs.logEvent("MembersTabPanel::onAcceptRequestToJoin", ["id"], arguments)
        }

        onDeclineRequestToJoin: {
            logs.logEvent("MembersTabPanel::onDeclineRequestToJoin", ["id"], arguments)
        }
    }

    UsersModel {
        id: usersModel
    }

    SortFilterProxyModel {
        id: usersModelWithMembershipState
        readonly property var membershipStatePerView: [
            [Constants.CommunityMembershipRequestState.Accepted , Constants.CommunityMembershipRequestState.BannedPending, Constants.CommunityMembershipRequestState.UnbannedPending, Constants.CommunityMembershipRequestState.KickedPending],
            [Constants.CommunityMembershipRequestState.Banned],
            [Constants.CommunityMembershipRequestState.Pending, Constants.CommunityMembershipRequestState.AcceptedPending, Constants.CommunityMembershipRequestState.RejectedPending],
            [Constants.CommunityMembershipRequestState.Rejected]
        ]

        sourceModel: usersModel
        sortRole: membersTabPanelPage.panelType

        proxyRoles: [
            ExpressionRole {
                name: "membershipRequestState"
                expression: {
                    var memberStates = usersModelWithMembershipState.membershipStatePerView[membersTabPanelPage.panelType]
                    return memberStates[model.index % (memberStates.length)]
                }
            },
            ExpressionRole {
                name: "requestToJoinLoading"
                expression: false
            }
        ]
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 320

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            Label {
                text: "View state"
            }

            ComboBox {
                id: viewStateSelector
                textRole: "text"
                valueRole: "value"
                model: ListModel {
                     id: model
                     ListElement { text: "All members"; value: MembersTabPanel.TabType.AllMembers }
                     ListElement { text: "Banned Members"; value: MembersTabPanel.TabType.BannedMembers }
                     ListElement { text: "Pending Members"; value: MembersTabPanel.TabType.PendingRequests }
                     ListElement { text: "Declined Members"; value: MembersTabPanel.TabType.DeclinedRequests }
                 }
            }
        }
    }

    Settings {
        property alias membersTabPanelSelection: viewStateSelector.currentIndex
    }
}

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba⎜Desktop?type=design&node-id=35909-605774&mode=design&t=KfrAekLfW5mTy68x-0
