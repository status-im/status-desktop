import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Communities.panels 1.0

import Models 1.0
import SortFilterProxyModel 0.2

SplitView {
    id: root

    MembersTabPanel {
        id: membersTabPanelPage
        placeholderText: "Placeholder text"
        model: usersModelWithMembershipState
        panelType: MembersTabPanel.TabType.PendingRequests
    }

    UsersModel {
        id: usersModel
    }

    SortFilterProxyModel {
        id: usersModelWithMembershipState
        readonly property var acceptedStates: [0, 3, 4]
        sourceModel: usersModel

        proxyRoles: [
            ExpressionRole {
                name: "membershipRequestState"
                expression: usersModelWithMembershipState.acceptedStates[model.index % (usersModelWithMembershipState.acceptedStates.length)]
            },
            ExpressionRole {
                name: "requestToJoinLoading"
                expression: false
            }
        ]
    }
}
