pragma Singleton

import QtQml 2.14

import StatusQ.Core.Theme 0.1

QtObject {
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
        if (linkType === Constants.socialLinkType.twitter) return qsTr("Twitter")
        if (linkType === Constants.socialLinkType.personalSite) return qsTr("Personal site")
        if (linkType === Constants.socialLinkType.github) return qsTr("Github")
        if (linkType === Constants.socialLinkType.youtube) return qsTr("YouTube channel")
        if (linkType === Constants.socialLinkType.discord) return qsTr("Discord handle")
        if (linkType === Constants.socialLinkType.telegram) return qsTr("Telegram handle")
        return "" // "custom" link type allows for user defined text
    }

    function linkTypeColor(linkType) {
        if (linkType === Constants.socialLinkType.twitter) return "#03A9F4"
        if (linkType === Constants.socialLinkType.github) return "#000000"
        if (linkType === Constants.socialLinkType.youtube) return "#FF3000"
        if (linkType === Constants.socialLinkType.discord) return "#7289DA"
        if (linkType === Constants.socialLinkType.telegram) return "#0088CC"
        return Theme.palette.primaryColor1
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
}
