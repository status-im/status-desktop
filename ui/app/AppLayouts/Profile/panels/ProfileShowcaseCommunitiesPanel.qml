import QtQuick

import StatusQ
import utils

import AppLayouts.Profile.controls

ProfileShowcasePanel {
    id: root

    emptyInShowcasePlaceholderText: qsTr("Drag communities here to display in showcase")
    emptyHiddenPlaceholderText: qsTr("Communities here will be hidden from your Profile")
    emptySearchPlaceholderText: qsTr("No communities matching search")
    searchPlaceholderText: qsTr("Search community name or role")
    delegate: ProfileShowcasePanelDelegate {
        title: model ? model.name : ""
        secondaryTitle: (model && model.memberRole) ? ProfileUtils.getMemberRoleText(model.memberRole) : qsTr("Member")
        hasImage: model && !!model.image

        icon.name: model ? model.name : ""
        icon.source: model ? model.image : ""
        icon.color: model ? model.color : ""
    }

    filter: FastExpressionFilter {
        readonly property string lowerCaseSearchText: root.searcherText.toLowerCase()

        function getMemberRole(memberRole) {
            return ProfileUtils.getMemberRoleText(memberRole)
        }

        expression: {
            lowerCaseSearchText
            return (name.toLowerCase().includes(lowerCaseSearchText) ||
                    getMemberRole(memberRole).toLowerCase().includes(lowerCaseSearchText))
        }
        expectedRoles: ["name", "memberRole"]
    }
}
