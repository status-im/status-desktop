import QtQuick

import StatusQ.Core.Theme

/*!
   \qmltype LoadingSkeletonTile
   \inherits ShaderEffect
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief A rounded skeleton shape with a shimmer sweep, drawn in a single
   pass without offscreen layers.

   Inside a LoadingSkeletonGroup the sweep runs across the whole group,
   otherwise across the tile itself.
*/
ShaderEffect {
    id: root

    property color color: Theme.palette.statusLoadingHighlight
    property real radius: 4

    readonly property color highlightColor: Theme.palette.statusLoadingHighlight2
    readonly property size itemSize: Qt.size(width, height)
    readonly property real pixelRatio: Screen.devicePixelRatio

    // position and size of the area the sweep travels across
    readonly property point sweepOrigin: {
        if (!d.group)
            return Qt.point(0, 0)
        let x = 0
        let y = 0
        for (let p = root; p && p !== d.group; p = p.parent) {
            x += p.x
            y += p.y
        }
        return Qt.point(x, y)
    }
    readonly property size sweepSize: d.group ? Qt.size(d.group.width, d.group.height)
                                              : itemSize
    property real phase: 0

    fragmentShader: "qrc:/StatusQ/shaders/skeletontile.frag.qsb"

    QtObject {
        id: d

        readonly property LoadingSkeletonGroup group: {
            for (let p = root.parent; p; p = p.parent) {
                if (p instanceof LoadingSkeletonGroup)
                    return p
            }
            return null
        }
    }

    Loader {
        active: root.visible
        sourceComponent: UniformAnimator {
            objectName: "shimmerAnimator"

            target: root
            uniform: "phase"
            from: 0
            to: 1
            duration: 1000
            loops: Animation.Infinite
            running: true
        }
    }
}
