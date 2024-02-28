import QtQuick 2.15

import utils 1.0

import AppLayouts.Profile.controls 1.0

ProfileShowcasePanel {
    id: root

    emptyInShowcasePlaceholderText: qsTr("Drag communities here to display in showcase")
    emptyHiddenPlaceholderText: qsTr("Communities here will be hidden from your Profile")

    delegate: ProfileShowcasePanel.Delegate {
        title: model ? model.name : ""
        secondaryTitle: model && (model.memberRole === Constants.memberRole.owner ||
                                        model.memberRole === Constants.memberRole.admin ||
                                        model.memberRole === Constants.memberRole.tokenMaster) ? qsTr("Admin") : qsTr("Member")
        hasImage: model && !!model.image

        icon.name: model ? model.name : ""
        icon.source: model ? model.image : ""
        icon.color: model ? model.color : ""
    }
}
