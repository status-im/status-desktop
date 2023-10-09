import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import Storybook 1.0

import StatusQ.Core.Theme 0.1
import shared.controls.chat 1.0

SplitView {

    Logs { id: logs }
    orientation: Qt.Vertical

    SplitView {

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Pane {
            SplitView.fillWidth: true
            Rectangle {
                id: wrapper
                anchors.fill: parent
                color: Theme.palette.statusChatInput.secondaryBackgroundColor

                ChatInputLinksPreviewArea {
                    id: chatInputLinkPreviewsArea
                    anchors.centerIn: parent
                    width: parent.width
                    imagePreviewArray: ["https://picsum.photos/200/300?random=1", "https://picsum.photos/200/300?random=1"]
                    linkPreviewModel: showLinkPreviewSettings ? emptyModel : linkPreviewListModel
                    showLinkPreviewSettings: !linkPreviewEnabledSwitch.checked
                    visible: hasContent

                    onImageRemoved: (index) =>  logs.logEvent("ChatInputLinksPreviewArea::onImageRemoved: " + index)
                    onImageClicked: (chatImage) => logs.logEvent("ChatInputLinksPreviewArea::onImageClicked: " + chatImage)
                    onLinkReload: (link) => logs.logEvent("ChatInputLinksPreviewArea::onLinkReload: " + link)
                    onLinkClicked: (link) => logs.logEvent("ChatInputLinksPreviewArea::onLinkClicked: " + link)

                    onEnableLinkPreview: () => {
                                         linkPreviewEnabledSwitch.checked = true
                                         logs.logEvent("ChatInputLinksPreviewArea::onEnableLinkPreview")
                                        }
                    onEnableLinkPreviewForThisMessage: () => logs.logEvent("ChatInputLinksPreviewArea::onEnableLinkPreviewForThisMessage")
                    onDisableLinkPreview: () => logs.logEvent("ChatInputLinksPreviewArea::onDisableLinkPreview")
                    onDismissLinkPreviewSettings: () => logs.logEvent("ChatInputLinksPreviewArea::onDismissLinkPreviewSettings")
                    onDismissLinkPreview: (index) => logs.logEvent("ChatInputLinksPreviewArea::onDismissLinkPreview: " + index)
                }
            }
        }

        Pane {
            SplitView.preferredWidth: 300
            SplitView.fillHeight: true
            ColumnLayout {
                Label {
                    text: "Links preview enabled"
                }
                Switch {
                    id: linkPreviewEnabledSwitch
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }

    ListModel {
        id: emptyModel
    }

    ListModel {
        id: linkPreviewListModel
        ListElement {
            url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
            unfurled: true
            immutable: false
            hostname: "youtube.com"
            title: "PSY - GANGNAM STYLE(강남스타일) M/V"
            description: ""
            linkType: 0
            thumbnailWidth: 480
            thumbnailHeight: 360
            thumbnailUrl: "https://picsum.photos/480/360?random=1"
            thumbnailDataUri: ""
        }
        ListElement {
            url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
            unfurled: false
            immutable: false
            hostname: "youtube.com"
            title: "PSY - GANGNAM STYLE(강남스타일) M/V"
            description: ""
            linkType: 0
            thumbnailWidth: 480
            thumbnailHeight: 360
            thumbnailUrl: "https://picsum.photos/480/360?random=2"
            thumbnailDataUri: ""
        }
        ListElement {
            url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
            unfurled: true
            immutable: false
            hostname: ""
            title: "PSY - GANGNAM STYLE(강남스타일) M/V"
            description: ""
            linkType: 0
            thumbnailWidth: 480
            thumbnailHeight: 360
            thumbnailUrl: "https://picsum.photos/480/360?random=3"
            thumbnailDataUri: ""
        }
        ListElement {
            url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
            unfurled: true
            hostname: "youtube.com"
            title: "PSY - GANGNAM STYLE(강남스타일) M/V"
            description: ""
            linkType: 0
            thumbnailWidth: 480
            thumbnailHeight: 360
            thumbnailUrl: "https://picsum.photos/480/360?random=4"
            thumbnailDataUri: ""
        }
        ListElement {
            url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
            unfurled: true
            immutable: false
            hostname: "youtube.com"
            title: "PSY - GANGNAM STYLE(강남스타일) M/V"
            description: ""
            linkType: 0
            thumbnailWidth: 480
            thumbnailHeight: 360
            thumbnailUrl: "https://picsum.photos/480/360?random=5"
            thumbnailDataUri: ""
        }
        ListElement {
            url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
            unfurled: true
            hostname: "youtube.com"
            title: "PSY - GANGNAM STYLE(강남스타일) M/V"
            description: ""
            linkType: 0
            thumbnailWidth: 480
            thumbnailHeight: 360
            thumbnailUrl: "https://picsum.photos/480/360?random=6"
            thumbnailDataUri: ""
        }
        ListElement {
            url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
            unfurled: true
            immutable: false
            hostname: "youtube.com"
            title: "PSY - GANGNAM STYLE(강남스타일) M/V"
            description: ""
            linkType: 0
            thumbnailWidth: 480
            thumbnailHeight: 360
            thumbnailUrl: "https://picsum.photos/480/360?random=7"
            thumbnailDataUri: ""
        }
        ListElement {
            url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
            unfurled: true
            immutable: false
            hostname: "youtube.com"
            title: "PSY - GANGNAM STYLE(강남스타일) M/V"
            description: ""
            linkType: 0
            thumbnailWidth: 480
            thumbnailHeight: 360
            thumbnailUrl: "https://picsum.photos/480/360?random=8"
            thumbnailDataUri: ""
        }
        ListElement {
            url: "https://www.youtube.com/watch?v=9bZkp7q19f0"
            unfurled: true
            immutable: false
            hostname: "youtube.com"
            title: "PSY - GANGNAM STYLE(강남스타일) M/V"
            description: ""
            linkType: 0
            thumbnailWidth: 480
            thumbnailHeight: 360
            thumbnailUrl: "https://picsum.photos/480/360?random=9"
            thumbnailDataUri: ""
        }
    }
}

// category: Panels

// https://www.figma.com/file/Mr3rqxxgKJ2zMQ06UAKiWL/💬-Chat⎜Desktop?type=design&node-id=22341-184809&mode=design&t=VWBVK4DOUxr1BmTp-0
