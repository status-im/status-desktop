import QtQuick 2.15

import StatusQ.Core 0.1

import utils 1.0

StatusBaseText {
    id: root

    required property bool unfurled
    required property bool empty
    required property string url
    required property int previewType
    required property var standardPreview
    required property var standardPreviewThumbnail
    required property var statusContactPreview
    required property var statusContactPreviewThumbnail
    required property var statusCommunityPreview
    required property var statusCommunityPreviewIcon
    required property var statusCommunityPreviewBanner
    required property var statusCommunityChannelPreview
    required property var statusCommunityChannelCommunityPreview
    required property var statusCommunityChannelCommunityPreviewIcon
    required property var statusCommunityChannelCommunityPreviewBanner

    wrapMode: Text.WordWrap

    function getThumbnailString(thumbnail) {
        const thumbnailWidth = thumbnail ? thumbnail.width : ""
        const thumbnailHeight = thumbnail ? thumbnail.height : ""
        const thumbnailUrl = thumbnail ? thumbnail.url : ""
        const thumbnailDataUri = thumbnail ? thumbnail.dataUri : ""
        return `(${thumbnailWidth}*${thumbnailHeight}, url: ${thumbnailUrl.length} symbols, data: ${thumbnailDataUri.length} symbols)`
    }

    function getStandardPreviewString(preview, thumbnail) {
        const hostname = standardPreview ? standardPreview.hostname : ""
        const title = standardPreview ? standardPreview.title : ""
        const description = standardPreview ? standardPreview.description : ""
        const thumbnailInfo = getThumbnailString(thumbnail)
        return `(hostname: ${hostname}): ${title}\n` +
                `description: ${description}\n` +
                `thumbnail: ${thumbnailInfo}`
    }

    function getStatusContactPreviewString(preview, thumbnail) {
        const publicKey = preview ? preview.publicKey : ""
        const displayName = preview ? preview.displayName : ""
        const description = preview ? preview.description : ""
        const thumbnailInfo = getThumbnailString(thumbnail)
        return `(publicKey: ${publicKey})\n` +
                `displayName: ${displayName}\n` +
                `description: ${description}\n` +
                `icon: ${thumbnailInfo}`
    }

    function getStatusCommunityPreviewString(preview, icon, banner) {
        const communityId = preview ? preview.communityId : ""
        const displayName = preview ? preview.displayName : ""
        const description = preview ? preview.description : ""
        const membersCount = preview ? preview.membersCount : ""
        const color = preview ? preview.color : ""
        const iconInfo = getThumbnailString(icon)
        const bannerInfo = getThumbnailString(banner)
        return `communityId: ${communityId}\n` +
               `displayName: ${displayName}\n` +
               `description: ${description}\n` +
               `membersCount: ${membersCount}\n` +
               `color: ${color}\n` +
               `icon: ${iconInfo}\n` +
               `banner: ${bannerInfo}`
    }

    function getStatusChannelPreviewString(channel, community, communityIcon, communityBanner) {
        const channelUuid = channel ? channel.channelUuid : ""
        const displayName = channel ? channel.displayName : ""
        const description = channel ? channel.description : ""
        const emoji = channel ? channel.emoji : ""
        const color = channel ? channel.color : ""
        const communityInfo = getStatusCommunityPreviewString(community, communityIcon, communityBanner)
        return `channelUuid: ${channelUuid}\n` +
               `displayName: ${displayName}\n` +
               `description: ${description}\n` +
               `emoji: ${emoji}\n` +
               `color: ${color}\n` +
               `- communityInfo: \n${communityInfo}`
    }

    function linkPreviewTypeString(t) {
        switch (t) {
        case Constants.LinkPreviewType.NoPreview:
            return "NoPreview"
        case Constants.LinkPreviewType.Standard:
            return "Standard"
        case Constants.LinkPreviewType.StatusContact:
            return "StatusContact"
        case Constants.LinkPreviewType.StatusCommunity:
            return "StatusCommunity"
        case Constants.LinkPreviewType.StatusCommunityChannel:
            return "StatusCommunityChannel"
        }
        return "???"
    }

    text: {
        const stateEmoji = unfurled ? (empty ? '❌' : '✅') : '👀'
        let previewString = ""

        switch (previewType) {
        case Constants.LinkPreviewType.Standard:
            previewString = getStandardPreviewString(standardPreview,
                                                     standardPreviewThumbnail)
            break
        case Constants.LinkPreviewType.StatusContact:
            previewString = getStatusContactPreviewString(statusContactPreview,
                                                          statusContactPreviewThumbnail)
            break
        case Constants.LinkPreviewType.StatusCommunity:
            previewString = getStatusCommunityPreviewString(statusCommunityPreview,
                                                            statusCommunityPreviewIcon,
                                                            statusCommunityPreviewBanner)
            break
        case Constants.LinkPreviewType.StatusCommunityChannel:
            previewString = getStatusChannelPreviewString(statusCommunityChannelPreview,
                                                          statusCommunityChannelCommunityPreview,
                                                          statusCommunityChannelCommunityPreviewIcon,
                                                          statusCommunityChannelCommunityPreviewBanner)
            break
        }

        return `${stateEmoji} ${linkPreviewTypeString(previewType)} ${url}\n${previewString}`
    }
}
