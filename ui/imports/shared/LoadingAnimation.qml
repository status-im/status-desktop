import QtQuick 2.15

import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.panels 1.0

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
