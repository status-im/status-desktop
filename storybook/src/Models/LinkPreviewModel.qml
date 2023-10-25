import QtQuick 2.15

ListModel {
    id: root


    function getStandardLinkPreview() {
        const preview = Object.assign({}, emptyObject)
        preview.url = "https://www.youtube.com/watch?v=9bZkp7q19f0"
        preview.previewType = 1
        preview.standardPreview = {}
        preview.standardPreviewThumbnail = {}
        preview.standardPreview.hostname = "www.youtube.com"
        preview.standardPreview.title = "PSY - GANGNAM STYLE(강남스타일) M/V"
        preview.standardPreview.description = "PSY - ‘I LUV IT’ M/V @ https://youtu.be/Xvjnoagk6GU PSY - ‘New Face’ M/V @https://youtu.be/OwJPPaEyqhI PSY - 8TH ALBUM '4X2=8' on iTunes @ https://smarturl.it/PSY_8thAlbum PSY - GANGNAM STYLE(강남스타일) on iTunes @ http://smarturl.it/PsyGangnam #PSY #싸이 #GANGNAMSTYLE #강남스타일 More about PSY@ http://www.psyp..."
        preview.standardPreview.linkType = 0
        preview.standardPreviewThumbnail.width = 480
        preview.standardPreviewThumbnail.height = 360
        preview.standardPreviewThumbnail.url = "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
        preview.standardPreviewThumbnail.dataUri = ""
        return preview
    }

    function getImageLinkPreview() {
        const preview = Object.assign({}, emptyObject)
        preview.url = "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
        preview.previewType = 1
        preview.standardPreview = {}
        preview.standardPreviewThumbnail = {}
        preview.standardPreview.hostname = "i.ytimg.com"
        preview.standardPreview.title = "Image_link_preview.png"
        preview.standardPreview.description = "Image link preview"
        preview.standardPreview.linkType = 1
        preview.standardPreviewThumbnail.width = 480
        preview.standardPreviewThumbnail.height = 360
        preview.standardPreviewThumbnail.url = "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
        preview.standardPreviewThumbnail.dataUri = ""
        return preview
    }

    function getCommunityLinkPreview() {
        const preview = Object.assign({}, emptyObject)
        preview.url = "https://status.app/c/ixiACjAKDlRlc3QgQ29tbXVuaXR5Eg9PcGVuIGZvciBhbnlvbmUYdiIHI0ZGMDAwMCoCHwkD#zQ3shnd55dNx9yTihuL6XMbmyM6UNjzU6jk77h5Js31jxcT5V"
        preview.previewType = 3
        preview.statusCommunityPreview = {}
        preview.statusCommunityPreview.communityId = "zQ3shnd55dNx9yTihuL6XMbmyM6UNjzU6jk77h5Js31jxcT5V"
        preview.statusCommunityPreview.displayName = "Test community display name"
        preview.statusCommunityPreview.description = "Test community description"
        preview.statusCommunityPreview.membersCount = 10
        preview.statusCommunityPreview.color = "#123456"
        preview.statusCommunityPreviewIcon = {}
        preview.statusCommunityPreviewIcon.width = 64
        preview.statusCommunityPreviewIcon.height = 64
        preview.statusCommunityPreviewIcon.url = "https://picsum.photos/64/64?random=1"
        preview.statusCommunityPreviewIcon.dataUri = ""
        preview.statusCommunityPreviewBanner = {}
        preview.statusCommunityPreviewBanner.width = 320
        preview.statusCommunityPreviewBanner.height = 180
        preview.statusCommunityPreviewBanner.url = "https://picsum.photos/320/180?random=1"
        preview.statusCommunityPreviewBanner.dataUri = ""
        return preview
    }

    function getChannelLinkPreview() {
        const preview = Object.assign({}, emptyObject)
        preview.url = "https://status.app/c/ixiACjAKDlRlc3QgQ29tbXVuaXR5Eg9PcGVuIGZvciBhbnlvbmUYdiIHI0ZGMDAwMCoCHwkD#zQ3shnd55dNx9yTihuL6XMbmyM6UNjzU6jk77h5Js31jxcT5V"
        preview.previewType = 4
        preview.statusCommunityChannelPreview = {}
        preview.statusCommunityChannelPreview.channelUuid = "zQ3shnd55dNx9yTihuL6XMbmyM6UNjzU6jk77h5Js31jxcT5V"
        preview.statusCommunityChannelPreview.emoji = "👋"
        preview.statusCommunityChannelPreview.displayName = "general"
        preview.statusCommunityChannelPreview.description = "Test channel description"
        preview.statusCommunityChannelPreview.color = "#122456"
        preview.statusCommunityChannelCommunityPreview = {}
        preview.statusCommunityChannelCommunityPreview.communityId = "zQ3shnd55dNx9yTihuL6XMbmyM6UNjzU6jk77h5Js31jxcT5V"
        preview.statusCommunityChannelCommunityPreview.displayName = "Doodles"
        preview.statusCommunityChannelCommunityPreview.description = "Test community description"
        preview.statusCommunityChannelCommunityPreview.membersCount = 10
        preview.statusCommunityChannelCommunityPreview.color = "#123456"
        preview.statusCommunityChannelCommunityPreviewIcon = {}
        preview.statusCommunityChannelCommunityPreviewIcon.width = 64
        preview.statusCommunityChannelCommunityPreviewIcon.height = 64
        preview.statusCommunityChannelCommunityPreviewIcon.url = "https://picsum.photos/64/64?random=1"
        preview.statusCommunityChannelCommunityPreviewIcon.dataUri = ""
        preview.statusCommunityChannelCommunityPreviewBanner = {}
        preview.statusCommunityChannelCommunityPreviewBanner.width = 320
        preview.statusCommunityChannelCommunityPreviewBanner.height = 180
        preview.statusCommunityChannelCommunityPreviewBanner.url = "https://picsum.photos/320/180?random=1"
        preview.statusCommunityChannelCommunityPreviewBanner.dataUri = ""
        return preview
    }

    function getContactLinkPreview() {
        const preview = Object.assign({}, emptyObject)
        preview.url = "https://status.app/u/Ow==#zQ3shgmVJjmwwhkfAemjDizYJtv9nzot7QD4iRJ52ZkgdU6Ci"
        preview.previewType = 2
        preview.statusContactPreview = {}
        preview.statusContactPreview.publicKey = "zQ3shgmVJjmwwhkfAemjDizYJtv9nzot7QD4iRJ52ZkgdU6Ci"
        preview.statusContactPreview.displayName = "Test contact display name"
        preview.statusContactPreview.description = "Test description"
        preview.statusContactPreviewThumbnail = {}
        preview.statusContactPreviewThumbnail.width = 64
        preview.statusContactPreviewThumbnail.height = 64
        preview.statusContactPreviewThumbnail.url = "https://picsum.photos/64/64?random=1"
        preview.statusContactPreviewThumbnail.dataUri = ""
        return preview
    }

    readonly property var emptyObject: {
        "unfurled": true,
        "immutable": false,
        "empty": false,
        "url": "",
        "previewType": 1,
        "standardPreview": {},
        "standardPreviewThumbnail": {},
        "statusContactPreview": {},
        "statusContactPreviewThumbnail": {},
        "statusCommunityPreview": {},
        "statusCommunityPreviewIcon": {},
        "statusCommunityPreviewBanner": {},
        "statusCommunityChannelPreview": {},
        "statusCommunityChannelCommunityPreview": {},
        "statusCommunityChannelCommunityPreviewIcon": {},
        "statusCommunityChannelCommunityPreviewBanner": {},
    }

    // Create the model dynamically, because `ListElement` doesnt suppport nested elements
    Component.onCompleted: {
        append(getStandardLinkPreview())
        append(getImageLinkPreview())
        append(getCommunityLinkPreview())
        append(getChannelLinkPreview())
        append(getContactLinkPreview())
    }
}
