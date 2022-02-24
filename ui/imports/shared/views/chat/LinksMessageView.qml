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
import shared.panels.chat 1.0
import shared.controls.chat 1.0

Column {
    id: root
    property var store
    property var messageStore
    property var container
    property string linkUrls: ""
    property bool isCurrentUser: false
    property bool isImageLink: false
    spacing: Style.current.halfPadding
    height: childrenRect.height

    onLinkUrlsChanged: {
        root.prepareModel()
    }

    function prepareModel() {
        linksModel.clear()
        if (!root.linkUrls) {
            return
        }
        root.linkUrls.split(" ").forEach(link => {
            linksModel.append({link})
        })
    }

    ListModel {
        id: linksModel
        Component.onCompleted: {
            root.prepareModel()
        }
    }

    Repeater {
        id: linksRepeater
        model: linksModel // doesn't work with a JSON object model!

        delegate: Loader {
            id: linkMessageLoader
            property bool fetched: false
            property var linkData
            property int linkWidth: linksRepeater.width
            readonly property string uuid: Utils.uuid()

            active: true

            Connections {
                target: localAccountSensitiveSettings
                onWhitelistedUnfurlingSitesChanged: {
                    fetched = false
                    linkMessageLoader.sourceComponent = undefined
                    linkMessageLoader.sourceComponent = linkMessageLoader.getSourceComponent()
                }
                onNeverAskAboutUnfurlingAgainChanged: {
                    linkMessageLoader.sourceComponent = undefined
                    linkMessageLoader.sourceComponent = linkMessageLoader.getSourceComponent()
                }
                onDisplayChatImagesChanged: {
                    linkMessageLoader.sourceComponent = undefined
                    linkMessageLoader.sourceComponent = linkMessageLoader.getSourceComponent()
                }
            }

           Connections {
               id: linkFetchConnections
               enabled: false
               target: root.messageStore.messageModule
               onLinkPreviewDataWasReceived: {
                    let response
                    try {
                        response = JSON.parse(previewData)
                    } catch (e) {
                        console.error(previewData, e)
                        return
                    }
                    if (response.uuid !== linkMessageLoader.uuid) return
                    linkFetchConnections.enabled = false

                    if (!response.success) {
                        console.error("could not get preview data")
                        return undefined
                    }

                    linkData = response.result

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
                onCommunityAdded: {
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

                        return linkMessageLoader.sourceComponent = unfurledLinkComponent
                    }
                }
            }

            function getSourceComponent() {
                // Reset the height in case we set it to 0 below. See note below
                // for more information
                this.height = undefined
                if (Utils.hasImageExtension(link)) {
                    if (RootStore.displayChatImages) {
                        linkData = {
                            thumbnailUrl: link
                        }
                        return unfurledImageComponent
                    } else {
                        if (RootStore.neverAskAboutUnfurlingAgain || (isImageLink && index > 0)) {
                            return
                        }

                        isImageLink = true
                        return enableLinkComponent
                    }
                }

                let linkWhiteListed = false
                const linkHostname = Utils.getHostname(link)
                if (!localAccountSensitiveSettings.whitelistedUnfurlingSites) {
                    localAccountSensitiveSettings.whitelistedUnfurlingSites = {}
                }
                const linkExists = Object.keys(localAccountSensitiveSettings.whitelistedUnfurlingSites).some(function(whitelistedHostname) {
                    const exists = linkHostname.endsWith(whitelistedHostname)
                    if (exists) {
                        linkWhiteListed = localAccountSensitiveSettings.whitelistedUnfurlingSites[whitelistedHostname] === true
                    }
                    return exists
                })
                if (!linkWhiteListed && linkExists && !RootStore.neverAskAboutUnfurlingAgain) {
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

                        return unfurledLinkComponent
                    }

                    linkFetchConnections.enabled = true

                    root.messageStore.getLinkPreviewData(link, linkMessageLoader.uuid)
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
                this.sourceComponent = getSourceComponent()
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
                anchors.centerIn: parent
                container: root.container
                source: linkData.thumbnailUrl
                imageWidth: 300
                isCurrentUser: root.isCurrentUser
                onClicked: imageClicked(linkImage.imageAlias)
                playing: root.messageStore.playAnimation
            }
        }
    }

    Component {
        id: invitationBubble
        InvitationBubbleView {
            store: root.store
            communityId: linkData.communityId
            isLink: true
            anchors.left: parent.left
        }
    }

    Component {
        id: unfurledLinkComponent
        MessageBorder {
            width: linkImage.width + 2
            height: linkImage.height + (Style.current.smallPadding * 2) + linkTitle.height + 2 + linkSite.height
            isCurrentUser: root.isCurrentUser

            StatusChatImageLoader {
                id: linkImage
                container: root.container
                source: linkData.thumbnailUrl
                imageWidth: 300
                isCurrentUser: root.isCurrentUser
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 1
                playing: root.messageStore.playAnimation
            }
            StatusBaseText {
                id: linkTitle
                text: linkData.title
                font.pixelSize: 13
                font.weight: Font.Medium
                elide: Text.ElideRight
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: linkImage.bottom
                anchors.rightMargin: Style.current.smallPadding
                anchors.leftMargin: Style.current.smallPadding
                anchors.topMargin: Style.current.smallPadding
                color: Theme.palette.directColor1
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
                anchors.bottomMargin: Style.current.smallPadding
            }

            MouseArea {
                anchors.top: linkImage.top
                anchors.left: linkImage.left
                anchors.right: linkImage.right
                anchors.bottom: linkSite.bottom
                cursorShape: Qt.PointingHandCursor
                onClicked:  {
                    if (!!linkData.callback) {
                        return linkData.callback()
                    }

                    Global.openLink(linkData.address)
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
                //% "Enable automatic image unfurling"
                text: isImageLink ? qsTrId("enable-automatic-image-unfurling") :
                                    //% "Enable link previews in chat?"
                                    qsTrId("enable-link-previews")
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                anchors.top: unfurlingImage.bottom
                anchors.topMargin: Style.current.halfPadding
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: infoText
                //% "Once enabled, links posted in the chat may share your metadata with their owners"
                text: qsTrId("once-enabled--links-posted-in-the-chat-may-share-your-metadata-with-their-owners")
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
                //% "Enable in Settings"
                text: qsTrId("enable-in-settings")
                onClicked: {
                    // TODO: replace with shared store constant
                    // Profile/RootStore.privacy_and_security_id
                    Global.changeAppSectionBySectionType(Constants.appSection.profile, 3);
                }
                width: parent.width
                anchors.top: sep1.bottom
            }

            Separator {
                id: sep2
                anchors.top: enableBtn.bottom
                anchors.topMargin: 0
            }

            StatusFlatButton {
                //% "Don't ask me again"
                text: qsTrId("dont-ask")
                onClicked: {
                    RootStore.setNeverAskAboutUnfurlingAgain(true);
                }
                width: parent.width
                anchors.top: sep2.bottom
            }
        }
    }
}
