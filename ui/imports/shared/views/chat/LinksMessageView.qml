import QtQuick 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0
import shared.status 1.0
import shared.panels 1.0
import shared.stores 1.0
import shared.controls.chat 1.0

Flow {
    id: root

    required property var store
    required property var messageStore

    required property var linkPreviewModel
    required property var gifLinks

    required property bool isCurrentUser

    readonly property alias hoveredLink: linksRepeater.hoveredUrl
    property string highlightLink: ""

    signal imageClicked(var image, var mouse, var imageSource, string url)

    spacing: 12

    //TODO: remove once GIF previews are unfurled sender side

    QtObject {
        id: d
        property bool localAskAboutUnfurling: true
    }

    Loader {
        visible: root.gifLinks && root.gifLinks.length > 0
                 && !RootStore.gifUnfurlingEnabled
                 && d.localAskAboutUnfurling && !RootStore.neverAskAboutUnfurlingAgain
        sourceComponent: enableLinkComponent
    }

    Repeater {
        id: tempRepeater
        model: RootStore.gifUnfurlingEnabled ? gifLinks : []
        delegate: gifComponent
    }

    Repeater {
        id: linksRepeater

        property string hoveredUrl: ""

        model: root.linkPreviewModel
        delegate: Loader {
            id: linkMessageLoader
            // properties from the model

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

            readonly property string hostname: standardPreview ? standardPreview.hostname : ""
            readonly property string title: standardPreview ? standardPreview.title : ""
            readonly property string description: standardPreview ? standardPreview.description : ""
            readonly property int standardLinkType: standardPreview ? standardPreview.linkType : ""
            readonly property int thumbnailWidth: standardPreviewThumbnail ? standardPreviewThumbnail.width : ""
            readonly property int thumbnailHeight: standardPreviewThumbnail ? standardPreviewThumbnail.height : ""
            readonly property string thumbnailUrl: standardPreviewThumbnail ? standardPreviewThumbnail.url : ""
            readonly property string thumbnailDataUri: standardPreviewThumbnail ? standardPreviewThumbnail.dataUri : ""

            asynchronous: true
            active: unfurled && !empty

            StateGroup {
                //Using StateGroup as a warkardound for https://bugreports.qt.io/browse/QTBUG-47796
                states: [
                    State {
                        name: "standardLinkPreview"
                        when: linkMessageLoader.previewType === Constants.LinkPreviewType.Standard
                        PropertyChanges { target: linkMessageLoader; sourceComponent: standardLinkPreviewCard }
                    },
                    State {
                        name: "statusContactLinkPreview"
                        when: linkMessageLoader.previewType === Constants.LinkPreviewType.StatusContact
                        PropertyChanges { target: linkMessageLoader; sourceComponent: unfurledProfileLinkComponent }
                    }
                ]
            }
        }
    }
    
    Component {
        id: standardLinkPreviewCard
        LinkPreviewCard {
            leftTail: !root.isCurrentUser // WARNING: Is this by design?
            bannerImageSource: standardPreviewThumbnail ? standardPreviewThumbnail.url : ""
            title: standardPreview ? standardPreview.title : ""
            description: standardPreview ? standardPreview.description : ""
            footer: standardPreview ? standardPreview.hostname : ""
            onClicked: (mouse) => {
                switch (mouse.button) {
                    case Qt.RightButton:
                    root.imageClicked(unfurledLink, mouse, "", url) // request a dumb context menu with just "copy/open link" items
                    break
                    default:
                    Global.openLinkWithConfirmation(url, hostname)
                    break
                }
            }
        }
    }
    
    Component {
        id: unfurledProfileLinkComponent
        UserProfileCard {
            id: unfurledProfileLink

            leftTail: !root.isCurrentUser
            userName: statusContactPreview && statusContactPreview.displayName ? statusContactPreview.displayName : ""
            userPublicKey: statusContactPreview && statusContactPreview.publicKey ? statusContactPreview.publicKey : ""
            userBio: statusContactPreview && statusContactPreview.description ? statusContactPreview.description : ""
            userImage: statusContactPreviewThumbnail ? statusContactPreviewThumbnail.url : ""
            ensVerified: false // not supported yet
            onClicked: {
                Global.openProfilePopup(userPublicKey)
            }
        }
    }

    //TODO: Remove this once we have gif support in new unfurling flow
    Component {
        id: gifComponent
        CalloutCard {
            implicitWidth: linkImage.width
            implicitHeight: linkImage.height
            leftTail: !root.isCurrentUser
            StatusChatImageLoader {
                id: linkImage
                readonly property bool globalAnimationEnabled: root.messageStore.playAnimation
                readonly property string urlLink: modelData
                property bool localAnimationEnabled: true
                objectName: "LinksMessageView_unfurledImageComponent_linkImage"
                anchors.centerIn: parent
                source: urlLink
                imageWidth: 300
                isCurrentUser: root.isCurrentUser
                playing: globalAnimationEnabled && localAnimationEnabled
                isOnline: root.store.mainModuleInst.isOnline
                asynchronous: true
                isAnimated: true
                onClicked: {
                    if (!playing)
                        localAnimationEnabled = true
                    else
                        root.imageClicked(linkImage.imageAlias, mouse, source, urlLink)
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
                onClicked: d.localAskAboutUnfurling = false
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
                text: qsTr("Enable automatic GIF unfurling")
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
                            color: dontAskBtn.textColor
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
