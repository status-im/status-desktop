import QtQuick

/*!
   \qmltype StatusRoundedImageBase
   \inherits Item
   \inqmlmodule StatusQ.Components.private
   \brief Common part of the single-pass rounded image renderers.

   Holds the image as a hidden texture source and works out where it lands.
   The image is never drawn by itself: the \c renderer (see
   StatusShaderRoundedImage, StatusShapeRoundedImage) samples its texture
   directly, so rounding the corners takes no offscreen layer and no mask
   texture.

   The image is decoded at the rendered size (the item's size times the device
   pixel ratio) unless \c sourceSize is set.

   For a still image an Image is built, for an animated one an AnimatedImage.
*/
Item {
    id: root

    property url source
    // Builds an AnimatedImage rather than an Image.
    property bool animated: false
    property bool playing: true

    // Image.PreserveAspectCrop fills the item, Image.PreserveAspectFit
    // letterboxes; the corners follow what is painted.
    property int fillMode: Image.PreserveAspectCrop

    property bool cache: true
    property bool asynchronous: true
    property bool smooth: true

    // Decode size, in pixels; defaults to the rendered size.
    property size sourceSize: fillMode === Image.PreserveAspectCrop
                              ? Qt.size(Math.ceil(width * d.dpr), Math.ceil(height * d.dpr))
                              : Qt.size(Math.ceil(width * d.dpr), 0)

    property real radius: 0
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius

    // Draws textureSource over contentRect; positions itself, in this item's
    // coordinates.
    property Component renderer

    // The hidden item the renderer samples.
    readonly property Image textureSource: contentLoader.item ? contentLoader.item.image : null
    readonly property int status: textureSource ? textureSource.status : Image.Null

    // Decoded size in pixels. Equal to the implicit size for raster sources
    // without an "@Nx" suffix, which is what chat images are.
    readonly property size textureSize: textureSource
                                        ? Qt.size(textureSource.implicitWidth, textureSource.implicitHeight)
                                        : Qt.size(0, 0)

    // The whole image, scaled and centered per fillMode, in this item's
    // coordinates. Larger than the item when cropping.
    readonly property rect imageRect: {
        const tw = textureSize.width
        const th = textureSize.height

        if (tw <= 0 || th <= 0 || width <= 0 || height <= 0)
            return Qt.rect(0, 0, 0, 0)

        const scale = fillMode === Image.PreserveAspectCrop
                    ? Math.max(width / tw, height / th)
                    : Math.min(width / tw, height / th)
        const w = tw * scale
        const h = th * scale

        return Qt.rect((width - w) / 2, (height - h) / 2, w, h)
    }

    // The painted part, which the rounded corners follow: the item itself
    // when cropping, the letterboxed image otherwise.
    readonly property rect contentRect: fillMode === Image.PreserveAspectCrop
                                        ? Qt.rect(0, 0, width, height)
                                        : imageRect

    readonly property real effectiveTopLeftRadius: d.clampRadius(topLeftRadius)
    readonly property real effectiveTopRightRadius: d.clampRadius(topRightRadius)
    readonly property real effectiveBottomLeftRadius: d.clampRadius(bottomLeftRadius)
    readonly property real effectiveBottomRightRadius: d.clampRadius(bottomRightRadius)

    QtObject {
        id: d

        readonly property real dpr: root.Window.window ? root.Window.window.devicePixelRatio
                                                       : Screen.devicePixelRatio

        function clampRadius(r) {
            return Math.max(0, Math.min(r, root.contentRect.width / 2, root.contentRect.height / 2))
        }
    }

    // The image and what draws it are built, and destroyed, together. A Shape
    // must not outlive its fill item: its renderers keep a pointer to the
    // previous fill item and dereference it on their next sync, which crashes
    // when that item is gone (Qt 6.11).
    Loader {
        id: contentLoader

        anchors.fill: parent
        sourceComponent: root.animated ? animatedContent : stillContent
    }

    Component {
        id: stillContent

        Item {
            readonly property alias image: stillImage

            // A texture source only: zero-sized so it builds no paint node
            // of its own, hidden so it is never drawn.
            Image {
                id: stillImage

                width: 0
                height: 0
                visible: false

                source: root.source
                sourceSize: root.sourceSize
                fillMode: root.fillMode
                asynchronous: root.asynchronous
                cache: root.cache
                smooth: root.smooth
            }

            Loader {
                sourceComponent: root.renderer
            }
        }
    }

    Component {
        id: animatedContent

        Item {
            readonly property alias image: animatedImage

            AnimatedImage {
                id: animatedImage

                width: 0
                height: 0
                visible: false

                source: root.source
                sourceSize: root.sourceSize
                fillMode: root.fillMode
                asynchronous: root.asynchronous
                cache: root.cache
                smooth: root.smooth
                playing: root.playing
            }

            Loader {
                sourceComponent: root.renderer
            }
        }
    }
}
