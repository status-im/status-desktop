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

    icon.color: Theme.palette.primaryColor1

    sectionType: Constants.appSection.profile
    color: Qt.lighter(icon.color, 1.7)

    iconLoaderComponent: StatusRoundIcon {
        asset.name: root.icon.name
        asset.color: root.icon.color
        asset.bgWidth: width
        asset.bgHeight: height
        asset.bgColor: Qt.lighter(asset.color, 1.8)
    }

    bottomRowComponent: StatusBetaTag {
        visible: root.isExperimental
    }
}
