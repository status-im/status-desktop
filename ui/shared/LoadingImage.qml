import QtQuick 2.13
import "."

SVGImage {
    id: loadingImg
    source: "../app/img/loading.svg"
    width: 17 * scaleAction.factor
    height: 17 * scaleAction.factor
    fillMode: Image.Stretch
    RotationAnimator {
        target: loadingImg;
        from: 0;
        to: 360;
        duration: 1200
        running: true
        loops: Animation.Infinite
    }
}
