pragma Singleton

import QtQml

import StatusQ.Core.Theme

QtObject {

    readonly property int defaultDelegateHeight: 76

    function displayName(nickName, ensName, displayName, aliasName)
    {
        return nickName || ensName || displayName || aliasName
    }

    // social links utils
    function addSocialLinkPrefix(link, type) {
        const prefix = Constants.socialLinkPrefixesByType[type]
        if (link.startsWith(prefix))
            return link
        return prefix + link
    }

    function stripSocialLinkPrefix(link, type) {
        return link.replace(Constants.socialLinkPrefixesByType[type], "")
    }

    function linkTypeToText(linkType) {
        if (linkType === Constants.socialLinkType.twitter) return qsTr("X (Twitter)")
        if (linkType === Constants.socialLinkType.personalSite) return qsTr("Personal site")
        if (linkType === Constants.socialLinkType.github) return qsTr("Github")
        if (linkType === Constants.socialLinkType.youtube) return qsTr("YouTube channel")
        if (linkType === Constants.socialLinkType.discord) return qsTr("Discord handle")
        if (linkType === Constants.socialLinkType.telegram) return qsTr("Telegram handle")
        return "" // "custom" link type allows for user defined text
    }

    function linkTypeToShortText(linkType) {
        if (linkType === Constants.socialLinkType.twitter) return qsTr("X (Twitter)")
        if (linkType === Constants.socialLinkType.personalSite) return qsTr("Personal")
        if (linkType === Constants.socialLinkType.github) return qsTr("Github")
        if (linkType === Constants.socialLinkType.youtube) return qsTr("YouTube")
        if (linkType === Constants.socialLinkType.discord) return qsTr("Discord")
        if (linkType === Constants.socialLinkType.telegram) return qsTr("Telegram")
        return "" // "custom" link type allows for user defined text
    }

    function linkTypeColor(linkType) {
        if (linkType === Constants.socialLinkType.twitter) return "#000000"
        if (linkType === Constants.socialLinkType.github) return "#000000"
        if (linkType === Constants.socialLinkType.youtube) return "#FF3000"
        if (linkType === Constants.socialLinkType.discord) return "#7289DA"
        if (linkType === Constants.socialLinkType.telegram) return "#0088CC"
        return Theme.palette.primaryColor1
    }

    function linkTypeBgColor(linkType) {
        return Theme.palette.getColor(linkTypeColor(linkType), 0.1)
    }

    function linkTypeToDescription(linkType) {
        if (linkType === Constants.socialLinkType.twitter) return qsTr("Twitter username")
        if (linkType === Constants.socialLinkType.personalSite) return qsTr("Personal site")
        if (linkType === Constants.socialLinkType.github) return qsTr("Github")
        if (linkType === Constants.socialLinkType.youtube) return qsTr("YouTube channel")
        if (linkType === Constants.socialLinkType.discord) return qsTr("Discord handle")
        if (linkType === Constants.socialLinkType.telegram) return qsTr("Telegram handle")
        return ""
    }

    function linkTextToType(text) {
        if (text === "__twitter") return Constants.socialLinkType.twitter
        if (text === "__personal_site") return Constants.socialLinkType.personalSite
        if (text === "__github") return Constants.socialLinkType.github
        if (text === "__youtube") return Constants.socialLinkType.youtube
        if (text === "__discord") return Constants.socialLinkType.discord
        if (text === "__telegram") return Constants.socialLinkType.telegram
        return Constants.socialLinkType.custom
    }

    function linkTypeToIcon(linkType) {
        if (linkType === Constants.socialLinkType.twitter) return "xtwitter"
        if (linkType === Constants.socialLinkType.personalSite) return "language"
        if (linkType === Constants.socialLinkType.github) return "github"
        if (linkType === Constants.socialLinkType.youtube) return "youtube"
        if (linkType === Constants.socialLinkType.discord) return "discord"
        if (linkType === Constants.socialLinkType.telegram) return "telegram"
        return "link"
    }

    // showcase
    function visibilityIcon(showcaseVisibility) {
        switch (showcaseVisibility) {
        case Constants.ShowcaseVisibility.IdVerifiedContacts:
            return "checkmark-circle"
        case Constants.ShowcaseVisibility.Contacts:
            return "profile"
        case Constants.ShowcaseVisibility.Everyone:
            return "language"
        case Constants.ShowcaseVisibility.NoOne:
        default:
            return "hide"
        }
    }

    // Member role names:
    function getMemberRoleText(memberRole) {
        switch(memberRole) {
        case Constants.memberRole.owner:
            return qsTr("Owner")
        case Constants.memberRole.admin:
            return qsTr("Admin")
        case Constants.memberRole.tokenMaster:
            return qsTr("TokenMaster")
        }
        return qsTr("Member")
    }
}
