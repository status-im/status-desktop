import QtQuick 2.15
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.status 1.0
import shared.panels 1.0
import shared.stores 1.0
import shared.controls.chat 1.0

ColumnLayout {
    id: root

    property var store
    property var messageStore
    property var linkPreviewModel

    property bool isCurrentUser: false

    signal imageClicked(var image, var mouse, var imageSource)

    Repeater {
        id: linksRepeater
        model: root.linkPreviewModel

        delegate: Loader {
            id: linkMessageLoader

            // properties from the model
            required property bool unfurled
            required property string title
            required property string description
            required property string hostname
            required property int thumbnailWidth
            required property int thumbnailHeight
            required property string thumbnailUrl
            required property string thumbnailDataUri

            asynchronous: true
            sourceComponent: unfurledLinkComponent

            StateGroup {
                //Using StateGroup as a warkardound for https://bugreports.qt.io/browse/QTBUG-47796
                states: [
                    State {
                        name: "loadLinkPreview"
                        when: !linkMessageLoader.isImage && !linkMessageLoader.isStatusDeepLink
                        PropertyChanges { target: linkMessageLoader; sourceComponent: unfurledLinkComponent }
                    }
                    // NOTE: New unfurling not yet suppport images and status links.
                    //       Uncomment code below when implemented:
                    //       - https://github.com/status-im/status-go/issues/3761
                    //       - https://github.com/status-im/status-go/issues/3762

                    // State {
                    //     name: "loadImage"
                    //     when: linkMessageLoader.isImage
                    //     PropertyChanges { target: linkMessageLoader; sourceComponent: unfurledImageComponent }
                    // },
                    // State {
                    //     name: "statusInvitation"
                    //     when: linkMessageLoader.isStatusDeepLink
                    //     PropertyChanges { target: linkMessageLoader; sourceComponent: invitationBubble }
                    // }
                ]
            }
        }
    }

    Component {
        id: unfurledImageComponent

        MessageBorder {
            implicitWidth: linkImage.width
            implicitHeight: linkImage.height
            isCurrentUser: root.isCurrentUser

            StatusChatImageLoader {
                id: linkImage

                readonly property bool globalAnimationEnabled: root.messageStore.playAnimation
                property bool localAnimationEnabled: true

                objectName: "LinksMessageView_unfurledImageComponent_linkImage"
                anchors.centerIn: parent
                source: result.thumbnailUrl
                imageWidth: 300
                isCurrentUser: root.isCurrentUser
                playing: globalAnimationEnabled && localAnimationEnabled
                isOnline: root.store.mainModuleInst.isOnline
                asynchronous: true
                isAnimated: result.contentType ? result.contentType.toLowerCase().endsWith("gif") : false
                onClicked: {
                    if (isAnimated && !playing)
                        localAnimationEnabled = true
                    else
                        root.imageClicked(linkImage.imageAlias, mouse, source)
                }
                imageAlias.cache: localAnimationEnabled // GIFs can only loop/play properly with cache enabled
                Loader {
                    width: 45
                    height: 38
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
                    active: linkImage.isAnimated && !linkImage.playing
                    sourceComponent: Item {
                        anchors.fill: parent
                        Rectangle {
                            anchors.fill: parent
                            color: "black"
                            radius: Style.current.radius
                            opacity: .4
                        }
                        StatusBaseText {
                            anchors.centerIn: parent
                            text: "GIF"
                            font.pixelSize: 13
                            color: "white"
                        }
                    }
                }
                Timer {
                    id: animationPlayingTimer
                    interval: 10000
                    running: linkImage.isAnimated && linkImage.playing
                    onTriggered: { linkImage.localAnimationEnabled = false }
                }
            }
        }
    }

    Component {
        id: invitationBubble

        InvitationBubbleView {
            property var invitationData: root.store.getLinkDataForStatusLinks(link)

            store: root.store
            communityId: invitationData ? invitationData.communityId : ""
            anchors.left: parent.left
            visible: !!invitationData
            loading: invitationData.fetching
            onInvitationDataChanged: {
                if (!invitationData)
                    linksModel.remove(index)
            }

            Connections {
                enabled: !!invitationData && invitationData.fetching
                target: root.store.communitiesModuleInst
                function onCommunityAdded(communityId:  string) {
                    if (communityId !== invitationData.communityId) return
                    invitationData = root.store.getLinkDataForStatusLinks(link)
                }
            }
        }
    }

    Component {
        id: unfurledLinkComponent

        MessageBorder {
            id: unfurledLink
            implicitWidth: linkImage.visible ? linkImage.width + 2 : 300
            implicitHeight: {
                if (linkImage.visible) {
                    return linkImage.height + (Style.current.smallPadding * 2) + (linkTitle.height + 2 + linkSite.height)
                }
                return (Style.current.smallPadding * 2) + linkTitle.height + 2 + linkSite.height
            }
            isCurrentUser: root.isCurrentUser

            StatusChatImageLoader {
                id: linkImage
                objectName: "LinksMessageView_unfurledLinkComponent_linkImage"
                source: thumbnailUrl
                visible: thumbnailUrl.length
                imageWidth: Math.min(300, thumbnailWidth > 0 ? thumbnailWidth : 300)
                isCurrentUser: root.isCurrentUser
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                isOnline: root.store.mainModuleInst.isOnline
                asynchronous: true
                onClicked: {
                    Global.openLink(result.address)
                }
            }

            StatusBaseText {
                id: linkTitle
                text: title
                font.pixelSize: 13
                font.weight: Font.Medium
                wrapMode: Text.Wrap
                anchors.top: linkImage.visible ? linkImage.bottom : parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.smallPadding
                anchors.rightMargin: Style.current.smallPadding
            }

            StatusBaseText {
                id: linkSite
                text: hostname
                font.pixelSize: 12
                font.weight: Font.Thin
                color: Theme.palette.baseColor1
                anchors.top: linkTitle.bottom
                anchors.topMargin: 2
                anchors.left: linkTitle.left
                anchors.bottomMargin: Style.current.halfPadding
            }

            MouseArea {
                anchors.top: linkImage.visible ? linkImage.top : linkTitle.top
                anchors.left: linkImage.visible ? linkImage.left : linkTitle.left
                anchors.right: linkImage.visible ? linkImage.right : linkTitle.right
                anchors.bottom: linkSite.bottom
                cursorShape: Qt.PointingHandCursor
                onClicked:  {
                    Global.openLink(link)
                }
            }
        }
    }
}
