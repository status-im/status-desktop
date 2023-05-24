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

Column {
    id: root

    property var store
    property var messageStore

    //receiving space separated url list
    property string links: ""
    readonly property alias unfurledLinksCount: d.unfurledLinksCount
    readonly property alias unfurledImagesCount: d.unfurledImagesCount
    property bool isCurrentUser: false

    signal imageClicked(var image, var mouse, var imageSource)
    signal linksLoaded()

    spacing: 4

    Repeater {
        id: linksRepeater
        model: linksModel
        delegate: Loader {
            id: linkMessageLoader
            required property var result
            required property string link
            required property int index
            required property bool unfurl
            required property bool success
            required property bool isStatusDeepLink
            readonly property bool isImage: result.contentType ? result.contentType.startsWith("image/") : false
            readonly property bool neverAskAboutUnfurlingAgain: RootStore.neverAskAboutUnfurlingAgain
            
            active: success
            asynchronous: true
            StateGroup {
                //Using StateGroup as a warkardound for https://bugreports.qt.io/browse/QTBUG-47796
                id: linkPreviewLoaderState
                states:[
                    State {
                        name: "neverAskAboutUnfurling"
                        when: !unfurl && neverAskAboutUnfurlingAgain
                        PropertyChanges { target: linkMessageLoader; sourceComponent: undefined; }
                        StateChangeScript { name: "removeFromModel"; script: linksModel.remove(index)}
                    },
                    State { 
                        name: "askToEnableUnfurling"
                        when: !unfurl && !neverAskAboutUnfurlingAgain
                        PropertyChanges { target: linkMessageLoader; sourceComponent: enableLinkComponent }
                    },
                    State { 
                        name: "loadImage"
                        when: unfurl && isImage
                        PropertyChanges { target: linkMessageLoader; sourceComponent: unfurledImageComponent }
                    },
                    State { 
                        name: "loadLinkPreview"
                        when: unfurl && !isImage && !isStatusDeepLink
                        PropertyChanges { target: linkMessageLoader; sourceComponent: unfurledLinkComponent }
                    },
                    State { 
                        name: "statusInvitation"
                        when: unfurl && isStatusDeepLink
                        PropertyChanges { target: linkMessageLoader; sourceComponent: invitationBubble }
                    }
                ]
            }
        }
    }

    QtObject {
        id: d
        property bool hasImageLink: false
        property int unfurledLinksCount: 0
        property int unfurledImagesCount: 0
        readonly property string uuid: Utils.uuid()
        readonly property string whiteListedImgExtensions: Constants.acceptedImageExtensions.toString()
        readonly property string whiteListedUrls: JSON.stringify(localAccountSensitiveSettings.whitelistedUnfurlingSites)
        readonly property string getLinkPreviewDataId: messageStore.messageModule.getLinkPreviewData(root.links, d.uuid, whiteListedUrls, whiteListedImgExtensions, localAccountSensitiveSettings.displayChatImages)
        onGetLinkPreviewDataIdChanged: { linkFetchConnections.enabled = true }
    }

    Connections {
        id: linkFetchConnections
        enabled: false
        target: root.messageStore.messageModule
        function onLinkPreviewDataWasReceived(previewData, uuid) {
            if(d.uuid != uuid) return
            linkFetchConnections.enabled = false
            try {  linksModel.rawData = JSON.parse(previewData) }
            catch(e) { console.warn("error parsing link preview data", previewData) }
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
            root.linksLoaded()
        }
    }

    Component {
        id: unfurledImageComponent

        MessageBorder {
            width: linkImage.width
            height: linkImage.height
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

            Component.onCompleted: d.unfurledImagesCount++
            Component.onDestruction: d.unfurledImagesCount--
        }
    }

    Component {
        id: invitationBubble
        InvitationBubbleView {
            property var invitationData: root.store.getLinkDataForStatusLinks(link)
            onInvitationDataChanged: { if(!invitationData) linksModel.remove(index) }
            store: root.store
            communityId: invitationData ? invitationData.communityId : ""
            anchors.left: parent.left
            visible: !!invitationData
            loading: invitationData.fetching

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
            width: linkImage.visible ? linkImage.width + 2 : 300
            height: {
                if (linkImage.visible) {
                    return linkImage.height + (Style.current.smallPadding * 2) + (linkTitle.height + 2 + linkSite.height)
                }
                return (Style.current.smallPadding * 2) + linkTitle.height + 2 + linkSite.height
            }
            isCurrentUser: root.isCurrentUser

            StatusChatImageLoader {
                id: linkImage
                objectName: "LinksMessageView_unfurledLinkComponent_linkImage"
                source: result.thumbnailUrl
                visible: result.thumbnailUrl.length
                readonly property int previewWidth: parseInt(result.width)
                imageWidth: Math.min(300, previewWidth > 0 ? previewWidth : 300)
                isCurrentUser: root.isCurrentUser
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                isOnline: root.store.mainModuleInst.isOnline
                asynchronous: true
                onClicked: {
                    if (!!result.callback) {
                        return result.callback()
                    }
                    Global.openLink(result.address)
                }
            }

            StatusBaseText {
                id: linkTitle
                text: result.title
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
                text: result.site
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
                    if (!!result.callback) {
                        return result.callback()
                    }
                    Global.openLink(link)
                }
            }

            Component.onCompleted: d.unfurledLinksCount++
            Component.onDestruction: d.unfurledLinksCount--
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
