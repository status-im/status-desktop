import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

ShellGridItem {
    id: root

    property int membersCount
    property int activeMembersCount
    property bool isExperimental

    sectionType: Constants.appSection.profile
    color: Theme.palette.primaryColor2

    iconLoaderComponent: StatusRoundIcon {
        asset.name: root.icon.name
        asset.bgWidth: width
        asset.bgHeight: height
    }

    bottomRowComponent: StatusBetaTag {
        visible: root.isExperimental
    }
}
