import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import AppLayouts.Communities.panels 1.0

import utils 1.0

import Models 1.0
import SortFilterProxyModel 0.2
import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical
    Logs { id: logs }

    MembersTabPanel {
        id: membersTabPanelPage
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        placeholderText: "Placeholder text"
        model: usersModelWithMembershipState
        panelType: viewStateSelector.currentValue

        onKickUserClicked: {
            logs.logEvent("MembersTabPanel::onKickUserClicked")
        }

        onBanUserClicked: {
            logs.logEvent("MembersTabPanel::onBanUserClicked")
        }

        onUnbanUserClicked: {
            logs.logEvent("MembersTabPanel::onUnbanUserClicked")
        }

        onAcceptRequestToJoin: {
            logs.logEvent("MembersTabPanel::onAcceptRequestToJoin")
        }

        onDeclineRequestToJoin: {
            logs.logEvent("MembersTabPanel::onDeclineRequestToJoin")
        }
    }

    UsersModel {
        id: usersModel
    }


    SortFilterProxyModel {
        id: usersModelWithMembershipState
        readonly property var membershipStatePerView: [
            [Constants.CommunityMembershipRequestState.Accepted , Constants.CommunityMembershipRequestState.BannedPending, Constants.CommunityMembershipRequestState.KickedPending],
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
