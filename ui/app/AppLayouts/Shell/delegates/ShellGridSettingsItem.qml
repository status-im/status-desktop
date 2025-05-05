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
    subtitle: qsTr("Settings")
    color: Qt.lighter(Theme.palette.primaryColor1, 1.7)

    iconLoaderComponent: StatusRoundIcon {
        asset.name: root.icon.name
        asset.color: Theme.palette.primaryColor1
        asset.bgWidth: width
        asset.bgHeight: height
        asset.bgColor: Qt.lighter(asset.color, 1.8)

        border.width: 2
        border.color: hovered ? "#222833" : "#161c27"
    }

    bottomRowComponent: StatusBetaTag {
        visible: root.isExperimental
    }
}
