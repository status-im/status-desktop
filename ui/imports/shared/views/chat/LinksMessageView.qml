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
    property var localUnfurlLinks

    property bool isCurrentUser: false

    signal imageClicked(var image, var mouse, var imageSource)

    Repeater {
        id: linksRepeater
        model: root.linkPreviewModel

        delegate: Loader {
            id: linkMessageLoader

            // properties from the model
            required property string url
            required property bool unfurled
            required property string hostname
            required property string title
            required property string description
            required property int linkType
            required property int thumbnailWidth
            required property int thumbnailHeight
            required property string thumbnailUrl
            required property string thumbnailDataUri
            property bool animated: false

            asynchronous: true

            StateGroup {
                //Using StateGroup as a warkardound for https://bugreports.qt.io/browse/QTBUG-47796
                states: [
                    State {
                        name: "loadLinkPreview"
                        when: linkMessageLoader.linkType === Constants.LinkPreviewType.Link
                        PropertyChanges { target: linkMessageLoader; sourceComponent: unfurledLinkComponent }
                    },
                    State {
                        name: "loadImage"
                        when: linkMessageLoader.linkType === Constants.LinkPreviewType.Image
                        PropertyChanges { target: linkMessageLoader; sourceComponent: unfurledImageComponent }
                    }
                    // NOTE: New unfurling not yet suppport status links.
                    //       Uncomment code below when implemented:
                    //       - https://github.com/status-im/status-go/issues/3762
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
                source: thumbnailUrl
                imageWidth: 300
                isCurrentUser: root.isCurrentUser
                playing: globalAnimationEnabled && localAnimationEnabled
                isOnline: root.store.mainModuleInst.isOnline
                asynchronous: true
                isAnimated: animated // FIXME: GIFs are not supported with new unfurling yet
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
            communityId: invitationData && invitationData.communityData ? invitationData.communityData.communityId : ""
            communityData: invitationData && invitationData.communityData ? invitationData.communityData : null
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
                    Global.openLink(url)
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
                    Global.openLink(url)
                }
            }
        }
    }


    // Code below can be dropped when New unfurling flow suppports GIFs.

    QtObject {
        id: d

        readonly property string uuid: Utils.uuid()
        readonly property string whiteListedImgExtensions: Constants.acceptedImageExtensions.toString()
        readonly property string whiteListedUrls: JSON.stringify(localAccountSensitiveSettings.whitelistedUnfurlingSites)
        readonly property string getLinkPreviewDataId: {
            if (root.localUnfurlLinks === "")
                return ""
            return root.messageStore.messageModule.getLinkPreviewData(root.localUnfurlLinks,
                                                                      d.uuid,
                                                                      whiteListedUrls,
                                                                      whiteListedImgExtensions,
                                                                      localAccountSensitiveSettings.displayChatImages)
        }


        onGetLinkPreviewDataIdChanged: {

            linkFetchConnections.enabled = root.localUnfurlLinks !== ""
        }
    }

    Connections {
        id: linkFetchConnections
        enabled: false
        target: root.messageStore.messageModule

        function onLinkPreviewDataWasReceived(previewData, uuid) {
            if (d.uuid !== uuid)
                return
            linkFetchConnections.enabled = false
            try {
                linksModel.rawData = JSON.parse(previewData)
            }
            catch(e) {
                console.warn("error parsing link preview data", previewData)
            }
        }
    }

    ListModel {
         id: linksModel

         property var rawData

         onRawDataChanged: {
             linksModel.clear()
             rawData.links.forEach((link) => {
                 linksModel.append(link)
             })
         }
     }

    Repeater {
        id: tempRepeater
        visible: !RootStore.neverAskAboutUnfurlingAgain
        model: linksModel

        delegate: Loader {
            id: tempLoader

            required property var result
            required property string link
            required property int index
            required property bool unfurl
            required property bool success
            required property bool isStatusDeepLink
            readonly property bool isImage: result.contentType ? result.contentType.startsWith("image/") : false

            readonly property string thumbnailUrl: result && result.thumbnailUrl ? result.thumbnailUrl : ""
            readonly property string title: result && result.title ? result.title : ""
            readonly property string hostname: result && result.site ? result.site : ""
            readonly property bool animated: true

            StateGroup {
                //Using StateGroup as a warkardound for https://bugreports.qt.io/browse/QTBUG-47796
                id: linkPreviewLoaderState
                states: [
                   State {
                        name: "askToEnableUnfurling"
                        when: !tempLoader.unfurl
                        PropertyChanges { target: tempLoader; sourceComponent: enableLinkComponent }
                    },
                    State {
                        name: "loadImage"
                        when: tempLoader.unfurl && tempLoader.isImage
                        PropertyChanges { target: tempLoader; sourceComponent: unfurledImageComponent }
                    }
//                    State {
//                        name: "loadLinkPreview"
//                        when: unfurl && !isImage && !isStatusDeepLink
//                        PropertyChanges { target: tempLoader; sourceComponent: unfurledLinkComponent }
//                    },
//                    State {
//                        name: "statusInvitation"
//                        when: unfurl && isStatusDeepLink
//                        PropertyChanges { target: tempLoader; sourceComponent: invitationBubble }
//                    }
                ]
            }
        }
    }

    Component {
        id: enableLinkComponent

        Rectangle {
            id: enableLinkRoot
            width: 300
            height: childrenRect.height + Style.current.smallPadding
            radius: 16
            border.width: 1
            border.color: Style.current.border
            color: Style.current.background

            StatusFlatRoundButton {
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.smallPadding
                icon.width: 20
                icon.height: 20
                icon.name: "close-circle"
                onClicked: linksModel.remove(index)
            }

            Image {
                id: unfurlingImage
                source: Style.png("unfurling-image")
                width: 132
                height: 94
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
            }

            StatusBaseText {
                id: enableText
                text: isImage ? qsTr("Enable automatic image unfurling") :
                                    qsTr("Enable link previews in chat?")
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                anchors.top: unfurlingImage.bottom
                anchors.topMargin: Style.current.halfPadding
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: infoText
                text: qsTr("Once enabled, links posted in the chat may share your metadata with their owners")
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                anchors.top: enableText.bottom
                font.pixelSize: 13
                color: Theme.palette.baseColor1
            }

            Separator {
                id: sep1
                anchors.top: infoText.bottom
                anchors.topMargin: Style.current.smallPadding
            }

            StatusFlatButton {
                id: enableBtn
                objectName: "LinksMessageView_enableBtn"
                text: qsTr("Enable in Settings")
                onClicked: {
                    Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.messaging);
                }
                width: parent.width
                anchors.top: sep1.bottom
                Component.onCompleted: {
                    background.radius = 0;
                }
            }

            Separator {
                id: sep2
                anchors.top: enableBtn.bottom
                anchors.topMargin: 0
            }

            Item {
                width: parent.width
                height: 44
                anchors.top: sep2.bottom
                clip: true

                StatusFlatButton {
                    id: dontAskBtn
                    width: parent.width
                    height: (parent.height+Style.current.padding)
                    anchors.top: parent.top
                    anchors.topMargin: -Style.current.padding
                    contentItem: Item {
                        StatusBaseText {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: Style.current.halfPadding
                            font: dontAskBtn.font
                            color: dontAskBtn.enabled ? dontAskBtn.textColor : dontAskBtn.disabledTextColor
                            text: qsTr("Don't ask me again")
                        }
                    }
                    onClicked: RootStore.setNeverAskAboutUnfurlingAgain(true)
                    Component.onCompleted: {
                        background.radius = Style.current.padding;
                    }
                }
            }
        }
    }



}
