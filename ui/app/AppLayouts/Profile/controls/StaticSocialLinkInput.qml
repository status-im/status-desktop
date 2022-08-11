import QtQuick 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

StatusInput {
    id: root

    property int linkType

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
        name: {
            if (linkType === Constants.socialLinkType.twitter) return "twitter"
            if (linkType === Constants.socialLinkType.personalSite) return "language"
            if (linkType === Constants.socialLinkType.github) return "github"
            if (linkType === Constants.socialLinkType.youtube) return "youtube"
            if (linkType === Constants.socialLinkType.discord) return "discord"
            if (linkType === Constants.socialLinkType.telegram) return "telegram"
            return ""
        }
        width: 20
        height: 20
    }
}
