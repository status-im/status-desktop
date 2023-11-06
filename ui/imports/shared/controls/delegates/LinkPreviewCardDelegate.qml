import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.controls.chat 1.0

LinkPreviewCard {
    id: root

    /*
    * Model properties
    * The following properties are required to be set by the user of this component
    * unfurled: Whether the link has been unfurled or not
    * empty: Whether the link preview is empty or not
    * url: The url of the link
    * immutable: Whether the link preview can be updated
    * previewType: The type of the preview. See Constants.LinkPreviewType
    * standardPreview: The standard preview data (title, description, linkType, hostname)
    * standardPreviewThumbnail: The standard preview thumbnail data (url, dataUri)
    * statusContactPreview: The status contact preview data (displayName, publicKey, description, icon)
    * statusContactPreviewThumbnail: The status contact preview thumbnail data (url, dataUri)
    * statusCommunityPreview: The status community preview data (communityId, displayName, description, membersCount, color)
    * statusCommunityPreviewIcon: The status community preview icon data (url, dataUri)
    * statusCommunityPreviewBanner: The status community preview banner data (url, dataUri)
    * statusCommunityChannelPreview: The status community channel preview data (channelId, displayName, description, emoji, color)
    * statusCommunityChannelCommunityPreview: The status community channel community preview data (communityId, displayName, description, membersCount, color)
    * statusCommunityChannelCommunityPreviewIcon: The status community channel community preview icon data (url, dataUri)
    * statusCommunityChannelCommunityPreviewBanner: The status community channel community preview banner data (url, dataUri)
    */
    required property bool unfurled
    required property bool empty
    required property string url
    required property bool immutable
    required property bool isLocalData
    required property bool loadingLocalData
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

    //View properties
    type: root.previewType
    linkData {
        title: standardPreview ? standardPreview.title : ""
        description: standardPreview ? standardPreview.description : ""
        domain: standardPreview ? standardPreview.hostname : "" //TODO: Use domainName when available
        thumbnail: standardPreviewThumbnail ? (standardPreviewThumbnail.url || standardPreviewThumbnail.dataUri) || "" : ""
        image: "" //TODO: usefavicon when available
    }
    userData {
        name: statusContactPreview ? statusContactPreview.displayName : ""
        publicKey: statusContactPreview ? statusContactPreview.publicKey : ""
        bio: statusContactPreview ? statusContactPreview.description : ""
        image: statusContactPreviewThumbnail ? (statusContactPreviewThumbnail.url || statusContactPreviewThumbnail.dataUri) || "" : ""
        ensVerified: false // not supported yet
    }
    communityData {
        name: statusCommunityPreview ? statusCommunityPreview.displayName : ""
        description: statusCommunityPreview ? statusCommunityPreview.description : ""
        banner: statusCommunityPreviewBanner ? (statusCommunityPreviewBanner.url || statusCommunityPreviewBanner.dataUri) || "" : ""
        image: statusCommunityPreviewIcon ? (statusCommunityPreviewIcon.url || statusCommunityPreviewIcon.dataUri) || "" : ""
        membersCount: statusCommunityPreview ? statusCommunityPreview.membersCount : 0
        activeMembersCount: statusCommunityPreview && isLocalData ? statusCommunityPreview.activeMembersCount : -1
        color: statusCommunityPreview ? statusCommunityPreview.color : ""
    }
    channelData {
        name: statusCommunityChannelPreview ? statusCommunityChannelPreview.displayName : ""
        description: statusCommunityChannelPreview ? statusCommunityChannelPreview.description : ""
        emoji: statusCommunityChannelPreview ? statusCommunityChannelPreview.emoji : ""
        color: statusCommunityChannelPreview ? statusCommunityChannelPreview.color : ""
        communityData {
            name: statusCommunityChannelCommunityPreview ? statusCommunityChannelCommunityPreview.displayName : ""
            description: statusCommunityChannelCommunityPreview ? statusCommunityChannelCommunityPreview.description : ""
            banner: statusCommunityChannelCommunityPreviewBanner ? (statusCommunityChannelCommunityPreviewBanner.url || statusCommunityChannelCommunityPreviewBanner.dataUri) || "" : ""
            image:  statusCommunityChannelCommunityPreviewIcon ? (statusCommunityChannelCommunityPreviewIcon.url || statusCommunityChannelCommunityPreviewIcon.dataUri) || "" : ""
            membersCount: statusCommunityChannelCommunityPreview ? statusCommunityChannelCommunityPreview.membersCount : 0
            activeMembersCount: statusCommunityChannelCommunityPreview && isLocalData ? statusCommunityChannelCommunityPreview.activeMembersCount : -1
            color: statusCommunityChannelCommunityPreview ? statusCommunityChannelCommunityPreview.color : ""
        }
    }
}
