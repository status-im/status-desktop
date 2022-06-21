import QtQuick 2.12

import utils 1.0
// import Qt.labs.lottieqt 1.0

Item {
    id: root
    anchors.fill: parent
    visible: (opacity > 0.0001)
    Behavior on opacity { NumberAnimation { duration: 250 }}

    Timer {
        running: true
        interval: 2000
        onTriggered: {
            root.opacity = 0.0;
        }
    }

    AnimatedImage {
        id: splashLogo
        width: 127.88
        height: 127.88
        anchors.centerIn: parent
        source: Style.gif("status_splash_" + (Style.current.name))
        playing: visible
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
