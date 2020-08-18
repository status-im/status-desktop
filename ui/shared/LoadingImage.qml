import QtQuick 2.13
import "."

SVGImage {
    id: loadingImg
    source: "../app/img/loading.svg"
    width: 17
    height: 17
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
