import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1

import shared.status 1.0
import shared.controls.chat 1.0

import utils 1.0

import SortFilterProxyModel 0.2

Control {
    id: root

    required property var imagePreviewArray
    /*
    Expected roles:
        string title
        string url
        bool unfurled
        bool immutable
        string hostname
        string description
        int linkType
        int thumbnailWidth
        int thumbnailHeight
        string thumbnailUrl
        string thumbnailDataUri
    */
    required property var linkPreviewModel
    required property bool showLinkPreviewSettings

    readonly property alias hoveredUrl: d.hoveredUrl
    readonly property bool hasContent: imagePreviewArray.length > 0 || showLinkPreviewSettings || linkPreviewRepeater.count > 0

    signal imageRemoved(int index)
    signal imageClicked(var chatImage)
    signal linkReload(string link)
    signal linkClicked(string link)

    signal enableLinkPreview()
    signal enableLinkPreviewForThisMessage()
    signal disableLinkPreview()
    signal dismissLinkPreviewSettings()
    signal dismissLinkPreview(int index)

    horizontalPadding: 12
    topPadding: 12

    contentItem: Item {
        id: opacityMaskWrapper
        
        anchors.fill: parent

        implicitWidth: flickable.implicitWidth
        implicitHeight: flickable.implicitHeight

        opacity: 0

        WheelHandler {
            target: flickable
            property: "contentX"
            acceptedDevices: PointerDevice.Mouse
            onActiveChanged: if(!active) flickable.returnToBounds()
        }

        Flickable {
            id: flickable
            
            anchors.fill: parent
            anchors.leftMargin: root.leftPadding
            anchors.rightMargin: root.rightPadding
            anchors.bottomMargin: root.bottomPadding
            anchors.topMargin: root.topPadding

            implicitHeight: contentHeight
            implicitWidth: contentWidth

            contentWidth: layout.width
            contentHeight: layout.height

            onFlickStarted: settingsContextMenu.close()

            RowLayout {
                id: layout
                spacing: 8
                StatusChatInputImageArea {
                    id: imageArea
                    Layout.preferredHeight: 64
                    spacing: layout.spacing
                    imageSource: imagePreviewArray
                    onImageClicked: root.imageClicked(chatImage)
                    onImageRemoved: root.imageRemoved(index)
                    visible: !!imagePreviewArray && imagePreviewArray.length > 0
                }
                Repeater {
                    id: linkPreviewRepeater
                    model: d.filteredModel
                    delegate: LinkPreviewMiniCard {
                        // Model properties

                        required property int index
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

                        readonly property var thumbnail: {
                            switch (previewType) {
                                case Constants.Standard:
                                    return standardPreviewThumbnail
                                case Constants.StatusContact:
                                    return statusContactPreviewThumbnail
                                case Constants.StatusCommunity:
                                    return statusCommunityPreviewIcon
                                case Constants.StatusCommunityChannel:
                                    return statusCommunityChannelCommunityPreviewIcon
                            }
                        }

                        readonly property string thumbnailUrl: thumbnail ? thumbnail.url : ""
                        readonly property string thumbnailDataUri: thumbnail ? thumbnail.dataUri : ""


                        Layout.preferredHeight: 64

                        titleStr: standardPreview ? standardPreview.title : statusContactPreview ? statusContactPreview.displayName : ""
                        domain: standardPreview ? standardPreview.hostname : "" //TODO: use domain when available
                        favIconUrl: ""                  //TODO: use favicon when available
                        communityName: statusCommunityPreview ? statusCommunityPreview.displayName : ""
                        channelName: statusCommunityChannelPreview ? statusCommunityChannelPreview.displayName : ""

                        thumbnailImageUrl: thumbnailUrl.length > 0 ? thumbnailUrl : thumbnailDataUri
                        type: getCardType(previewType, standardPreview)
                        previewState: unfurled && !empty ? LinkPreviewMiniCard.State.Loaded :
                                    unfurled && empty ? LinkPreviewMiniCard.State.LoadingFailed :
                                    !unfurled ? LinkPreviewMiniCard.State.Loading : LinkPreviewMiniCard.State.Invalid

                        onClose: root.dismissLinkPreview(d.filteredModel.mapToSource(index))
                        onRetry: root.linkReload(url)
                        onClicked: root.linkClicked(url)
                        onRightClicked: settingsContextMenu.popup()
                        onContainsMouseChanged: {
                            if (containsMouse) {
                                d.hoveredUrl = url
                            } else if (d.hoveredUrl === url) {
                                d.hoveredUrl = ""
                            }
                        }
                        Component.onDestruction: {
                            if(d.hoveredUrl === url) {
                                d.hoveredUrl = ""
                            }
                        }
                    }
                }
                LinkPreviewSettingsCard {
                    id: settingsCard
                    visible: root.showLinkPreviewSettings
                    onDismiss: root.dismissLinkPreviewSettings()
                    onEnableLinkPreviewForThisMessage: root.enableLinkPreviewForThisMessage()
                    onEnableLinkPreview: root.enableLinkPreview()
                    onDisableLinkPreview: root.disableLinkPreview()
                }
            }
        }
    }
    
    Rectangle {
        id: horizontalClipMask
        anchors.fill: opacityMaskWrapper
        visible: false
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: root.horizontalPadding / horizontalClipMask.width; color: "white" }
            GradientStop { position: 1 - root.horizontalPadding / horizontalClipMask.width; color: "white" }
            GradientStop { position: 1; color: "transparent" }
        }
    }
    
    OpacityMask {
        anchors.fill: opacityMaskWrapper
        source: opacityMaskWrapper
        maskSource: horizontalClipMask
    }

    QtObject {
        id: d
        property string hoveredUrl: ""
        property SortFilterProxyModel filteredModel: SortFilterProxyModel {
            id: filteredModel
            sourceModel: root.linkPreviewModel
            filters: [
                ExpressionFilter {
                    expression: { return !model.immutable || model.unfurled } // Filter out immutable links that haven't been unfurled yet
                }
            ]
        }
    }

    LinkPreviewSettingsCardMenu {
        id: settingsContextMenu

        onEnableLinkPreviewForThisMessage: root.enableLinkPreviewForThisMessage()
        onEnableLinkPreview: root.enableLinkPreview()
        onDisableLinkPreview: root.disableLinkPreview()
    }
}
