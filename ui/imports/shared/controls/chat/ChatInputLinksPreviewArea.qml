import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1

import shared.status 1.0
import shared.controls.chat 1.0

import SortFilterProxyModel 0.2

Control {
    id: root

    required property var imagePreviewModel
    required property var linkPreviewModel

    readonly property alias hoveredUrl: d.hoveredUrl
    readonly property int contentItemsCount: imagePreviewModel.length + d.filteredModel.count

    signal imageRemoved(int index)
    signal imageClicked(var chatImage)
    signal linkReload(string link)
    signal linkClicked(string link)
    signal linkRemoved(string link)

    horizontalPadding: 12
    topPadding: 12

    contentItem: Item {
        id: opacityMaskWrapper
        
        anchors.fill: parent

        implicitWidth: flickable.implicitWidth
        implicitHeight: flickable.implicitHeight

        opacity: 0

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

            RowLayout {
                id: layout
                spacing: 8
                StatusChatInputImageArea {
                    id: imageArea
                    Layout.preferredHeight: 64
                    spacing: layout.spacing
                    imageSource: imagePreviewModel
                    onImageClicked: root.imageClicked(chatImage)
                    onImageRemoved: root.imageRemoved(index)
                    visible: !!imagePreviewModel && imagePreviewModel.length > 0
                }
                Repeater {
                    model: d.filteredModel
                    delegate: LinkPreviewMiniCard {
                        // Model properties
                        required property string title
                        required property string url
                        required property bool unfurled
                        required property bool immutable
                        required property string hostname
                        required property string description
                        required property int linkType
                        required property int thumbnailWidth
                        required property int thumbnailHeight
                        required property string thumbnailUrl
                        required property string thumbnailDataUri

                        required property int index

                        Layout.preferredHeight: 64

                        titleStr: title
                        domain: hostname                //TODO: use domain when available
                        favIconUrl: thumbnailImageUrl   //TODO: use favicon when available
                        communityName: ""               //TODO: add community info when available
                        channelName: ""                 //TODO: add community info when available

                        thumbnailImageUrl: thumbnailDataUri.length > 0 ? thumbnailDataUri : thumbnailUrl
                        type: linkType === 0 ? LinkPreviewMiniCard.Type.Link : LinkPreviewMiniCard.Type.Image
                        previewState: unfurled && hostname != "" ? LinkPreviewMiniCard.State.Loaded :
                                    unfurled && hostname === "" ? LinkPreviewMiniCard.State.LoadingFailed :
                                    !unfurled ? LinkPreviewMiniCard.State.Loading : LinkPreviewMiniCard.State.Invalid

                        onClose: root.linkRemoved(url)
                        onRetry: root.linkReload(url)
                        onClicked: root.linkClicked(url)
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
            }
        }
    }

    LinearGradient {
        id: horizontalClipMask
        anchors.fill: opacityMaskWrapper
        visible: false
        start: Qt.point(0 , 0)
        end: Qt.point(horizontalClipMask.width, 0)
        gradient: Gradient {
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
}
