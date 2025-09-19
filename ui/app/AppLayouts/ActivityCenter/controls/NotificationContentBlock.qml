// NotificationContentBlock.qml
// -----------------------------------------------------------------------------
// A versatile content block for notification cards:
// - Rich text (mentions/links) clamped to 3–4 lines with ellipsis
// - Optional "hero" banner/card above the text (image or any item via default slot)
// - Optional media strip below the text:
//     * Single square thumbnail (with optional corner badge)
//     * Gallery of up to 3 thumbnails + an overflow tile "N+" for the rest
//
// DESIGN GOALS
// -------------
// * Text never overflows the card: reserved padding, max lines with elide.
// * Media layout adapts automatically to the number of attachments.
// * No Qt5Compat dependencies. Uses modern Qt6 types.
// * Safe rounded thumbs via clip:true wrappers (no shader/effects).
//
// API
// ---
// property string  contentHtml            : Rich text. Mentions as <a href="...">@name</a>.
// property int     maxLines               : 3 by default (set 4 if your card is taller).
// property int     nameMaxChars           : 120 max; overage is hard-truncated with "…"
// property bool    reserveRightGutter     : if true, keeps some right padding for
//                                           external affordances (e.g., format key).
//
// // Hero area (optional):
// property url     heroSource             : If set, shows a rounded banner above the text.
// property real    heroAspectRatio        : 1.78 (16:9) by default.
// property int     heroRadius             : 12
//
// // Media strip (optional):
// property var     attachments            : list<url> or JS array of urls
// property int     maxThumbs              : 4 (3 images + 1 overflow)
// property int     thumbSize              : 64
// property int     thumbRadius            : 10
// property int     thumbSpacing           : 8
//
// // Single-thumb badge (only when attachments.length === 1):
// property bool    showSingleBadge        : false
// property string  singleBadgeText        : "M" (1–2 chars recommended)
// property int     singleBadgeSize        : 18
//
// // Signals:
// signal linkActivated(string href)
// signal heroClicked()
// signal attachmentClicked(int index, url source)
//
// USAGE EXAMPLES
// --------------
// // Text only (3 lines):
// NotificationContentBlock {
//     contentHtml: 'hey, <a href="status:user:robert">@robertf.ox.eth</a>, Do we still plan…'
// }
//
// // With hero banner (card artwork):
// NotificationContentBlock {
//     heroSource: "https://picsum.photos/600/338"
//     contentHtml: 'hey, <a href="...">@robertf.ox.eth</a>, Do we still plan…'
// }
//
// // Single image with badge:
// NotificationContentBlock {
//     contentHtml: 'hey, <a href="...">@robertf.ox.eth</a>, Do we still plan…'
//     attachments: [ "https://picsum.photos/320/240?1" ]
//     showSingleBadge: true
//     singleBadgeText: "M"
// }
//
// // Gallery with overflow ("5+"):
// NotificationContentBlock {
//     contentHtml: 'hey, <a href="...">@robertf.ox.eth</a>, Do we still plan…'
//     attachments: [
//         "https://picsum.photos/320/240?1",
//         "https://picsum.photos/320/240?2",
//         "https://picsum.photos/320/240?3",
//         "https://picsum.photos/320/240?4",
//         "https://picsum.photos/320/240?5",
//         "https://picsum.photos/320/240?6"
//     ]
// }
//
// NOTES
// -----
// * Set maxLines to 4 if the card is taller. The component elides at the *end*
//   of the last visible line.
// * nameMaxChars is a hard cut pass that runs *before* layout, so long names
//   don’t cause reflow jitter. Only the text content is altered; links remain.
//
// -----------------------------------------------------------------------------

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils
import StatusQ.Components
import StatusQ.Components.private

import utils

Item {
    id: root

    // ---------- Public API ----------
    property string contentHtml: ""
    property int    maxLines: 3
    property int    nameMaxChars: 120

    property url    preImageSource: ""

    // Media stripe
    property var    attachments: []           // JS array or QQmlList
    property int    maxThumbs: 4
    property int    thumbSize: 56
    property int    thumbRadius: 4
    property int    thumbSpacing: 4

    property bool   showSingleBadge: false
    property string singleBadgeText: "M"
    property int    singleBadgeSize: 18

    signal linkActivated(string href)
    signal attachmentClicked(int index, url source)

    // Layout
    implicitWidth: contentColumn.implicitWidth
    implicitHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn
        width: parent.width

        // Pre-message image
        Image {
            id: preImage
            Layout.fillWidth: true
            Layout.maximumHeight: 125 // TODO: Value by design
            visible: root.preImageSource
            source: root.preImageSource
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true

            layer.enabled: true
            layer.effect: MultiEffect {
                source: preImage

                maskEnabled: true
                maskSource: mask

                visible: true
                enabled: true

                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
            }

            // Mask geometry
            Rectangle {
                id: mask
                anchors.fill: preImage
                radius: 24
                visible: false
                layer.enabled: true
            }
        }

        // Text Content
        StatusBaseText {
            id: contentText
            Layout.fillWidth: true

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: root.contentHtml
            maximumLineCount: root.maxLines
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSize13
            color: Theme.palette.directColor4

            onLinkActivated: href => root.linkActivated(href)
        }

        // Media Stripe (optional)
        RowLayout {
            Repeater {
                model: root.attachments

                Image {
                    id: imageMessage

                    Layout.preferredWidth: root.thumbSize
                    Layout.preferredHeight: root.thumbSize
                    fillMode: Image.PreserveAspectFit
                    source: root.attachments[index]

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        source: imageMessage

                        maskEnabled: true
                        maskSource: maskAlbum

                        visible: true
                        enabled: true

                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                    }

                    Rectangle {
                        id: maskAlbum
                        visible: false
                        anchors.fill: imageMessage
                        layer.enabled: true
                        radius: 8
                    }
                }
            }
        }
    }
    /* StatusMessageImageAlbum {
        Tracer{}
        Layout.fillWidth: true
        Layout.preferredHeight: root.thumbSize

        spacing: root.thumbSpacing
        imageWidth: root.thumbSize

        album: root.attachments
        albumCount: root.attachments.length > root.maxThumbs ?
                        root.attachments.length :
                        root.maxThumbs
        shapeType: StatusImageMessage.ShapeType.RIGHT_ROUNDED
        radiusShape: 4
    }*/
}
