import QtQuick 2.13
import "."

SVGImage {
    id: loadingImg
    // TODO replace by a real loading image
    source: "../app/img/settings.svg"
    width: 30
    height: 30
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