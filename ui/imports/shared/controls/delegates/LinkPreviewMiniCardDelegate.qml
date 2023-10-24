import QtQuick 2.15

import utils 1.0
import shared.controls.chat 1.0

LinkPreviewMiniCard {
    id: root

    required property bool unfurled
    required property bool empty
    required property string url
    required property bool immutable
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


    title: ""
    domain: ""
    communityName: ""
    channelName: ""
    iconUrl: ""
    thumbnailImageUrl: ""
    type: LinkPreviewMiniCard.Type.Unknown
    previewState: !root.unfurled ? LinkPreviewMiniCard.State.Loading : root.unfurled && !root.empty ? LinkPreviewMiniCard.State.Loaded : LinkPreviewMiniCard.State.LoadingFailed


    StateGroup {
        states: [
            State {
                name: "standardPreview"
                when: root.previewType == Constants.Standard && root.previewState == LinkPreviewMiniCard.State.Loaded
                PropertyChanges {
                    target: root
                    title: root.standardPreview.title
                    domain: root.standardPreview.hostname   //TODO: Use domainName when available
                    iconUrl: ""                             //TODO: Add favicon when available
                    thumbnailImageUrl: (root.standardPreviewThumbnail.url || root.standardPreviewThumbnail.dataUri) ?? ""
                    type: root.standardPreview.linkType == Constants.StandardLinkPreviewType.Link ? LinkPreviewMiniCard.Type.Link : LinkPreviewMiniCard.Type.Image
                }
            },
            State {
                name: "statusContactPreview"
                when: root.previewType == Constants.StatusContact && root.previewState == LinkPreviewMiniCard.State.Loaded
                PropertyChanges {
                    target: root
                    title: root.statusContactPreview.displayName
                    domain: Constants.externalStatusLink
                    iconUrl: (root.statusContactPreviewThumbnail.url || root.statusContactPreviewThumbnail.dataUri) ?? ""
                    thumbnailImageUrl: ""
                    type: LinkPreviewMiniCard.Type.User
                }
            },
            State {
                name: "statusCommunityPreview"
                when: root.previewType == Constants.StatusCommunity && root.previewState == LinkPreviewMiniCard.State.Loaded
                PropertyChanges {
                    target: root
                    title: communityName
                    domain: Constants.externalStatusLink
                    iconUrl: (root.statusCommunityPreviewIcon.url || root.statusCommunityPreviewIcon.dataUri) ?? ""
                    thumbnailImageUrl: ""
                    type: LinkPreviewMiniCard.Type.Community
                    communityName: root.statusCommunityPreview ? root.statusCommunityPreview.displayName : ""
                }
            },
            State {
                name: "statusCommunityChannelPreview"
                when: root.previewType == Constants.StatusCommunityChannel && root.previewState == LinkPreviewMiniCard.State.Loaded
                PropertyChanges {
                    target: root
                    title: root.statusCommunityChannelPreview ? root.statusCommunityChannelPreview.displayName : ""
                    domain: Constants.externalStatusLink
                    iconUrl: (root.statusCommunityChannelCommunityPreviewIcon.url || root.statusCommunityChannelCommunityPreviewIcon.dataUri) ?? ""
                    thumbnailImageUrl: ""
                    type: LinkPreviewMiniCard.Type.Channel
                    channelName: "#" + title
                    communityName: root.statusCommunityChannelCommunityPreview ? root.statusCommunityChannelCommunityPreview.displayName : ""
                }
            }
        ]
    }
}
