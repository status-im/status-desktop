import QtQuick 2.13
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
    property var container

    property alias linksModel: linksRepeater.model
    readonly property alias unfurledLinksCount: d.unfurledLinksCount

    property bool isCurrentUser: false

    signal imageClicked(var image)

    spacing: 4

    QtObject {
        id: d

        property bool isImageLink: false
        property int unfurledLinksCount: 0
    }

    Repeater {
        id: linksRepeater

        delegate: Loader {
            id: linkMessageLoader
            property bool fetched: false
            property var linkData
            readonly property string uuid: Utils.uuid()

            property bool loadingFailed: false

            active: true

            Connections {
                target: localAccountSensitiveSettings
                function onWhitelistedUnfurlingSitesChanged() {
                    fetched = false
                    linkMessageLoader.sourceComponent = undefined
                    linkMessageLoader.sourceComponent = linkMessageLoader.getSourceComponent()
                }
                function onNeverAskAboutUnfurlingAgainChanged() {
                    linkMessageLoader.sourceComponent = undefined
                    linkMessageLoader.sourceComponent = linkMessageLoader.getSourceComponent()
                }
                function onDisplayChatImagesChanged() {
                    linkMessageLoader.sourceComponent = undefined
                    linkMessageLoader.sourceComponent = linkMessageLoader.getSourceComponent()
                }
            }

            Connections {
                id: linkFetchConnections
                enabled: false
                target: root.messageStore.messageModule
                onLinkPreviewDataWasReceived: {
                    let response = {}
                    try {
                        response = JSON.parse(previewData)
                    } catch (e) {
                        console.error(previewData, e)
                        linkMessageLoader.loadingFailed = true
                        return
                    }
                    if (response.uuid !== linkMessageLoader.uuid) return
                    linkFetchConnections.enabled = false

                    if (!response.success) {
                        console.error("could not get preview data")
                        linkMessageLoader.loadingFailed = true
                        return
                    }

                    linkData = response.result
                    linkMessageLoader.loadingFailed = false

                    linkMessageLoader.height = undefined // Reset height so it's not 0
                    if (linkData.contentType.startsWith("image/")) {
                        return linkMessageLoader.sourceComponent = unfurledImageComponent
                    }
                    if (linkData.site && linkData.title) {
                        linkData.address = link
                        return linkMessageLoader.sourceComponent = unfurledLinkComponent
                    }
                }
            }

            Connections {
                id: linkCommunityFetchConnections
                enabled: false
                target: root.store.communitiesModuleInst
                function onCommunityAdded(communityId) {
                    if (communityId !== linkData.communityId) {
                        return
                    }
                    linkCommunityFetchConnections.enabled = false
                    const data = root.store.getLinkDataForStatusLinks(link)
                    if (data) {
                        linkData = data
                        if (!data.fetching && data.communityId) {
                            return linkMessageLoader.sourceComponent = invitationBubble
                        }
                        // do not show unfurledLinkComponent
                        return
                    }
                }
            }

            Connections {
                target: root.store.mainModuleInst
                enabled: linkMessageLoader.loadingFailed

                function onIsOnlineChanged() {
                    if (!root.store.mainModuleInst.isOnline)
                        return

                    linkMessageLoader.fetched = false
                    linkMessageLoader.sourceComponent = undefined
                    linkMessageLoader.sourceComponent = linkMessageLoader.getSourceComponent()
                }
            }

            function getSourceComponent() {
                // Reset the height in case we set it to 0 below. See note below
                // for more information
                this.height = undefined
                const linkHostname = Utils.getHostname(link)
                if (!localAccountSensitiveSettings.whitelistedUnfurlingSites) {
                    localAccountSensitiveSettings.whitelistedUnfurlingSites = {}
                }

                const whitelistHosts = Object.keys(localAccountSensitiveSettings.whitelistedUnfurlingSites)

                const linkExists = whitelistHosts.some(hostname => linkHostname.endsWith(hostname))

                const linkWhiteListed = linkExists && whitelistHosts.some(hostname =>
                    linkHostname.endsWith(hostname) && localAccountSensitiveSettings.whitelistedUnfurlingSites[hostname] === true)

                if (!linkWhiteListed && linkExists && !RootStore.neverAskAboutUnfurlingAgain && !model.isImage) {
                    return enableLinkComponent
                }

                if (linkWhiteListed) {
                    if (fetched) {
                        if (linkData.communityId) {
                            return invitationBubble
                        }

                        return unfurledLinkComponent
                    }
                    fetched = true

                    const data = root.store.getLinkDataForStatusLinks(link)
                    if (data) {
                        linkData = data
                        if (data.fetching && data.communityId) {
                            linkCommunityFetchConnections.enabled = true
                            return
                        }
                        if (data.communityId) {
                            return invitationBubble
                        }

                        // do not show unfurledLinkComponent
                        return
                    }

                    linkFetchConnections.enabled = true
                    root.messageStore.getLinkPreviewData(link, linkMessageLoader.uuid)
                }

                if (model.isImage) {
                    if (RootStore.displayChatImages) {
                        linkData = {
                            thumbnailUrl: link
                        }
                        return unfurledImageComponent
                    }
                    else if (!(RootStore.neverAskAboutUnfurlingAgain || (d.isImageLink && index > 0))) {
                        d.isImageLink = true
                        return enableLinkComponent
                    }
                }

                // setting the height to 0 allows the "enable link" dialog to
                // disappear correctly when RootStore.neverAskAboutUnfurlingAgain
                // is true. The height is reset at the top of this method.
                this.height = 0
                return undefined
            }

            Component.onCompleted: {
                // putting this is onCompleted prevents automatic binding, where
                // QML warns of a binding loop detected
                this.sourceComponent = linkMessageLoader.getSourceComponent()
            }
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
                objectName: "LinksMessageView_unfurledImageComponent_linkImage"
                anchors.centerIn: parent
                container: root.container
                source: linkData.thumbnailUrl
                imageWidth: 300
                isCurrentUser: root.isCurrentUser
                onClicked: imageClicked(linkImage.imageAlias)
                playing: root.messageStore.playAnimation
                isOnline: root.store.mainModuleInst.isOnline
            }

            Component.onCompleted: d.unfurledLinksCount++
            Component.onDestruction: d.unfurledLinksCount--
        }
    }

    Component {
        id: invitationBubble
        InvitationBubbleView {
            store: root.store
            communityId: linkData.communityId
            anchors.left: parent.left
        }
    }

    Component {
        id: unfurledLinkComponent
        MessageBorder {
            width: linkImage.visible ? linkImage.width + 2 : 300
            height: {
                if (linkImage.visible) {
                    return linkImage.height + (Style.current.smallPadding * 2) + linkTitle.height + 2 + linkSite.height
                }
                return (Style.current.smallPadding * 2) + linkTitle.height + 2 + linkSite.height
            }
            isCurrentUser: root.isCurrentUser

            StatusChatImageLoader {
                id: linkImage
                objectName: "LinksMessageView_unfurledLinkComponent_linkImage"
                container: root.container
                source: linkData.thumbnailUrl
                visible: linkData.thumbnailUrl.length
                readonly property int previewWidth: parseInt(linkData.width)
                imageWidth: Math.min(300, previewWidth > 0 ? previewWidth : 300)
                isCurrentUser: root.isCurrentUser
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                playing: root.messageStore.playAnimation
                isOnline: root.store.mainModuleInst.isOnline
            }

            StatusBaseText {
                id: linkTitle
                text: linkData.title
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
                text: linkData.site
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
                    if (!!linkData.callback) {
                        return linkData.callback()
                    }
                    Global.openLink(linkData.address)
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
                onClicked: {
                    enableLinkRoot.height = 0
                    enableLinkRoot.visible = false
                }
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
                text: d.isImageLink ? qsTr("Enable automatic image unfurling") :
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
                    onClicked: {
                        RootStore.setNeverAskAboutUnfurlingAgain(true);
                    }
                    Component.onCompleted: {
                        background.radius = Style.current.padding;
                    }
                }
            }
        }
    }
}
