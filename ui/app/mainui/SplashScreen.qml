import QtQuick 2.12

import utils 1.0
// import Qt.labs.lottieqt 1.0

Item {
    id: root

    SpriteSequence {
        id: spriteSeq2
        width: 128
        height: 128
        anchors.centerIn: parent
        Sprite {
            id: sprite
            frameCount: 90
            frameWidth: 640
            frameHeight: 640
            frameRate: 40
            source: Style.png("status_splash_" + Style.current.name)
        }
    }
    // AnimatedImage {
    //     width: 128
    //     height: 128
    //     anchors.centerIn: parent
    //     source: Style.gif("status_splash_" + Style.current.name)
    // }

    // NOTE: keep it if we will decide to switch on lottie
    // LottieAnimation {
    //     anchors.centerIn: parent
    //     autoPlay: true
    //     loops: LottieAnimation.Infinite
    //     quality: LottieAnimation.HighQuality
    //     source: Style.lottie("status_splash")
    // }
}
