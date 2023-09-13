import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import shared.views.chat 1.0

SplitView {
    Pane {
        id: messageViewWrapper
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        LinksMessageView {
            id: linksMessageView
            
            anchors.fill: parent

            store: {}
            messageStore: {}
            linkPreviewModel: ListModel {
                id: linkPreviewModel
                ListElement {
                    url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
                    unfurled: true
                    hostname: "www.youtube.com"
                    title: "PSY - GANGNAM STYLE(강남스타일) M/V"
                    description: "PSY - ‘I LUV IT’ M/V @ https://youtu.be/Xvjnoagk6GU PSY - ‘New Face’ M/V @https://youtu.be/OwJPPaEyqhI PSY - 8TH ALBUM '4X2=8' on iTunes @ https://smarturl.it/PSY_8thAlbum PSY - GANGNAM STYLE(강남스타일) on iTunes @ http://smarturl.it/PsyGangnam #PSY #싸이 #GANGNAMSTYLE #강남스타일 More about PSY@ http://www.psyp..."
                    linkType: 0 // 0 = link, 1 = image
                    thumbnailWidth: 480
                    thumbnailHeight: 360
                    thumbnailUrl: "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
                    thumbnailDataUri: "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
                }
                ListElement {
                    url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
                    unfurled: true
                    hostname: "www.youtube.com"
                    title: "PSY - GANGNAM STYLE(강남스타일) M/V"
                    description: "PSY - ‘I LUV IT’ M/V @ https://youtu.be/Xvjnoagk6GU PSY - ‘New Face’ M/V @https://youtu.be/OwJPPaEyqhI PSY - 8TH ALBUM '4X2=8' on iTunes @ https://smarturl.it/PSY_8thAlbum PSY - GANGNAM STYLE(강남스타일) on iTunes @ http://smarturl.it/PsyGangnam #PSY #싸이 #GANGNAMSTYLE #강남스타일 More about PSY@ http://www.psyp..."
                    linkType: 0 // 0 = link, 1 = image
                    thumbnailWidth: 480
                    thumbnailHeight: 360
                    thumbnailUrl: "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
                    thumbnailDataUri: "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
                }
                ListElement {
                    url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
                    unfurled: true
                    hostname: "www.youtube.com"
                    title: "PSY - GANGNAM STYLE(강남스타일) M/V"
                    description: "PSY - ‘I LUV IT’ M/V @ https://youtu.be/Xvjnoagk6GU PSY - ‘New Face’ M/V @https://youtu.be/OwJPPaEyqhI PSY - 8TH ALBUM '4X2=8' on iTunes @ https://smarturl.it/PSY_8thAlbum PSY - GANGNAM STYLE(강남스타일) on iTunes @ http://smarturl.it/PsyGangnam #PSY #싸이 #GANGNAMSTYLE #강남스타일 More about PSY@ http://www.psyp..."
                    linkType: 0 // 0 = link, 1 = image
                    thumbnailWidth: 480
                    thumbnailHeight: 360
                    thumbnailUrl: "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
                    thumbnailDataUri: "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
                }
                ListElement {
                    url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
                    unfurled: true
                    hostname: "www.youtube.com"
                    title: "PSY - GANGNAM STYLE(강남스타일) M/V"
                    description: "PSY - ‘I LUV IT’ M/V @ https://youtu.be/Xvjnoagk6GU PSY - ‘New Face’ M/V @https://youtu.be/OwJPPaEyqhI PSY - 8TH ALBUM '4X2=8' on iTunes @ https://smarturl.it/PSY_8thAlbum PSY - GANGNAM STYLE(강남스타일) on iTunes @ http://smarturl.it/PsyGangnam #PSY #싸이 #GANGNAMSTYLE #강남스타일 More about PSY@ http://www.psyp..."
                    linkType: 0 // 0 = link, 1 = image
                    thumbnailWidth: 480
                    thumbnailHeight: 360
                    thumbnailUrl: "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
                    thumbnailDataUri: "https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg"
                }
            }
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