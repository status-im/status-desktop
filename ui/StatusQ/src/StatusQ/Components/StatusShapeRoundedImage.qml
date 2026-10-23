import QtQuick
import QtQuick.Shapes

import StatusQ.Components.private

/*!
   \qmltype StatusShapeRoundedImage
   \inherits StatusRoundedImageBase
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief An image with rounded corners, drawn as a Shape filled with it.

   A rounded PathRectangle is filled with the image's own texture
   (ShapePath.fillItem), rendered by the curve renderer, which antialiases the
   edge in its shader. No offscreen layer or mask texture is involved, and no
   custom shader either. Each corner has its own radius.

   The Shape renderers copy a texture out of the atlas before filling with it,
   so an image small enough to be atlased is held twice.

   Prototype; see RoundedImagesPage in the storybook for the comparison with
   the layer + MultiEffect mask approach.

   \qml
        StatusShapeRoundedImage {
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

    renderer: Shape {
        id: shape

        x: root.contentRect.x
        y: root.contentRect.y
        width: root.contentRect.width
        height: root.contentRect.height

        visible: root.status === Image.Ready
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: -1
            fillItem: root.textureSource

            // The fill spans the texture's pixel size divided by the device
            // pixel ratio, from the shape's origin; scale and move it onto the
            // image's rect.
            fillTransform: {
                const ir = root.imageRect
                const dpr = root.Window.window ? root.Window.window.devicePixelRatio
                                               : Screen.devicePixelRatio
                const bw = root.textureSize.width / dpr
                const bh = root.textureSize.height / dpr

                if (bw <= 0 || bh <= 0)
                    return Qt.matrix4x4()

                return Qt.matrix4x4(ir.width / bw, 0, 0, ir.x - shape.x,
                                    0, ir.height / bh, 0, ir.y - shape.y,
                                    0, 0, 1, 0,
                                    0, 0, 0, 1)
            }

            PathRectangle {
                width: shape.width
                height: shape.height
                topLeftRadius: root.effectiveTopLeftRadius
                topRightRadius: root.effectiveTopRightRadius
                bottomLeftRadius: root.effectiveBottomLeftRadius
                bottomRightRadius: root.effectiveBottomRightRadius
            }
        }
    }
}
