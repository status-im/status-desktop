import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1

import shared.status 1.0
import shared.controls.delegates 1.0

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
                    delegate: LinkPreviewMiniCardDelegate {
                        required property int index

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
                    expression: !model.immutable || model.unfurled // Filter out immutable links that haven't been unfurled yet
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
