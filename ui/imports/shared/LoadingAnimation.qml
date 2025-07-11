import QtQuick

import StatusQ.Core.Theme

import utils
import shared.panels

SVGImage {
    id: loadingImg
    source: Theme.svg("loading")
    width: 25
    height: 25
    fillMode: Image.Stretch
    RotationAnimator {
        target: loadingImg
        from: 0
        to: 360
        duration: 1200
        running: visible
        loops: Animation.Infinite
    }
}
