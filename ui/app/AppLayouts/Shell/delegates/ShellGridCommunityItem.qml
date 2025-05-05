import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.controls 1.0

ShellGridItem {
    id: root

    property int membersCount
    property int activeMembersCount

    sectionType: Constants.appSection.community
    subtitle: qsTr("Community")

    bottomRowComponent: Loader {
        sourceComponent: membersComponent
        // TODO more community tags (tokens/pending/kicked)
    }

    iconLoaderComponent: StatusRoundedImage {
        image.source: root.icon.source
        border.width: 2
        border.color: hovered ? "#222833" : "#161c27"
    }

    component MembersTag: InformationTag {
        spacing: 4
        horizontalPadding: Theme.smallPadding
        verticalPadding: 4
        bgRadius: 20
        bgBorderColor: Qt.rgba(1, 1, 1, 0.1)
        tagPrimaryLabel.color: Theme.palette.white
        tagPrimaryLabel.font.weight: Font.Medium
        asset.color: Theme.palette.baseColor1
    }

    Component {
        id: membersComponent
        MembersTag {
            asset.name: root.activeMembersCount ? "tiny/flash" : "tiny/members"
            tagPrimaryLabel.text: numberFormat(root.activeMembersCount ? root.activeMembersCount : root.membersCount)
        }
    }
}
