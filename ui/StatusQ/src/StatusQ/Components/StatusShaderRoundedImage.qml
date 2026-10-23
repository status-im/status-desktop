import QtQuick

import StatusQ.Components.private

/*!
   \qmltype StatusShaderRoundedImage
   \inherits StatusRoundedImageBase
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief An image with rounded corners, drawn by one ShaderEffect.

   The fragment shader samples the image's own texture and computes each
   fragment's coverage from its distance to the rounded rectangle, so the
   corners cost no offscreen layer, no mask texture and no extra pass. Each
   corner has its own radius. Atlas textures are sampled in place, not copied.

   Prototype; see RoundedImagesPage in the storybook for the comparison with
   the layer + MultiEffect mask approach.

   \qml
        StatusShaderRoundedImage {
            width: 144
            height: 144
            source: "photo.jpg"
            radius: 16
            bottomLeftRadius: 4
        }
   \endqml
*/
StatusRoundedImageBase {
    id: root

    renderer: ShaderEffect {
        x: root.contentRect.x
        y: root.contentRect.y
        width: root.contentRect.width
        height: root.contentRect.height

        visible: root.status === Image.Ready

        property Item source: root.textureSource
        property size itemSize: Qt.size(width, height)
        property vector4d radii: Qt.vector4d(root.effectiveTopLeftRadius,
                                             root.effectiveTopRightRadius,
                                             root.effectiveBottomRightRadius,
                                             root.effectiveBottomLeftRadius)
        // the painted part of the image, as a 0..1 window into it
        property vector4d uvTransform: {
            const cr = root.contentRect
            const ir = root.imageRect

            if (ir.width <= 0 || ir.height <= 0)
                return Qt.vector4d(0, 0, 1, 1)

            return Qt.vector4d((cr.x - ir.x) / ir.width, (cr.y - ir.y) / ir.height,
                               cr.width / ir.width, cr.height / ir.height)
        }
        property real edgeWidth: 1 / (root.Window.window ? root.Window.window.devicePixelRatio
                                                         : Screen.devicePixelRatio)

        // next to this file: in the bundled resources, or on disk when StatusQ
        // QML is loaded from the sources
        fragmentShader: Qt.resolvedUrl("shaders/roundedimage.frag.qsb")
    }
}
