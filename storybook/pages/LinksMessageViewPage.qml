import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import shared.views.chat 1.0

SplitView {

    ListModel {
        id: mockedLinkPreviewModel

        // Create the model dynamically, because `ListElement` doesnt suppport nested elements
        Component.onCompleted: {
            const emptyObject = {
                "unfurled": true,
                "empty": false,
                "url": "https://www.youtube.com/watch?v=9bZkp7q19f0",
                "previewType": 1,
                "standardPreview": {
                    "hostname": "www.youtube.com",
                    "title": "PSY - GANGNAM STYLE(강남스타일) M/V",
                    "description": "PSY - ‘I LUV IT’ M/V @ https://youtu.be/Xvjnoagk6GU PSY - ‘New Face’ M/V @https://youtu.be/OwJPPaEyqhI PSY - 8TH ALBUM '4X2=8' on iTunes @ https://smarturl.it/PSY_8thAlbum PSY - GANGNAM STYLE(강남스타일) on iTunes @ http://smarturl.it/PsyGangnam #PSY #싸이 #GANGNAMSTYLE #강남스타일 More about PSY@ http://www.psyp...",
                    "linkType": 0,
                },
                "standardPreviewThumbnail": {
                    "width": 480,
                    "height": 360,
                    "url": "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg",
                    "dataUri": "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg",
                },
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

            const preview1 = Object.assign({}, emptyObject)
            preview1.url = "https://www.youtube.com/watch?v=9bZkp7q19f0"
            preview1.previewType = 1
            preview1.standardPreview = {}
            preview1.standardPreviewThumbnail = {}
            preview1.standardPreview.hostname = "www.youtube.com"
            preview1.standardPreview.title = "PSY - GANGNAM STYLE(강남스타일) M/V"
            preview1.standardPreview.description = "PSY - ‘I LUV IT’ M/V @ https://youtu.be/Xvjnoagk6GU PSY - ‘New Face’ M/V @https://youtu.be/OwJPPaEyqhI PSY - 8TH ALBUM '4X2=8' on iTunes @ https://smarturl.it/PSY_8thAlbum PSY - GANGNAM STYLE(강남스타일) on iTunes @ http://smarturl.it/PsyGangnam #PSY #싸이 #GANGNAMSTYLE #강남스타일 More about PSY@ http://www.psyp..."
            preview1.standardPreview.standardLinkType = 0
            preview1.standardPreviewThumbnail.width = 480
            preview1.standardPreviewThumbnail.height = 360
            preview1.standardPreviewThumbnail.url = "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
            preview1.standardPreviewThumbnail.dataUri = ""


            const preview2 = Object.assign({}, emptyObject)
            preview2.url = "https://status.app/u/Ow==#zQ3shgmVJjmwwhkfAemjDizYJtv9nzot7QD4iRJ52ZkgdU6Ci"
            preview2.previewType = 2
            preview2.statusContactPreview = {}
            preview2.statusContactPreview.publicKey = "zQ3shgmVJjmwwhkfAemjDizYJtv9nzot7QD4iRJ52ZkgdU6Ci"
            preview2.statusContactPreview.displayName = "Test contact display name"
            preview2.statusContactPreview.description = "Test description"
            preview2.statusContactPreviewThumbnail = {}
            preview2.statusContactPreviewThumbnail.width = 64
            preview2.statusContactPreviewThumbnail.height = 64
            preview2.statusContactPreviewThumbnail.url = "https://placehold.co/64x64"
            preview2.statusContactPreviewThumbnail.dataUri = ""

            const preview3 = Object.assign({}, emptyObject)
            preview3.url = "https://status.app/c/ixiACjAKDlRlc3QgQ29tbXVuaXR5Eg9PcGVuIGZvciBhbnlvbmUYdiIHI0ZGMDAwMCoCHwkD#zQ3shnd55dNx9yTihuL6XMbmyM6UNjzU6jk77h5Js31jxcT5V"
            preview3.previewType = 3
            preview3.statusCommunityPreview = {}
            preview3.statusCommunityPreview.communityId = "zQ3shnd55dNx9yTihuL6XMbmyM6UNjzU6jk77h5Js31jxcT5V"
            preview3.statusCommunityPreview.displayName = "Test community display name"
            preview3.statusCommunityPreview.description = "Test community description"
            preview3.statusCommunityPreview.membersCount = 10
            preview3.statusCommunityPreview.color = "#123456"
            preview3.statusCommunityPreviewIcon = {}
            preview3.statusCommunityPreviewIcon.width = 64
            preview3.statusCommunityPreviewIcon.height = 64
            preview3.statusCommunityPreviewIcon.url = "https://placehold.co/64x64"
            preview3.statusCommunityPreviewIcon.dataUri = ""
            preview3.statusCommunityPreviewBanner = {}
            preview3.statusCommunityPreviewBanner.width = 320
            preview3.statusCommunityPreviewBanner.height = 180
            preview3.statusCommunityPreviewBanner.url = "https://placehold.co/320x180"
            preview3.statusCommunityPreviewBanner.dataUri = ""

            mockedLinkPreviewModel.append(preview1)
            mockedLinkPreviewModel.append(preview2)
            mockedLinkPreviewModel.append(preview3)
        }
    }

    Pane {
        id: messageViewWrapper
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        component LinkPreviewObject: QtObject {
            required property string url
            required property bool unfurled
            required property bool empty
            required property int previewType
        }

        component StandardPreviewObject: QtObject {
            required property string hostname
            required property string title
            required property string description
            required property int linkType // 0 = link, 1 = image
        }

        component ThumbnailObject: QtObject {
            required property int width
            required property int height
            required property string url
            required property string dataUri
        }

        LinksMessageView {
            id: linksMessageView
            
            anchors.fill: parent

            store: {}
            messageStore: {}
            linkPreviewModel: mockedLinkPreviewModel
            localUnfurlLinks: {}
            isCurrentUser: true

            onImageClicked: {
                console.log("image clicked")
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
        
        ColumnLayout {
            spacing: 25
            ColumnLayout {
                Label {
                    text: qsTr("Sender")
                }
                CheckBox {
                    text: qsTr("Current user")
                    checked: linksMessageView.isCurrentUser
                    onToggled: linksMessageView.isCurrentUser = !linksMessageView.isCurrentUser
                }
            }
        }
    }
}
