import QtQuick 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

StatusInput {
    id: root

    property int linkType
    property string icon

    leftPadding: 18 // by design

    placeholderText: {
        if (linkType === Constants.socialLinkType.twitter) return qsTr("Twitter Handle")
        if (linkType === Constants.socialLinkType.personalSite) return qsTr("Personal Site")
        if (linkType === Constants.socialLinkType.github) return qsTr("Github")
        if (linkType === Constants.socialLinkType.youtube) return qsTr("YouTube Channel")
        if (linkType === Constants.socialLinkType.discord) return qsTr("Discord Handle")
        if (linkType === Constants.socialLinkType.telegram) return qsTr("Telegram Handle")
        return ""
    }
    input.asset {
        name: root.icon
        width: 20
        height: 20
    }
}
