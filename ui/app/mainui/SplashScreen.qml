import QtQuick 2.12

import utils 1.0
// import Qt.labs.lottieqt 1.0

Item {
    id: root

    AnimatedImage {
        width: 128
        height: 128
        anchors.centerIn: parent
        source: Style.gif("status_splash_" + Style.current.name)
    }

    // NOTE: keep it if we will decide to switch on lottie
    // LottieAnimation {
    //     anchors.centerIn: parent
    //     autoPlay: true
    //     loops: LottieAnimation.Infinite
    //     quality: LottieAnimation.HighQuality
    //     source: Style.lottie("status_splash")
    // }
}
